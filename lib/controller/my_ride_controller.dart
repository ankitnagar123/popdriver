import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import '../../utils/shared_preferences.dart';
import '../Model/driver_ride_history_model.dart';
import '../Model/driver_ride_later_model.dart';
import '../Model/fetch_driver_booking_details.dart';
import 'booking_controller.dart';


class MyRidesController extends GetxController {
  ApiService apiService = ApiService();
  SecureStorageService secure = SecureStorageService();
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

  // MY RIDE SCREEN PARAMETER
  var status = "".obs;
  RxString startDate = "".tr.obs;
  RxString endDate = "".tr.obs;
  var rideLoader = false.obs;
  var totalBooking = "".obs;
  var totalEarning = "".obs;
  var fetchBookLoader = false.obs;
  var driverStartBookingLoader = false.obs;
  var startIndex = 0.obs;

  // History parameter
  var dateStatus = "".obs;
  RxString HistoryStartDate = "Select".tr.obs;
  RxString HistoryEndDate = "Select".tr.obs;
  var historyLoader = false.obs;

  var historyList = <DriverRideHistoryModel>[].obs;

  var rideLaterScreenList = <RideLaterScreenBookingModel>[].obs;
  var rideLaterScreenLoader = false.obs;

  FetchDriverBookingDetailsModel? _bookingDetailsModel;

  FetchDriverBookingDetailsModel? get bookingDetailsModel =>
      _bookingDetailsModel;

  void driverTotalBooking() async {
    rideLoader.value = true;
    Map<String, dynamic> book = {
      'driver_id': await secure.readData(secure.user_id)
    };

    try {
      var response = await apiService.postData(URLS.DRIVER_TOTAL_BOOKING, book);
      var data = jsonDecode(response.body);
      log('total ride response------->$data');

      totalBooking.value = data['Total_booking'].toString();
      totalEarning.value = data['Total_earning'].toString();

      rideLoader.value = false;
    } catch (e) {
      rideLoader.value = false;
      log('Exception-----', error: e.toString());
    }
  }

  void rideHistory(String startDate, String endDate,type ) async {
    historyLoader.value = true;
    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id),
      "start_date": startDate,
      "end_date": endDate,
      "type ": type
    };

    historyList.clear();

    log("historyParameter ------->:$map");

    try {
      final response = await apiService.postData(URLS.DRIVER_RIDE_HISTORY, map);

      log("ride history response-------${response.body}");

      historyList.value = driverRideHistoryModelFromJson(response.body);

      historyLoader.value = false;
    } catch (e) {
      historyLoader.value = false;
      log("Exception----", error: e.toString());
    }
  }

  void fetchDriverBookingDetails(String bookingId, VoidCallback callback) async {
    fetchBookLoader.value = true;
    Map<String, dynamic> map = {
      'driver_id': await secure.readData(secure.user_id),
      'booking_id': bookingId
    };
    print("booking parameter -----?:$map");

    try {
      _bookingDetailsModel = null;
      final response = await apiService.postData(URLS.DRIVER_BOOKING_DETAILS, map);

      log("booking details response------->:${jsonDecode(response.body)}");

      _bookingDetailsModel = FetchDriverBookingDetailsModel.fromJson(jsonDecode(response.body));
      log('${_bookingDetailsModel}');
      callback();
      fetchBookLoader.value = false;
    } catch (e) {
      fetchBookLoader.value = false;
      log("Exception-----vishnu", error: e.toString());
    }
  }

  void rideLaterScreenBooking(String start_date,String end_date  )async{
    rideLaterScreenLoader.value  = true;
    Map<String, dynamic> booking = {
      "driver_id": await secure.readData(secure.user_id),
      "start_date":start_date,
      "end_date":end_date,
    };

    log("$booking");

    try{

      final response = await apiService.postData(URLS.RIDE_LATER_SCREEN_DRIVER_BOOKING, booking);

      log("ride later booking screen response-----${response.body}");

      rideLaterScreenList.value = rideLaterScreenBookingModelFromJson(response.body);

      startDate.value = "";
      endDate.value = "";
      rideLaterScreenLoader.value = false;

    }catch(e){
      rideLaterScreenLoader.value = false;
      log("Exception------>",error: e.toString());
    }

  }

  void driverStartRide(String bookingId,VoidCallback callback)async{
    driverStartBookingLoader.value = true;
    Map<String, dynamic> start  = {

    "driver_id" : await secure.readData(secure.user_id),
    "booking_id" : bookingId,
    };
    
    log('parameter------>:$start');
    
    try{
      
      final response = await apiService.postData(URLS.RIDE_LATER_SCREEN_DRIVER_BOOKING_START, start);

      var jsonString = jsonDecode(response.body);

      log('response === >:$jsonString');

      if(jsonString['result'] == "arrived successfully"){
        driverStartBookingLoader.value = false;
        Get.find<BookingController>().userAcceptBooking(() { });
        Get.back();
        Get.back();
      }else{
       callback();
       driverStartBookingLoader.value = false;
      }
    }catch(e){
      driverStartBookingLoader.value = false;
      log("Exception------->:",error: e.toString());
    }

  }
  
}
