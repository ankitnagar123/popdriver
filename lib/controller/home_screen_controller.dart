import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mtaanidriver/controller/permision_controller.dart';
import '../Network/api_service.dart';
import '../Network/urls.dart';
import '../utils/colors.dart';
import '../utils/shared_preferences.dart';

import 'auth_controller.dart';
import 'booking_controller.dart';

class HomeController extends GetxController {
  SecureStorageService secure = SecureStorageService();

  RxString arriveDriver = "".obs;
  RxBool driverArriveValue = false.obs;
  RxBool hide = false.obs;

  var bookingIndex = -1.obs;
  var polylineVariable = "".obs;
  var polylineVariable1 = "".obs;
  var polylineVariable2 = "".obs;
  var cancelIndex = -1.obs;
  RxBool onOff = false.obs;
  RxBool painButton = false.obs;
  var startLocation = LatLng(22.6832, 75.8576).obs;
  var endLocation = LatLng(22.636383, 75.810692).obs;
  late StreamSubscription<Position> streamSubscription;
  PolylinePoints polylinePoints = PolylinePoints();

  var markers = <Marker>[].obs;
  List<LatLng> polylineCoordinates = [];
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  ApiService apiService = ApiService();

  // var googleMapController = Rx<GoogleMapController?>(null);

  Rx<GoogleMapController?> googleMapController = Rx<GoogleMapController?>(null);
  Uint8List? _driverMarkerBytes;
  DateTime? _lastDriverLatLongSyncAt;
  DateTime? _lastRideRefreshAt;
  DateTime? _lastPenaltyDialogAt;
  DateTime? _penaltyUntil;
  Timer? _penaltyExpiryTimer;
  bool _wasOnlineBeforePenalty = false;
  LatLng? _lastCameraTarget;
  bool _isListening = false;

  /// Bump so `HomeScreen` rebuilds polylines after async Directions fetch.
  final RxInt mapPolylineEpoch = 0.obs;
  final RxInt penaltyRemainingSeconds = 0.obs;

  void setGoogleMapController(GoogleMapController controller) {
    googleMapController.value = controller;
  }

  void updateCameraPosition(LatLng location) {
    final controller = googleMapController.value;
    if (controller != null) {
      // Avoid over-animating camera on each GPS tick; it causes jitter on iOS.
      if (_lastCameraTarget != null) {
        final distance = Geolocator.distanceBetween(
          _lastCameraTarget!.latitude,
          _lastCameraTarget!.longitude,
          location.latitude,
          location.longitude,
        );
        if (distance < 8) return;
      }
      _lastCameraTarget = location;
      try {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: location,
              zoom: 16,
            ),
          ),
        );
      } on PlatformException catch (e) {
        log('animateCamera skipped: ${e.message}');
      }
    }
  }

  /// Called after the route polyline is decoded so the map refreshes and fits the path.
  void onRoutePolylineReady(List<LatLng> points) {
    if (points.isEmpty) return;
    mapPolylineEpoch.value++;
    _fitCameraToRoute(points);
  }

  void _fitCameraToRoute(List<LatLng> points) {
    final mapCtl = googleMapController.value;
    if (mapCtl == null || points.length < 2) return;
    try {
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;
      for (final p in points) {
        minLat = minLat < p.latitude ? minLat : p.latitude;
        maxLat = maxLat > p.latitude ? maxLat : p.latitude;
        minLng = minLng < p.longitude ? minLng : p.longitude;
        maxLng = maxLng > p.longitude ? maxLng : p.longitude;
      }
      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      mapCtl.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } on PlatformException catch (e) {
      log('fitCameraToRoute skipped: ${e.message}');
    } catch (e) {
      log('fitCameraToRoute skipped: $e');
    }
  }

  @override
  void onClose() {
    _penaltyExpiryTimer?.cancel();
    try {
      stopListening();
    } catch (e) {
      print("Error in onClose: $e");
    }
    super.onClose();
  }

  @override
  void dispose() {
    _penaltyExpiryTimer?.cancel();
    try {
      stopListening();
    } catch (e) {
      print("Error in dispose: $e");
    }
    super.dispose();
  }

  /// Call when driver manually goes offline — don't auto-restore after penalty.
  void clearPenaltyAutoRestore() {
    _wasOnlineBeforePenalty = false;
    _penaltyExpiryTimer?.cancel();
  }

  // User location
  getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    startListening();
  }

  void startListening() {
    if (_isListening) return;
    _isListening = true;
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      print("listening -----");
      startLocation.value = LatLng(position.latitude, position.longitude);
      updateMarker(position);
      Data(position, Get.context!);
    });
  }

  void stopListening() {
    try {
      _isListening = false;
      streamSubscription.cancel().then((_) {
        try {
          Get.find<PermissionController>().mapSubscription?.cancel();
          Get.find<PermissionController>().mapSubscription = null;
          print("Position stream subscription cancelled");
        } catch (e) {
          print("Error cancelling map subscription: $e");
        }
      }).catchError((error) {
        print("Error cancelling position stream subscription: $error");
      });
    } catch (e) {
      print("Error in stopListening: $e");
    }
  }

/*
   Future<void> updateMarker(Position position) async {
      Uint8List imageData = await getMarkers();
      markers.clear();
      markers.add(Marker(
         markerId: MarkerId("1"),
         position: LatLng(position.latitude, position.longitude),
         rotation: position.heading,
         draggable: true,
         zIndex: 2,
         flat: true,
         anchor: Offset(0.5, 0.5),
         icon: BitmapDescriptor.fromBytes(imageData),
      ));
   }
*/

  Future<void> updateMarker(Position position) async {
    _driverMarkerBytes ??= await getMarkers();
    final marker =
        markers.firstWhereOrNull((m) => m.markerId == const MarkerId("1"));

    if (marker != null) {
      markers.remove(marker);
    }

    markers.add(Marker(
      markerId: const MarkerId("1"),
      position: LatLng(position.latitude, position.longitude),
      rotation: position.heading,
      draggable: true,
      zIndex: 2,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      icon: BitmapDescriptor.fromBytes(_driverMarkerBytes!),
    ));
  }

  Future<Uint8List> getMarkers() async {
    ByteData byteData = await rootBundle.load("assets/images/imagemarker.png");
    return byteData.buffer.asUint8List();
  }

  // User pickup Location Marker
  Future<void> userPickupMarker(BuildContext context) async {
    Uint8List imageData = await getMarker(context);
    markers.removeWhere((m) => m.markerId == const MarkerId("2"));
    markers.add(Marker(
      markerId: MarkerId("2"),
      position: endLocation.value,
      zIndex: 2,
      infoWindow: InfoWindow(
        title: 'User Current Location',
      ),
      icon: BitmapDescriptor.fromBytes(imageData),
    ));
  }

  // User pickup Location Marker
  Future<Uint8List> getMarker(BuildContext context) async {
    ByteData byteData = await DefaultAssetBundle.of(context)
        .load("assets/images/Picup_Marker.png");
    return byteData.buffer.asUint8List();
  }

  // Update Driver latLong.....
  void updateDriverLatLong(
    String lat,
    String long,
    String rotation,
    String status, {
    BuildContext? context,
  }) async {
    Map<String, dynamic> latlong = {
      "driver_id": await secure.readData(secure.user_id),
      'lat': lat,
      "long": long,
      'rotation': rotation,
      'available_status': status,
    };

    log("update driver lat long ---->:$latlong");

    try {
      final response =
          await apiService.postData(URLS.DRIVER_LATLONG_UPDATE, latlong);
      if (response.statusCode == 429) return;
      final body = response.body.trim();
      if (body.isEmpty || body.startsWith("<")) return;
      final decoded = jsonDecode(body);
      if (decoded is! Map) return;
      final data = Map<String, dynamic>.from(decoded);
      log("update driver latlong response ---->:$data");
      log("result------->:${data['result']}");
      _handleLatLongResponse(data, context: context);
    } catch (e) {
      log('Exception-----', error: e.toString());
    }
  }

  bool _isUnavailableStatus(String? status) {
    final normalized = (status ?? '').trim().toLowerCase().replaceAll(' ', '');
    return normalized == 'unavailable';
  }

  bool isPenaltyActive() {
    if (_penaltyUntil == null) return false;
    return DateTime.now().isBefore(_penaltyUntil!);
  }

  int _remainingPenaltySeconds() {
    if (_penaltyUntil == null) return 0;
    final remaining = _penaltyUntil!.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  String _penaltyMessage([int? seconds]) {
    final remaining = seconds ?? _remainingPenaltySeconds();
    if (remaining >= 3600) {
      final hours = remaining ~/ 3600;
      final minutes = (remaining % 3600) ~/ 60;
      return 'You are unavailable due to penalty. Try again in @hours h @minutes m'
          .trParams({'hours': '$hours', 'minutes': '$minutes'});
    }
    if (remaining >= 60) {
      return 'You are unavailable due to penalty. Try again in @minutes min'
          .trParams({'minutes': '${remaining ~/ 60}'});
    }
    return 'You are unavailable due to penalty. Try again in @seconds sec'
        .trParams({'seconds': '$remaining'});
  }

  void _applyPenaltyFromBackend(int penaltySeconds) {
    _penaltyExpiryTimer?.cancel();
    penaltyRemainingSeconds.value = penaltySeconds;
    if (penaltySeconds > 0) {
      _penaltyUntil = DateTime.now().add(Duration(seconds: penaltySeconds));
      _penaltyExpiryTimer = Timer(Duration(seconds: penaltySeconds), () {
        if (!isPenaltyActive()) {
          _onPenaltyCleared();
        }
      });
    } else {
      _penaltyUntil = null;
    }
  }

  void _onPenaltyCleared({BuildContext? context, Position? position}) {
    _penaltyExpiryTimer?.cancel();
    _penaltyUntil = null;
    penaltyRemainingSeconds.value = 0;

    if (!_wasOnlineBeforePenalty) return;
    _wasOnlineBeforePenalty = false;

    onOff.value = true;
    sp.setBoolValue(sp.DRIVER_ONLINE_STATUS, true);
    Get.find<BookingController>().rideNowBooking();

    if (position != null) {
      _lastDriverLatLongSyncAt = null;
      updateDriverLatLong(
        position.latitude.toString(),
        position.longitude.toString(),
        position.heading.toString(),
        'Available',
        context: context,
      );
    }

    log('Penalty cleared — driver restored to online');
  }

  void _showPenaltyDialog({
    required String message,
    BuildContext? context,
    bool isPenalty = true,
  }) {
    final now = DateTime.now();
    if (_lastPenaltyDialogAt != null &&
        now.difference(_lastPenaltyDialogAt!).inSeconds < 30) {
      return;
    }
    _lastPenaltyDialogAt = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen == true) return;

      final dialogContext = context ?? Get.overlayContext ?? Get.context;
      if (dialogContext == null || !dialogContext.mounted) return;

      showDialog<void>(
        context: dialogContext,
        barrierDismissible: false,
        builder: (dialogCtx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 52,
                ),
                const SizedBox(height: 16),
                Text(
                  isPenalty ? 'Penalty Applied'.tr : 'Unavailable'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: MyColors.DarkBlue.withOpacity(0.9),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _forceDriverUnavailable({
    required String message,
    BuildContext? context,
    bool showDialog = true,
    bool isPenalty = false,
  }) {
    final wasOnline = onOff.value;
    if (wasOnline && isPenalty) {
      _wasOnlineBeforePenalty = true;
    } else if (!isPenalty) {
      _wasOnlineBeforePenalty = false;
    }
    onOff.value = false;
    sp.setBoolValue(sp.DRIVER_ONLINE_STATUS, false);

    if (!wasOnline || !showDialog) return;

    _showPenaltyDialog(
      message: message,
      context: context,
      isPenalty: isPenalty,
    );
  }

  void _handleLatLongResponse(
    Map<String, dynamic> data, {
    BuildContext? context,
  }) {
    final backendStatus = data['available_status']?.toString();
    final penaltySeconds =
        int.tryParse(data['penalty_remaining_seconds']?.toString() ?? '0') ?? 0;

    _applyPenaltyFromBackend(penaltySeconds);

    // Backend penalty OR unavailable → driver must go offline.
    // Next GPS sync will send UnAvailable automatically (onOff = false).
    if (penaltySeconds > 0 || _isUnavailableStatus(backendStatus)) {
      final message = penaltySeconds > 0
          ? _penaltyMessage(penaltySeconds)
          : 'You have been marked unavailable by admin'.tr;
      _forceDriverUnavailable(
        message: message,
        context: context,
        isPenalty: penaltySeconds > 0,
      );
      return;
    }

    _onPenaltyCleared(context: context);
  }

  bool canGoOnline({bool showMessage = true}) {
    if (isPenaltyActive()) {
      if (showMessage) {
        _showPenaltyDialog(
          message: _penaltyMessage(),
          isPenalty: true,
        );
      }
      return false;
    }
    return true;
  }

  void _syncDriverAvailability(Position position, BuildContext context) {
    final now = DateTime.now();
    final shouldSync = _lastDriverLatLongSyncAt == null ||
        now.difference(_lastDriverLatLongSyncAt!).inSeconds >= 3;
    if (!shouldSync) return;

    _lastDriverLatLongSyncAt = now;

    if (onOff.value) {
      if (isPenaltyActive()) {
        _forceDriverUnavailable(
          message: _penaltyMessage(),
          context: context,
          isPenalty: true,
        );
        updateDriverLatLong('0', '0', '0', 'UnAvailable', context: context);
        return;
      }
      updateDriverLatLong(
        position.latitude.toString(),
        position.longitude.toString(),
        position.heading.toString(),
        'Available',
        context: context,
      );
    } else {
      if (!isPenaltyActive() && _wasOnlineBeforePenalty) {
        _onPenaltyCleared(context: context, position: position);
        return;
      }
      updateDriverLatLong('0', '0', '0', 'UnAvailable', context: context);
    }
  }

  Future<void> Data(Position position, BuildContext context) async {
    try {
      // Check if Google Map controller is available
      if (googleMapController.value != null) {
        updateCameraPosition(LatLng(position.latitude, position.longitude));
      }

      final now = DateTime.now();
      // Slightly looser polling reduces duplicate requests (helps with HTTP 429).
      final shouldRefreshRideState = _lastRideRefreshAt == null ||
          now.difference(_lastRideRefreshAt!).inSeconds >= 12;
      if (shouldRefreshRideState) {
        _lastRideRefreshAt = now;
        var loginKey = await sp.getStringValue(sp.LOGIN_DEVICE_KEY.toString());
        var accessToken = await sp.getStringValue(sp.ACCESS_TOKEN.toString());
        var authController = Get.find<AuthController>();
        authController.loginCheck(loginKey.toString(), accessToken, context);
        Get.find<BookingController>().rideNowBooking();
        Get.find<BookingController>().userAcceptBooking();
      }

      _syncDriverAvailability(position, context);

      var bookingController = Get.find<BookingController>();
      startLocation.value = LatLng(position.latitude, position.longitude);

      if (hide.value == false) {
        // Do nothing if hide is false
      } else if (bookingController.useracceptmodel.bookingId != "") {
        bookingController.updateLatLongStartRide(
          bookingController.useracceptmodel.bookingId,
          position.latitude.toString(),
          position.longitude.toString(),
        );
      }

      if (bookingController.useracceptmodel.status != "") {
        userPickupMarker(context);
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
