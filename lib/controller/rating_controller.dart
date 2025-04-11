import 'dart:developer';

import 'package:get/get.dart';

import '../../Network/api_service.dart';
import '../../Network/urls.dart';

import '../Model/rating_model.dart';
import '../utils/shared_preferences.dart';


class RatingController extends GetxController {

  var isLoading = false.obs;
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


}