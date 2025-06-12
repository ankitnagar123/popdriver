import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../Network/api_service.dart';
import '../../Network/urls.dart';

import '../Model/rating_model.dart';
import '../utils/shared_preferences.dart';
import '../utils/snackBar.dart';


class RatingController extends GetxController {

  var isLoading = false.obs;
  var addLoading = false.obs;
  SecureStorageService secure = SecureStorageService();
 ApiService apiService = ApiService();

 var ratingList = Rxn<RatingModel>();

 SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

 void rating()async {
   isLoading.value = true;
   Map<String,dynamic> map = {
     'driver_id'  : await secure.readData(secure.user_id)
   };
   
   try{

     final response = await apiService.postData(URLS.DRIVER_RATING, map);

     log("response-------->:${response.body}");
     ratingList.value = ratingModelFromJson(response.body);
     isLoading.value = false;

   }catch(e){
     isLoading.value = false;
     log("Exception-------",error: e.toString());
   }

 }

  Future<void> rateToUser(String bookingId ,rating,positive_point,negative_point,BuildContext context) async {
    addLoading.value = true;

    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id),
      "booking_id":bookingId,
      "rating":rating,
      "positive_point":positive_point,
      "negative_point":negative_point,
    };
    log("Rate User  Check: $map");

    try {
      final response = await apiService.postDatatoken(URLS.RATINGTOUSER, map);
      var jsonString = jsonDecode(response.data);
      log("Rate  Response Check: ${jsonString['result']}");

      if (jsonString['result'] == "success") {
        Navigator.pop(context);
        customSnackBar("✅ Rate successful!");

      } else {
        var jsonString = jsonDecode(response.data);

        customSnackBar(jsonString['result'].toString());
      }
    } catch (e) {
      log("Exception during payment status check", error: e.toString());
      customSnackBar("❌ Error checking payment status.");
    } finally {
      addLoading.value = false;
    }
  }



}