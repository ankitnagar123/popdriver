import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import '../../Model/fetch_cart_model.dart';
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/snackBar.dart';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Model/ride_later_booking_model.dart';
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
  final SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  final ApiService apiService = ApiService();
  final selectedIndex = RxnInt(-1);
  final reason = "".obs;
  final acceptBookLoader = false.obs;
  final cancelBookLoader = false.obs;
  final cancelStartBookLoader = false.obs;
  final statusChangeLoader = false.obs;
  final bookingId = "".obs;
  final rideNowList = <RideNowBookingModel>[].obs;
  final rideLaterList = <RideLaterBookingModel>[].obs;
  final startRideOtp = "".obs;
  final datas = "".obs;
  final datass = "".obs;
  final completeText = "".obs;
  final deleteId = "".obs;
  Timer? timer;

  late UserAcceptBookingModel _userAcceptBookingModel;
  UserAcceptBookingModel get useracceptmodel => _userAcceptBookingModel;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    userAcceptBooking(() {});
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

  void refreshData() {
    rideNowBooking();
    rideLaterBooking();
    userAcceptBooking(() {});
    Get.find<MyRidesController>().rideLaterScreenBooking("", '');
  }

  void adminApprove() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) => adminLogout());
  }

  void cancel() {
    timer?.cancel();
  }

  void rideNowBooking() async {
    final rideNowBooking = {'driver_id': await secure.readData(secure.user_id)};
    try {
      rideLaterList.clear();
      final response = await apiService.postData(URLS.FETCH_RIDE_NOW_BOOKING, rideNowBooking);
      log("ride now booking response----->:${response.body}");
      rideNowList.value = rideNowBookingModelFromJson(response.body);
      datas.value = rideNowList.isEmpty ? "" : "hello";
    } catch (e) {
      log("ride now booking Exception-----", error: e.toString());
    }
  }

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

  void acceptBooking(String bookingId, VoidCallback callback) async {
    acceptBookLoader.value = true;
    final accept = {
      'driver_id': await secure.readData(secure.user_id),
      "booking_id": bookingId,
    };
    try {
      final response = await apiService.postData(URLS.DRIVER_ACCEPT_BOOKING, accept);
      final data = jsonDecode(response.body);
      if (data['result'] == "success") {
        userAcceptBooking(() {});
        acceptBookLoader.value = false;
        callback();
        Get.find<MyRidesController>().rideLaterScreenBooking("", '');
        customSnackBar("Accepted successfully");
      } else {
        acceptBookLoader.value = false;
        customSnackBar("Something Went Wrong".tr);
      }
    } catch (e) {
      acceptBookLoader.value = false;
      log("Exception-----", error: e.toString());
    }
  }

  void cancelBooking(String bookingId, String reason, VoidCallback callback) async {
    cancelBookLoader.value = true;
    final accept = {
      'driver_id': await secure.readData(secure.user_id),
      "booking_id": bookingId,
      'reason': reason,
    };
    log("parameter----------->$accept");
    try {
      final response = await apiService.postData(URLS.DRIVER_CANCEL_BOOKING, accept);
      final data = jsonDecode(response.body);
      if (data['result'] == "success") {
        completeText.value = "";
        cancelBookLoader.value = false;
        userAcceptBooking(() {});
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

  void driverBookingCancel(String bookingId, String reason, VoidCallback callback) async {
    cancelStartBookLoader.value = true;
    final accept = {
      'driver_id': await secure.readData(secure.user_id),
      "booking_id": bookingId,
      'cancel_reason': reason,
    };
    log("parameter----------->$accept");
    try {
      final response = await apiService.postData(URLS.CANCEL_BOOKING, accept);
      final data = jsonDecode(response.body);
      if (data['result'] == "success") {
        polyline.clear();
        controller.markers.clear();
        controller.onOff.value = true;
        controller.hide.value = false;
        cancelStartBookLoader.value = false;
        callback();
        customSnackBar("Booking Canceled".tr);
      } else {
        cancelStartBookLoader.value = false;
        customSnackBar("Something Went Wrong".tr);
      }
    } catch (e) {
      cancelBookLoader.value = false;
      log("Exception-----", error: e.toString());
    }
  }

  void userAcceptBooking(VoidCallback callback) async {
    final user = {"driver_id": await secure.readData(secure.user_id)};
    try {
      final response = await apiService.postData(URLS.USER_ACCEPT_BOOKING, user);
      final data = jsonDecode(response.body);
      deleteId.value = data['booking_id'];
      if (data['booking_id'] == "") {
        resetControllerState();
      } else {
        updateBookingState(data);
      }
      log("response user data accept${data}");
    } catch (e) {
      log("Exception-----booking", error: e.toString());
    }
  }

  void updateBookingState(Map<String, dynamic> data) {
    _userAcceptBookingModel = UserAcceptBookingModel.fromJson(data);
    final status = _userAcceptBookingModel.status;
    final sourceLat = double.parse(_userAcceptBookingModel.sourceLat);
    final sourceLong = double.parse(_userAcceptBookingModel.sourceLong);
    final destinationLat = double.parse(_userAcceptBookingModel.destinationLat);
    final destinationLong = double.parse(_userAcceptBookingModel.destinationLong);

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
    completeText.value = "Arrive".tr;
    controller.onOff.value = true;
    controller.driverArriveValue.value = true;
    controller.endLocation.value = LatLng(sourceLat, sourceLong);
    controller.hide.value = true;
    if (controller.polylineVariable.value == "") {
      getPolyLine(LatLng(controller.startLocation.value.latitude, controller.startLocation.value.longitude),
          LatLng(sourceLat, sourceLong));
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
      getPolyLine(LatLng(controller.startLocation.value.latitude, controller.startLocation.value.longitude),
          LatLng(destinationLat, destinationLong));
      controller.polylineVariable2.value = "hello";
    }
  }

  void resetControllerState() {
    polyline.clear();
    controller.polylineVariable.value = "";
    controller.polylineVariable2.value = "";
    controller.markers.clear();
    controller.driverArriveValue.value = false;
    controller.arriveDriver.value = "";
    controller.painButton.value = false;
    // controller.onOff.value = true;
    controller.hide.value = false;
    completeText.value = "";
  }

  void statusChange(String status, String bookingId, String endDate, String endTime, VoidCallback callback) async {
    statusChangeLoader.value = true;
    final statusData = {
      "driver_id": await secure.readData(secure.user_id),
      "status": status,
      "booking_id": bookingId,
    };
    log("status change----------->:$statusData");
    try {
      final response = await apiService.postData(URLS.STATUS_CHANGE, statusData);
      final data = jsonDecode(response.body);
      final result = data['result'];
      log("status change response: $data");
      if (result == "arrived successfully") {
        final otp = data['confirmation_code'].toString();
       /* sp.setStringValue(sp.DRIVER_START_RIDE_OTP, otp);*/
      }
      userAcceptBooking(() {});
      callback();
      statusChangeLoader.value = false;
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
      final response = await apiService.postData(URLS.DRIVER_UPDATE_LAT_LONG, map);
      final jsonString = jsonDecode(response.body);
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
      final response = await apiService.postData(URLS.check_driver_admin_status, logout);
      final jsonString = jsonDecode(response.body);
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
    Get.find<AuthController>().driverLogout("1", () {});
    final language = await sp.getStringValue(sp.LANGUAGE);
    sp.clearData();
    secure.deleteAllData();
    sp.setBoolValue(sp.ON_BOARDING_KEY, true);
    if (language != null) {
      sp.setStringValue(sp.LANGUAGE, language);
    }
    await Future.delayed(Duration.zero, () {
      Get.find<HomeController>().streamSubscription.cancel();
    });
    Get.offAllNamed(RouteHelper.getLoginScreenRoute());
    customSnackBar(result);
  }
}
