import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/snackBar.dart';
import '../../utils/booking_cancellation_dialog.dart';
import '../../service/notification_service.dart';
import '../../service/booking_incoming_service.dart';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Model/ride_now_booking_model.dart';
import '../Model/user_accept_booking_model.dart';
import '../route_helper/route_helper.dart';
import '../utils/polyline_handler.dart';
import 'auth_controller.dart';
import 'home_screen_controller.dart';
import 'my_ride_controller.dart';

class BookingController extends GetxController with WidgetsBindingObserver {
  final HomeController controller = Get.find<HomeController>();
  final SecureStorageService secure = SecureStorageService();
  final ApiService apiService = ApiService();
  final selectedIndex = RxnInt(-1);
  final reason = "".obs;
  final acceptBookLoader = false.obs;
  final cancelBookLoader = false.obs;
  final cancelStartBookLoader = false.obs;
  final statusChangeLoader = false.obs;
  final bookingId = "".obs;
  final rideNowList = <RideNowBookingModel>[].obs;
  // final rideLaterList = <RideLaterBookingModel>[].obs;
  final startRideOtp = "".obs;
  final datas = "".obs;
  // final datass = "".obs;
  final completeText = "".obs;
  final deleteId = "".obs;
  Timer? timer;
  Timer? _rideListRefreshTimer;
  Timer? _webRideListRefreshTimer;

  /// Web has no FCM — poll faster to match app notification refresh.
  static Duration get _rideListRefreshInterval => const Duration(seconds: 15);
  static const Duration _webExtraRefreshInterval = Duration(seconds: 8);

  bool _rideNowFetchInFlight = false;
  final Set<String> _knownBookingIds = <String>{};

  void _logBooking(String msg) => debugPrint('[BOOKING_API] $msg');

  UserAcceptBookingModel _userAcceptBookingModel =
      UserAcceptBookingModel.empty();
  UserAcceptBookingModel get useracceptmodel => _userAcceptBookingModel;

  String _activeAcceptedBookingId = '';
  bool _suppressUserCancellationDialog = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    userAcceptBooking(() {});
    startRideListAutoRefresh();
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshData();
    }
  }

  Future<void> refreshData() async {
    await rideNowBooking();
    await userAcceptBooking(() {});
    Get.find<MyRidesController>().rideLaterScreenBooking("", '');
  }

  /// Poll ride-now list while driver is online and not on an active trip.
  void startRideListAutoRefresh() {
    _rideListRefreshTimer?.cancel();
    _webRideListRefreshTimer?.cancel();

    _rideListRefreshTimer = Timer.periodic(_rideListRefreshInterval, (_) {
      if (!controller.onOff.value) return;
      if (controller.hide.value || controller.driverArriveValue.value) return;
      rideNowBooking();
    });

    if (kIsWeb) {
      _webRideListRefreshTimer = Timer.periodic(_webExtraRefreshInterval, (_) {
        if (!controller.onOff.value) return;
        if (controller.hide.value || controller.driverArriveValue.value) return;
        rideNowBooking();
      });
    }
  }

  void stopRideListAutoRefresh() {
    _rideListRefreshTimer?.cancel();
    _rideListRefreshTimer = null;
    _webRideListRefreshTimer?.cancel();
    _webRideListRefreshTimer = null;
  }

  /// Call when driver goes online — wait for GPS on web, then fetch bookings.
  Future<void> refreshAfterGoingOnline() async {
    if (kIsWeb && !controller.hasValidLocation.value) {
      _logBooking('waiting for GPS before booking fetch...');
      final ready = await controller.waitForValidLocation(
        timeout: const Duration(seconds: 8),
      );
      if (!ready) {
        _logBooking('booking fetch deferred — GPS not ready yet');
      }
    }
    await rideNowBooking();
    await Future.delayed(const Duration(seconds: 2));
    await rideNowBooking();
  }

  void adminApprove() {
    timer?.cancel();
    // Avoid spamming backend on app start; only check while online.
    timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!controller.onOff.value) return;
      adminLogout();
    });
  }

  void cancel() {
    timer?.cancel();
    stopRideListAutoRefresh();
  }

  Future<void> rideNowBooking() async {
    if (_rideNowFetchInFlight) return;
    _rideNowFetchInFlight = true;
    try {
      final driverId = await secure.readData(secure.user_id);
      if (driverId == null || driverId.isEmpty) {
        _logBooking('skipped — driver_id missing');
        return;
      }

      if (kIsWeb && !controller.hasValidLocation.value) {
        _logBooking('skipped — GPS not ready yet');
        return;
      }

      final payload = {'driver_id': driverId};
      final home = Get.find<HomeController>();
      final loc = home.startLocation.value;
      _logBooking(
        'POST fetch_driver_ride_now_list driver_id=$driverId '
        'lat=${loc.latitude} lng=${loc.longitude} '
        'valid=${home.hasValidLocation.value}',
      );

      final response =
          await apiService.postData(URLS.FETCH_RIDE_NOW_BOOKING, payload);

      if (response.statusCode == 429) {
        _logBooking('rate limited (429)');
        return;
      }
      if (response.statusCode >= 500) {
        _logBooking('server/network error (${response.statusCode})');
        return;
      }

      final body = response.body.trim();
      if (body.isEmpty || body.startsWith('<')) {
        _logBooking('empty response — no bookings');
        rideNowList.value = [];
        datas.value = "";
        await BookingRingManager.syncWithPendingBookings([]);
        return;
      }

      final decoded = jsonDecode(body);
      if (decoded is List) {
        rideNowList.value = decoded
            .map((item) =>
                RideNowBookingModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        _logBooking('found ${rideNowList.length} booking(s): $body');

        final pendingIds = rideNowList
            .map((b) => b.bookingId)
            .where((id) => id.isNotEmpty)
            .toList();
        final currentIdSet = pendingIds.toSet();
        final newlyDetected =
            currentIdSet.difference(_knownBookingIds).toList();
        _knownBookingIds
          ..clear()
          ..addAll(currentIdSet);

        try {
          await BookingRingManager.syncWithPendingBookings(pendingIds);
          if (newlyDetected.isNotEmpty) {
            _logBooking(
                'new booking(s) for ring/UI: ${newlyDetected.join(', ')}');
            RideNowBookingModel? latest;
            for (final b in rideNowList) {
              if (b.bookingId == newlyDetected.first) {
                latest = b;
                break;
              }
            }
            if (latest != null &&
                BookingIncomingService.instance.isAppInBackground) {
              await BookingIncomingService.instance.presentIncomingBooking(
                booking: latest,
              );
            }
          }
        } catch (e) {
          _logBooking('ring sync failed: $e');
        }
      } else {
        _logBooking('unexpected JSON: $body');
        rideNowList.value = [];
      }
      datas.value = rideNowList.isEmpty ? "" : "hello";
    } catch (e) {
      _logBooking('exception: $e');
      rideNowList.value = [];
      datas.value = "";
      await BookingRingManager.syncWithPendingBookings([]);
    } finally {
      _rideNowFetchInFlight = false;
    }
  }

/*
  void rideLaterBooking() async {
    final rideLaterBooking = {'driver_id': await secure.readData(secure.user_id)};
    try {
      final response = await apiService.postData(URLS.FETCH_RIDE_LATER_BOOKING, rideLaterBooking);
      log("ride later booking response----->:${response.body}");
      rideLaterList.value = rideLaterBookingModelFromJson(response.body);
      datass.value = rideLaterList.isEmpty ? "" : "hello";
    } catch (e) {
      log("ride later booking Exception-----", error: e.toString());
    }
  }
*/

  void acceptBooking(String bookingId, VoidCallback callback) async {
    await BookingRingManager.stopImmediate();
    BookingIncomingService.instance.clearShownState();
    acceptBookLoader.value = true;
    final accept = {
      'driver_id': await secure.readData(secure.user_id),
      "booking_id": bookingId,
    };
    try {
      final response =
          await apiService.postData(URLS.DRIVER_ACCEPT_BOOKING, accept);
      final body = response.body.trim();
      if (body.isEmpty || body.startsWith("<")) {
        acceptBookLoader.value = false;
        customSnackBar("Server busy. Please try again.");
        return;
      }
      final data = _decodeJsonSafely(body);
      if (data == null) {
        acceptBookLoader.value = false;
        customSnackBar("Invalid response from server.");
        return;
      }
      if (data['result'] == "success") {
        rideNowList.removeWhere((item) => item.bookingId == bookingId);
        await userAcceptBooking(() {});
        await rideNowBooking();
        acceptBookLoader.value = false;
        _activeAcceptedBookingId = bookingId;
        callback();
        Get.find<MyRidesController>().rideLaterScreenBooking("", '');
        customSnackBar("Booking Accepted successfully");
      } else {
        acceptBookLoader.value = false;
        customSnackBar("Something Went Wrong".tr);
      }
    } catch (e) {
      acceptBookLoader.value = false;
      log("Exception-----", error: e.toString());
    }
  }

  void cancelBooking(
      String bookingId, String reason, VoidCallback callback) async {
    await BookingRingManager.stopImmediate();
    BookingIncomingService.instance.clearShownState();
    cancelBookLoader.value = true;
    final accept = {
      'driver_id': await secure.readData(secure.user_id),
      "booking_id": bookingId,
      'reason': reason,
    };
    log("parameter----------->$accept");
    try {
      final response =
          await apiService.postData(URLS.DRIVER_CANCEL_BOOKING, accept);
      final body = response.body.trim();
      if (body.isEmpty || body.startsWith("<")) {
        cancelBookLoader.value = false;
        customSnackBar("Server busy. Please try again.");
        return;
      }
      final data = _decodeJsonSafely(body);
      if (data == null) {
        cancelBookLoader.value = false;
        customSnackBar("Invalid response from server.");
        return;
      }
      if (data['result'] == "success") {
        rideNowList.removeWhere((item) => item.bookingId == bookingId);
        completeText.value = "";
        cancelBookLoader.value = false;
        await userAcceptBooking(() {});
        await rideNowBooking();
        try {
          await Get.find<HomeController>().refreshAvailabilityStatus(
            forceDialog: true,
          );
        } catch (_) {
          /* ignore */
        }
        callback();
        customSnackBar("Booking Canceled");
      } else {
        cancelBookLoader.value = false;
        customSnackBar("Something Went Wrong".tr);
      }
    } catch (e) {
      cancelBookLoader.value = false;
      log("Exception-----", error: e.toString());
    }
  }

  void driverBookingCancel(
      String bookingId, String reason, VoidCallback callback) async {
    cancelStartBookLoader.value = true;
    final accept = {
      'driver_id': await secure.readData(secure.user_id),
      "booking_id": bookingId,
      'cancel_reason': reason,
    };
    log("parameter----------->$accept");
    try {
      final response = await apiService.postData(URLS.CANCEL_BOOKING, accept);
      final body = response.body.trim();
      if (body.isEmpty || body.startsWith("<")) {
        cancelStartBookLoader.value = false;
        customSnackBar("Server busy. Please try again.");
        return;
      }
      final data = _decodeJsonSafely(body);
      if (data == null) {
        cancelStartBookLoader.value = false;
        customSnackBar("Invalid response from server.");
        return;
      }
      if (data['result'] == "success") {
        polyline.clear();
        controller.clearMarkersExceptDriver();
        controller.onOff.value = true;
        controller.hide.value = false;
        cancelStartBookLoader.value = false;
        _suppressUserCancellationDialog = true;
        _activeAcceptedBookingId = '';
        // Ignore delayed iOS FCM / poll "Booking Cancelled" for this ride.
        BookingCancellationDialog.suppressForDriverCancel(bookingId);
        BookingCancellationDialog.clearLastShown();
        callback();
        customSnackBar("Booking Canceled".tr);
      } else {
        cancelStartBookLoader.value = false;
        customSnackBar("Something Went Wrong".tr);
      }
    } catch (e) {
      cancelStartBookLoader.value = false;

      cancelBookLoader.value = false;
      log("Exception-----", error: e.toString());
    }
  }

  Future<void> userAcceptBooking([VoidCallback? callback]) async {
    final user = {"driver_id": await secure.readData(secure.user_id)};
    try {
      final response =
          await apiService.postData(URLS.USER_ACCEPT_BOOKING, user);
      if (response.statusCode == 429) {
        log("userAcceptBooking: rate limited (429)");
        callback?.call();
        return;
      }
      final body = response.body.trim();
      if (body.isEmpty || body.startsWith("<")) {
        log("userAcceptBooking: non-JSON response (status ${response.statusCode})");
        callback?.call();
        return;
      }
      final data = _decodeJsonSafely(body);
      if (data == null) {
        log("userAcceptBooking: failed to parse JSON");
        callback?.call();
        return;
      }
      final bookingIdRaw = data['booking_id'];
      final bookingIdStr = bookingIdRaw == null ? "" : bookingIdRaw.toString();
      final previousActiveId = _activeAcceptedBookingId;
      deleteId.value = bookingIdStr;
      if (bookingIdStr.isEmpty) {
        final hadActiveBooking = previousActiveId.isNotEmpty;
        resetControllerState();
        _activeAcceptedBookingId = '';
        await rideNowBooking();
        if (hadActiveBooking &&
            !_suppressUserCancellationDialog &&
            !BookingCancellationDialog.isSuppressed(previousActiveId)) {
          BookingCancellationDialog.show(previousActiveId);
        }
        // Keep suppress true a bit longer when driver cancelled — reset only
        // if this empty response was a true passenger cancel path.
        if (!BookingCancellationDialog.isSuppressed(previousActiveId)) {
          _suppressUserCancellationDialog = false;
        }
      } else {
        _activeAcceptedBookingId = bookingIdStr;
        _suppressUserCancellationDialog = false;
        updateBookingState(data);
      }
      log("response user data accept$data");
      callback?.call();
      update();
    } catch (e) {
      log("Exception-----booking", error: e.toString());
      callback?.call();
    }
  }

  void updateBookingState(Map<String, dynamic> data) {
    _userAcceptBookingModel = UserAcceptBookingModel.fromJson(data);
    final status = _userAcceptBookingModel.status;
    final sourceLat = double.parse(_userAcceptBookingModel.sourceLat);
    final sourceLong = double.parse(_userAcceptBookingModel.sourceLong);
    final destinationLat = double.parse(_userAcceptBookingModel.destinationLat);
    final destinationLong =
        double.parse(_userAcceptBookingModel.destinationLong);

    switch (status) {
      case "Confirmed":
        updateConfirmedState(sourceLat, sourceLong);
        break;
      case "Arrived":
        updateArrivedState(sourceLat, sourceLong);
        break;
      case "Start Ride":
        updateStartRideState(destinationLat, destinationLong);
        break;
      default:
        resetControllerState();
    }
  }

  void updateConfirmedState(double sourceLat, double sourceLong) {
    BookingRingManager.stopImmediate();
    completeText.value = "Arrive".tr;
    controller.onOff.value = true;
    controller.driverArriveValue.value = true;
    controller.endLocation.value = LatLng(sourceLat, sourceLong);
    controller.hide.value = true;
    if (controller.polylineVariable.value == "") {
      getPolyLine(
        LatLng(
          controller.startLocation.value.latitude,
          controller.startLocation.value.longitude,
        ),
        LatLng(sourceLat, sourceLong),
      ).then((pts) {
        if (pts != null && pts.isNotEmpty) {
          controller.onRoutePolylineReady(pts);
        }
      });
      controller.polylineVariable.value = "hello";
    }
    if (controller.arriveDriver.value == "") {
      controller.arriveDriver.value = "Arrive";
    }
  }

  void updateArrivedState(double sourceLat, double sourceLong) {
    completeText.value = "Start Ride".tr;
    controller.polylineVariable.value = "";
    controller.onOff.value = true;
    controller.painButton.value = true;
    bookingId.value = _userAcceptBookingModel.bookingId;
    controller.driverArriveValue.value = true;
    controller.hide.value = true;
    controller.endLocation.value = LatLng(sourceLat, sourceLong);
  }

  void updateStartRideState(double destinationLat, double destinationLong) {
    completeText.value = "Complete Ride".tr;
    controller.onOff.value = true;
    controller.driverArriveValue.value = true;
    controller.hide.value = true;
    controller.endLocation.value = LatLng(0.0, 0.0);
    controller.endLocation.value = LatLng(destinationLat, destinationLong);
    if (controller.polylineVariable2.value == "") {
      getPolyLine(
        LatLng(
          controller.startLocation.value.latitude,
          controller.startLocation.value.longitude,
        ),
        LatLng(destinationLat, destinationLong),
      ).then((pts) {
        if (pts != null && pts.isNotEmpty) {
          controller.onRoutePolylineReady(pts);
        }
      });
      controller.polylineVariable2.value = "hello";
    }
  }

  void resetControllerState() {
    polyline.clear();
    controller.polylineVariable.value = "";
    controller.polylineVariable2.value = "";
    controller.clearMarkersExceptDriver();
    controller.driverArriveValue.value = false;
    controller.arriveDriver.value = "";
    controller.painButton.value = false;
    // controller.onOff.value = true;
    controller.hide.value = false;
    completeText.value = "";
    _userAcceptBookingModel = UserAcceptBookingModel.empty();
  }

  /// Call on login / logout so previous-driver trip memory never leaks.
  /// Does NOT show "Booking Cancelled" (unlike empty API after an active trip).
  void clearSessionStateForNewLogin() {
    BookingRingManager.clearSession();
    _activeAcceptedBookingId = '';
    _suppressUserCancellationDialog = true;
    BookingCancellationDialog.clearLastShown();
    deleteId.value = '';
    bookingId.value = '';
    rideNowList.clear();
    _knownBookingIds.clear();
    datas.value = '';
    completeText.value = '';
    startRideOtp.value = '';
    reason.value = '';
    selectedIndex.value = -1;
    resetControllerState();
    controller.onOff.value = false;
    controller.hide.value = false;
    controller.driverArriveValue.value = false;
    controller.arriveDriver.value = '';
    controller.mapFollowDriver.value = true;
  }

  /// Passenger cancelled — reset trip UI and show global popup (FCM / polling).
  void handleUserSideCancellationShowDialog(String bookingId) {
    BookingRingManager.stopImmediate();
    final id = bookingId.trim().isNotEmpty
        ? bookingId.trim()
        : (_activeAcceptedBookingId.isNotEmpty
            ? _activeAcceptedBookingId
            : deleteId.value);
    _suppressUserCancellationDialog = true;
    _activeAcceptedBookingId = '';
    resetControllerState();
    // Driver already cancelled this booking — never show passenger popup.
    if (id.isNotEmpty && !BookingCancellationDialog.isSuppressed(id)) {
      BookingCancellationDialog.show(id);
    }
    rideNowBooking();
  }

  void statusChange(String status, String bookingId, String endDate,
      String endTime, VoidCallback callback) async {
    statusChangeLoader.value = true;
    final statusData = {
      "driver_id": await secure.readData(secure.user_id),
      "status": status,
      "booking_id": bookingId,
    };
    log("status change----------->:$statusData");
    try {
      final response =
          await apiService.postData(URLS.STATUS_CHANGE, statusData);
      final data = _decodeJsonSafely(response.body);
      if (data == null) {
        statusChangeLoader.value = false;
        customSnackBar("Invalid response from server. Please try again.");
        return;
      }
      final result = (data['result'] ?? '').toString();
      log("status change response: $data");
      if (_isStatusChangeSuccessful(result)) {
        _applyImmediateStateForStatus(status);
        await userAcceptBooking();
        if (status == 'end_ride') {
          await rideNowBooking();
        }
        callback();
      } else {
        customSnackBar(result.isEmpty ? "Something went wrong".tr : result);
      }
      statusChangeLoader.value = false;
      update();
    } catch (e) {
      statusChangeLoader.value = false;
      log("Exception -------->", error: e.toString());
    }
  }

  void updateLatLongStartRide(String bookingId, String lat, String lng) async {
    final map = {
      'booking_id': bookingId,
      'lat': lat,
      'lng': lng,
    };
    log('latlong---------->$map');
    try {
      final response =
          await apiService.postData(URLS.DRIVER_UPDATE_LAT_LONG, map);
      final jsonString = _decodeJsonSafely(response.body);
      if (jsonString == null) return;
      log('latlng response----------${response.body}');
      final result = jsonString['result'];
      log('latlng result----------$result');
    } catch (e) {
      log("Exception updating lat/long", error: e.toString());
    }
  }

  void adminLogout() async {
    final logout = {"driver_id": await secure.readData(secure.user_id)};
    log("logout id :------>:$logout");
    try {
      final response =
          await apiService.postData(URLS.check_driver_admin_status, logout);
      final jsonString = _decodeJsonSafely(response.body);
      if (jsonString == null) {
        // Avoid crashing polling loop when API occasionally returns empty body.
        log("adminLogout: received non-JSON/empty response");
        return;
      }
      log("logout response Admin:-------->$jsonString}");
      final result = jsonString['result'];
      if (result == "Success") {
        // Do nothing, admin is approved
      } else {
        handleAdminLogout(result);
      }
    } catch (e) {
      log("Exception during admin logout", error: e.toString());
    }
  }

  void handleAdminLogout(String result) async {
    timer?.cancel();
    await Get.find<AuthController>().driverLogout("1", () {});
    await Future.delayed(Duration.zero, () {
      Get.find<HomeController>().streamSubscription.cancel();
    });
    Get.offAllNamed(RouteHelper.getLoginScreenRoute());
    customSnackBar(result);
  }

  bool _isStatusChangeSuccessful(String result) {
    final lower = result.toLowerCase();
    return lower.contains('success');
  }

  void _applyImmediateStateForStatus(String status) {
    switch (status) {
      case "arrived":
        completeText.value = "Start Ride".tr;
        controller.arriveDriver.value = "Arrived";
        controller.driverArriveValue.value = true;
        controller.hide.value = true;
        controller.painButton.value = true;
        break;
      case "start_ride":
        completeText.value = "Complete Ride".tr;
        controller.arriveDriver.value = "";
        controller.driverArriveValue.value = true;
        controller.hide.value = true;
        controller.painButton.value = true;
        break;
      case "end_ride":
        _activeAcceptedBookingId = '';
        _suppressUserCancellationDialog = true;
        BookingCancellationDialog.clearLastShown();
        resetControllerState();
        controller.onOff.value = true;
        break;
      default:
        break;
    }
  }

  Map<String, dynamic>? _decodeJsonSafely(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
