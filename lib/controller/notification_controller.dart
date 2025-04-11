import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get/get.dart';
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import 'package:flutter/material.dart';
import '../Model/notification_model.dart';
import '../Network/urls.dart';
import '../utils/shared_preferences.dart';
import '../utils/snackBar.dart';

class NotificationController extends GetxController{

  SecureStorageService secure = SecureStorageService();

  var notificationLoader = false.obs;
  var notificationLoader1 = false.obs;
  var notificationDeleteLoader = false.obs;
  ApiService apiService = ApiService();
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

  var notificationList = <NotificationModel>[].obs;


  void notification(String status)async{
    if(status == ""){
      notificationLoader.value = true;
    }else{
      notificationLoader1.value = true;
    }

    Map<String,dynamic> notification = {
      'driver_id'  : await secure.readData(secure.user_id),
    };
    
    try{
      
      final response = await apiService.postData(URLS.DRIVER_NOTIFICATION, notification);

      log('Notification response--------->:${response.body}');

      notificationList.value = notificationModelFromJson(response.body);

      notificationLoader.value = false;
      notificationLoader1.value = false;

    }catch(e){
      notificationLoader.value = false;
      notificationLoader1.value = false;
      log("Exception-----",error: e.toString());
    }

  }

  void deleteNotification(String notificationId)async{
    notificationDeleteLoader.value = true;
    Map<String,dynamic> delete = {
      "driver_id" : await secure.readData(secure.user_id),
      "notification_id" : notificationId
    };

    try{

      final response = await apiService.postData(URLS.DRIVER_NOTIFICATION_DELETE, delete);

      var jsonString = jsonDecode(response.body);

      log("delete notification-------->:$jsonString");

      if(jsonString['result'] == "Update successfully"){
        notificationDeleteLoader.value = false;
        Navigator.of(Get.context!).pop();
        notification("delete");
        customSnackBar("Notification Deleted");
      }else{
        notificationDeleteLoader.value = false;
        customSnackBar("Something Went Wrong".tr);
      }

    }catch(e){
      notificationDeleteLoader.value = false;
    }
  }




}