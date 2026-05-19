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

  Future<bool> writeSupport(
    BuildContext context,
    String email,
    String subject,
    String message,
  ) async {
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

    if (jsonString['result'] == 'successfully') {
      customSnackBar('support submitted'.tr);
      fetchQuery('refresh');
      writeSupportLoader.value = false;
      return true;
    }
    writeSupportLoader.value = false;
    customSnackBar('something went wrong'.tr);
    return false;
  } catch (e) {
    writeSupportLoader.value = false;
    log('Exception-----', error: e.toString());
    return false;
  }
}

  /// [showBlockingLoader] — only true when a full-screen loader is intended.
  /// Write Support loads tickets in the background without blocking the form.
  void fetchQuery(String status, {bool showBlockingLoader = false}) async {
    if (showBlockingLoader || status == 'refresh') {
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

  Future<void> fetchSingleQuery(String complain_number, String status) async {
    if (status.isEmpty) {
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

  Future<bool> replyThread(String complain_number, String message) async {
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

      if (jsonString['result'] == 'successfully') {
        customSnackBar('Reply sent successfully'.tr);
        fetchSingleQuery(complain_number, 'poll');
        replyLoader.value = false;
        return true;
      }
      customSnackBar('something went wrong'.tr);
      replyLoader.value = false;
      return false;
    } catch (e) {
      replyLoader.value = false;
      log('replyThread Exception ---', error: e.toString());
      return false;
    }
  }

}