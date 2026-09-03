import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get/get.dart';
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import 'package:flutter/material.dart';
import '../Model/notification_model.dart';
import '../Model/vehicle_fetch_model.dart';
import '../Network/urls.dart';
import '../utils/shared_preferences.dart';
import '../utils/snackBar.dart';
import 'package:dio/dio.dart'as DIO;

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../Network/urls.dart';
import 'auth_controller.dart';


class VehicleController extends GetxController{
  
  DIO.Dio dioClient = DIO.Dio();
  var status = "".obs;

  var selectedIndex = RxnInt(-1);
  RxString CarId = "".obs;
  var vehicleFetchLoader = false.obs;
  var vehicleDetailLoader = false.obs;

  ApiService apiService = ApiService();

  AuthController con = AuthController();
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

  var vehicleList = <VehicleFetchModel>[].obs;
  final selectedCarId = ''.obs;


  void fetchVehicle()async{
    vehicleFetchLoader.value = true;
   try{

     final response = await apiService.getData(URLS.VEHICLE_FETCH);
     log("vehicle fetch response -------${response.data}");
     vehicleList.value = vehicleFetchModelFromJson(
       response.data is String ? response.data : json.encode(response.data),
     );

     // vehicleList.value = vehicleFetchModelFromJson(response.data);
     vehicleFetchLoader.value = false;
   }catch(e){
     vehicleFetchLoader.value = false;
     log("Exception -----",error: e.toString());
   }
  }

}