import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import 'package:flutter/material.dart';
import '../Model/notification_model.dart';
import '../Network/urls.dart';
import '../utils/shared_preferences.dart';
import '../utils/snackBar.dart';
import '../Model/fetchQueryModel.dart';
import '../Model/fetch_single_query.dart';


class SupportController extends GetxController{
  SecureStorageService secure = SecureStorageService();
  var writeSupportLoader = false.obs;
  var  fetchQueryLoader = false.obs;
  var fetchQueryList = <FetchQueryModel>[].obs;
  var fetchSingleQueryList = <FetchSingleQueryModel>[].obs;
  var fetchSingleQueryLoader = false.obs;
  var closeQueryLoader = false.obs;
  var replyLoader = false.obs;


ApiService apiService = ApiService();

SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

  void writeSupport(BuildContext context,String email,String subject,String message)async{
  writeSupportLoader.value = true;
  Map<String, dynamic> map = {

  "driver_id":await secure.readData(secure.user_id),
  "email":email,
  "subject":subject,
  'message':message
  };

  log('parameter------>:$map');

  try{

    final response = await apiService.postData(URLS.DRIVER_SUPPORT, map);

    var jsonString = jsonDecode(response.body);
    log("response------->$jsonString");

    if(jsonString['result']=='successfully'){
      customSnackBar('support submitted'.tr);
      fetchQuery("fetch");
     /* Navigator.of(context).pop();*/
      writeSupportLoader.value = false;
    }else{
      writeSupportLoader.value = false;
      customSnackBar('something went wrong'.tr);
    }
  }catch(e){
    writeSupportLoader.value = false;
    log("Exception-----",error: e.toString());
  }
}

  void fetchQuery(String status)async{
    if(status == ""){
      fetchQueryLoader.value = true;
    }
    Map<String,dynamic> map = {
      'driver_id' : await secure.readData(secure.user_id)??"",
    };

    try{

      final response = await apiService.postData(URLS.FETCH_QUERY, map);

      log(" fetch query response -----${response.body}");

      fetchQueryList.value = fetchQueryModelFromJson(response.body);
      fetchQueryLoader.value = false;
    }catch(e){
      fetchQueryLoader.value = false;
      log("fetch Query Exception ---",error: e.toString());
    }

  }

  void fetchSingleQuery(String complain_number,String status)async{
    if(status == ""){
      fetchSingleQueryLoader.value = true;
    }

    Map<String,dynamic> map = {
      'driver_id' : await secure.readData(secure.user_id)??"",
      'complain_number' : complain_number,
    };

    try{

      final response = await apiService.postData(URLS.SINGLE_QUERY, map);

      log(" single query response -----${response.body}");

      fetchSingleQueryList.value = fetchSingleQueryModelFromJson(response.body);
      fetchSingleQueryLoader.value = false;
    }catch(e){
      fetchSingleQueryLoader.value = false;
      log("single Query Exception ---",error: e.toString());
    }

  }

  void closeTicket(String complain_number)async{
    closeQueryLoader.value = true;
    Map<String,dynamic> map = {
      'driver_id' : await secure.readData(secure.user_id)??"",
      'complain_number' : complain_number,
    };

    try{

      final response = await apiService.postData(URLS.CLOSE_TICKET, map);

      var jsonString = jsonDecode(response.body);

      log(" close query response -----$jsonString");

      if(jsonString['result'] == "successfully"){
        Get.back();
        customSnackBar("Ticket Closed");
        fetchQuery("fetch");

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

      final response = await apiService.postData(URLS.THREAD_REPLY, map);

      var jsonString = jsonDecode(response.body);

      log(" reply query response -----$jsonString");

      if(jsonString['result'] == "successfully"){
        Get.back();
        customSnackBar("Reply sent successfully");
        fetchSingleQuery(complain_number,"hii");
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