import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get/get.dart';
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import 'package:flutter/material.dart';
import '../Model/notification_model.dart';
import '../Network/urls.dart';
import '../utils/shared_preferences.dart';
import '../utils/snackBar.dart';

import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'as DIO;
import 'package:flutter/material.dart';
import '../Model/fetch_complane_model.dart';
import '../Model/fetch_single_complane_model.dart';
import '../Network/api_service.dart';
import '../Network/urls.dart';
import '../utils/shared_preferences.dart';
import 'home_screen_controller.dart';

class PainButtonController extends GetxController{
  SecureStorageService secure = SecureStorageService();
  HomeController controller  = Get.find<HomeController>();
  var location = "".obs;
  var imageString = Rxn<File>();
  var painLoader = false.obs;
  RxString imageName = "".obs;
  var reportLoader = false.obs;
  DIO.Dio  dioClient = DIO.Dio();
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  ApiService apiService = ApiService();

  var fetchComplanList = <FetchComplaneModel>[].obs;
  var  fetchComLoader = false.obs;
  var fetchSingleQueryLoader = false.obs;
  var fetchSingleComList = <FetchSingleComplaneModel>[].obs;
  var closeQueryLoader = false.obs;
  var replyLoader = false.obs;

  Future<void> getAddressFromLatLng(String BookingId) async {

    List<Placemark> placeMarks = await placemarkFromCoordinates(
        controller.startLocation.value.latitude,
        controller.startLocation.value.longitude,
    );
    print(placeMarks);

    Placemark place = placeMarks[0];
   location.value =
    '${place.subLocality},${place.locality},${place.administrativeArea},${place.postalCode}, ${place.country}';
    print("destination ------>:${location.value}");
    complain(BookingId, location.value, controller.startLocation.value.latitude.toString(),  controller.startLocation.value.longitude.toString());
  }

  void report(String booking_id,String title,String complain,File? file)async{
  reportLoader.value = true;
  DIO.FormData formData = DIO.FormData.fromMap({

    "driver_id"  : await secure.readData(secure.user_id),
    "booking_id"  : booking_id,
    "title"       : title,
    "complain"   : complain,
    "image"      : await DIO.MultipartFile.fromFile(file!.path,filename: file.path.split("/").last),

  });
  log("parameter ------ ${formData.fields}");
  
  try{
    
    final response = await apiService.multiPartFile(URLS.REPORT, formData);

    var jsonString = jsonDecode(response.data);
    log("response --------$jsonString");

    if(jsonString['result'] == "success"){
      reportLoader.value = false;
      fetchComp("fetch",booking_id);
      imageString.value = null;
      imageName.value = "";
      customSnackBar("Complaint Added Successfully");

    }else{
      reportLoader.value = false;
    }
    
  }catch(e){
    reportLoader.value = false;
    log("Exception-----",error: e.toString());
  }
  }


  void complain(String booking_id,String location,String latitude,String longitude)async{
    painLoader.value = true;
    Map<String, dynamic> complain = {

      "driver_id" : await secure.readData(secure.user_id),
      "booking_id" : booking_id,
      "location"  : location,
      "latitude"  : latitude,
      "longitude" : longitude,
    };
    
    log("parameter------->:$complain");
    
    try{
      
      final response = await apiService.postData(URLS.PAIN_BUTTON, complain);

      var jsonString = jsonDecode(response.body);
      log('response-------->:$jsonString');
      if(jsonString['result'] == "success"){
        painLoader.value = false;
        customSnackBar("panic notification sent successfully sent to admin");
        log("pain Notification-----------------${jsonString['result']}");
      }else{
        painLoader.value = false;
      }
      
    }catch(e){
      painLoader.value = false;
      log("Exception------",error: e.toString());
    }
    
  }

  void fetchComp(String status,String bookingID)async{
    if(status == ""){
      fetchComLoader.value = true;
    }
    Map<String,dynamic> map = {
      'driver_id' : await secure.readData(secure.user_id)??"",
      "booking_id" : bookingID,
    };

    try{

      final response = await apiService.postData(URLS.FETCH_Com, map);

      log(" fetch Compliance response -----${response.body}");

      fetchComplanList.value = fetchComplaneModelFromJson(response.body);
    fetchComLoader.value = false;
    }catch(e){
    fetchComLoader.value = false;
      log("fetch Compliance Exception ---",error: e.toString());
    }

  }

  void fetchSingleQueryCom(String complain_number,String status)async{
    if(status == ""){
      fetchSingleQueryLoader.value = true;
    }

    Map<String,dynamic> map = {
      'driver_id' : await secure.readData(secure.user_id)??"",
      'complain_number' : complain_number,
    };

    try{

      final response = await apiService.postData(URLS.FETCH_Single_Com, map);

      log(" single query response -----${response.body}");

      fetchSingleComList.value = fetchSingleComplaneModelFromJson(response.body);
      fetchSingleQueryLoader.value = false;
    }catch(e){
      fetchSingleQueryLoader.value = false;
      log("single Query Exception ---",error: e.toString());
    }

  }

  void closeTicket(String complain_number,id)async{
    closeQueryLoader.value = true;
    Map<String,dynamic> map = {
      'driver_id' : await secure.readData(secure.user_id)??"",
      'complain_number' : complain_number,
    };

    try{

      final response = await apiService.postData(URLS.CLOSE_TICKET1, map);

      var jsonString = jsonDecode(response.body);

      log(" close query response -----$jsonString");

      if(jsonString['result'] == "successfully"){
        Get.back();
        customSnackBar("Ticket Closed");
        fetchComp("fetch",id);

      }else{
        customSnackBar("something went wrong");
      }

      closeQueryLoader.value = false;
    }catch(e){
      closeQueryLoader.value = false;
      log("close Query Exception ---",error: e.toString());
    }

  }

  void replyThread(String complain_number,message)async{
    replyLoader.value = true;
    Map<String,dynamic> map = {
      'driver_id' : await secure.readData(secure.user_id)??"",
      'message' : message,
      'complain_number' : complain_number,
    };

    try{

      final response = await apiService.postData(URLS.THREAD_REPLY_Come, map);

      var jsonString = jsonDecode(response.body);

      log(" reply query response -----$jsonString");

      if(jsonString['result'] == "successfully"){
        Get.back();
        customSnackBar("Reply sent successfully");
        fetchSingleQueryCom(complain_number,"hii");
      }else{
        customSnackBar("something went wrong");
      }

      replyLoader.value = false;
    }catch(e){
      replyLoader.value = false;
      log("close Query Exception ---",error: e.toString());
    }

  }

}