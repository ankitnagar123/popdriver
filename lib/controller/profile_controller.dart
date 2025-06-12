import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:get/get.dart';
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import 'package:flutter/material.dart';
import '../Model/notification_model.dart';
import '../Network/urls.dart';
import '../utils/colors.dart';
import '../utils/shared_preferences.dart';
import '../utils/snackBar.dart';

import 'package:get/get.dart';
import '../Network/urls.dart';
import 'package:dio/dio.dart'as DIO;

class ProfileController extends GetxController{

  var imageString = Rxn<File>();
  SecureStorageService secure = SecureStorageService();

  DIO.Dio  dioClient = DIO.Dio();

  var fetchDetailLoader = false.obs;
  var updateDetailLoader = false.obs;
  var updateImageLoader = false.obs;

  var changePasswordLoader = false.obs;



  var Name = "".obs;
  var Email = "".obs;
  var lastName = "".obs;
  var Contact = "".obs;
  var CountryCode = "".obs;
  var flags = "".obs;
  var Image = "".obs;
  var licenceImage = "".obs;
  var licenceDate = "".obs;
  var fitnessImage = "".obs;
  var fitnessExpiry = "".obs;
  var registrationImage = "".obs;
  var registrationDate = "".obs;
  var insuranceImage = "".obs;
  var insuranceDate = "".obs;
  var IdProofImage = "".obs;
  var IdProofExpiry = "".obs;
  var vehiclemake = "".obs;
  var vehicleModel = "".obs;
  var year = "".obs;
  var color = "".obs;
  var carId = "".obs;
  var identityNo = "".obs;
  var resultVar = RxnInt(0);

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  ApiService apiService = ApiService();

  void fetchDriverDetail()async{
    resultVar.value = 0;
    fetchDetailLoader.value = true;
    Map<String, dynamic> fetchDetail = {
      "driver_id"  : await secure.readData(secure.user_id),
    };
    log("driver detail fetch parameter-----$fetchDetail");
    try{

      final response = await apiService.postData(URLS.DRIVER_FETCH_DETAIL, fetchDetail);
      var jsonString = jsonDecode(response.body);
      log("drive detail response ------$jsonString");
      var result = jsonString['result'];
      if(result == "successfully"){

        String image = jsonString["Image"].toString();
        String name = jsonString["first_name"].toString();
        String lastname = jsonString["last_name"].toString();
        String email = jsonString["email"].toString();
        String country = jsonString["country_code"].toString();
        String flag = jsonString["flag"].toString();
        String contact = jsonString["contact"].toString();
        String licenceimage = jsonString["licence_image"].toString();
        String licencedate = jsonString["expiry_date"].toString();
        String registrationimage = jsonString["identity_image"].toString();
        String registrationdate = jsonString["identity_expiry_date"].toString();
        String fitnessimage = jsonString["rc_image"].toString();
        String fitnessdate = jsonString["rc_expiry_date"].toString();
        String insuranceimage = jsonString["insurance_image"].toString();
        String insurancedate = jsonString["insurance_expiry_date"].toString();
        String idimage = jsonString["id_proof_image"].toString();
        String idExpirydate = jsonString["id_expiry_date"].toString();
        String make = jsonString["vehicle_make"].toString();
        String model = jsonString["vehicle_number"].toString();
        String vehicle_year = jsonString["vehicle_year"].toString();
        String vehicle_colour = jsonString["vehicle_colour"].toString();
        String car_id = jsonString["car_id"].toString();
        String invite = jsonString["invite_code"].toString();
        String walletAmount = jsonString["wallet_amount"].toString();
        String inviteUrl = jsonString["invite_url"].toString();
        String membership_id = jsonString["membership_id"].toString();
        String membership_status = jsonString["membership_description"].toString();
        String member_expiry_date = jsonString["member_expiry_date"].toString();
        String membership_type = jsonString["membership_type"].toString();
        String membership_commission = jsonString["membership_commission"].toString();
        String identity_no = jsonString["identity_no"].toString();


        Image.value = image;
        Name.value = name;
        Email.value = email;
        lastName.value = lastname;
        CountryCode.value = country;
        flags.value = flag;
        licenceImage.value = licenceimage;
        licenceDate.value = licencedate;
        registrationImage.value = registrationimage;
        registrationDate.value = registrationdate;
        fitnessImage.value = fitnessimage;
        fitnessExpiry.value = fitnessdate;
        insuranceImage.value = insuranceimage;
        insuranceDate.value = insurancedate;
        IdProofImage.value = idimage;
        IdProofExpiry.value = idExpirydate;
        Contact.value = contact;
        vehiclemake.value = make;
        year.value = vehicle_year;
        vehicleModel.value = model;
        color.value = vehicle_colour;
        carId.value = car_id;
        identityNo.value = identity_no;
        MyColors.InviteCode = invite;
        MyColors.walletAmount = walletAmount;
        MyColors.name = "$name $lastname";
        MyColors.email = email;
        MyColors.phone = country+contact;
        MyColors.image = image;
        MyColors.InviteUrl = inviteUrl;
        MyColors.MemberShipId = membership_id;
        MyColors.MemberShipStatus = membership_status;
        MyColors.MemberShipType = membership_type;
        MyColors.MemberShipExpiry = member_expiry_date;
        MyColors.MemberShipCommision = membership_commission;

        log("memberShip_id--------->$membership_id");
        log("licenceExpiry--------->$licencedate");
        log("MyColors.InviteCode--------->${MyColors.InviteCode}");

        secure.writeData(secure.user_name, Name.value+" "+lastName.value);
        fetchDetailLoader.value = false;
        resultVar.value = 1;

      }else{
        resultVar.value = 2;
        fetchDetailLoader.value = false;
        customSnackBar(result.toString());
      }

    }catch(e){
      resultVar.value = 2;
      fetchDetailLoader.value = false;
      log("Exception ----",error: e.toString());
    }
  }

/*  void updateDriveDetail(String name,String lastName,String email,
      String contact,String currentPass,String newPass,String countryCode,String flag,
      String vehicle_name,String vehicle_number,String year,String colour,String expiry_date_lic,
      String identity_expiry_date, String rc_expiry_date,String insurance_expiry_date,
      File? fitness, File? identity,
      File? licence, File? insurance,
      File?idProofImage,String idExpiryDate,
      String car_id,
      VoidCallback callback)async{
    updateDetailLoader.value = true;
    DIO.FormData update = DIO.FormData.fromMap({
      'driver_id'             : await secure.readData(secure.user_id),
      'first_name'            : name,
      'last_name'             : lastName,
      'country_code'          : countryCode,
      'contact'               : contact,
      'email'                 : email,
      'current_password'      : currentPass,
      'new_password'          : newPass,
      "country_flag"          : flag,
      "vehicle_name"          : vehicle_name,
      "vehicle_number"        : vehicle_number,
      "car_id"                : car_id,
      "year"                  : year,
      "colour"                : colour,
      "expiry_date_lic"       : expiry_date_lic,
      "identity_expiry_date"  : identity_expiry_date,
      "rc_expiry_date"        : rc_expiry_date,
      "id_expiry_date"        : idExpiryDate,
      "insurance_expiry_date" : insurance_expiry_date,
      "rc_image"              : fitness?.path == null? "" :await DIO.MultipartFile.fromFile(fitness!.path,filename: fitness.path.split("/").last),
      "identity_image"        :identity?.path == null? "" :await DIO.MultipartFile.fromFile(identity!.path,filename: identity.path.split("/").last),
      "license_image"         : licence?.path == null? "" :await DIO.MultipartFile.fromFile(licence!.path,filename: licence.path.split("/").last),
      "insurance_image"       : insurance?.path == null? "" :await DIO.MultipartFile.fromFile(insurance!.path,filename: insurance.path.split("/").last),
      "id_proof_image"        : idProofImage?.path == null? "" :await DIO.MultipartFile.fromFile(idProofImage!.path,filename: idProofImage.path.split("/").last),
    });

    log("parameter ------${update.fields}");

    try{

      final response = await apiService.multiPartFile(URLS.DRIVER_UPDATE_DETAIL, update);
      var jsonString =  jsonDecode(response.data);
      log("response ------$jsonString");
      var result = jsonString['result'];
      if(result == "successfully update"){
        updateDetailLoader.value = false;
        customSnackBar("Successfully Updated".tr);
        callback();
        fetchDriverDetail();
      }else{
        updateDetailLoader.value = false;
        customSnackBar(result.toString().tr);
      }

    }catch(e){
      updateDetailLoader.value = false;
     log("Exception-----",error: e.toString());
    }
  }*/

  void driverProfileUpdate(
      String vehicleId,
      String vehicleNames,
      String firstName,
      String lastName,
      String countryCode,
      String flag,
      String contact,
      String email,
      VoidCallback callback
      ) async {
    updateDetailLoader.value = true;

    Map<String, dynamic> map = {
      "driver_id":  await secure.readData(secure.user_id) ,
      "car_id": vehicleId,
      "vehicle_number": vehicleNames,
      "first_name": firstName,
      "last_name": lastName,
      "country_code": countryCode,
      "contact": contact,
      "email":email,
      "country_flag": flag,
    };
    log("driver Profile Update  parameter ------>:$map");

    try {
      final response = await apiService.postData(URLS.DRIVER_UPDATE_DETAIL, map);

      var jsonString = jsonDecode(response.body);
      log("driver Profile Update response----->:$jsonString");
      if (jsonString['result'] == "successfully update") {
        updateDetailLoader.value = false;
        callback();
        fetchDriverDetail();
        callback();
      } else {
        updateDetailLoader.value = false;
        customSnackBar(jsonString['result'].toString());
      }
    } catch (e) {
      updateDetailLoader.value = false;
      log("Exception--------", error: e.toString());
    }
  }



  Future<void> changePassword(
      String current_password, new_password, VoidCallback call) async {
    changePasswordLoader.value = true;

    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id),
      "current_password": current_password,
      "new_password": new_password,
    };
    log("password change Params: $map");

    try {
      final response =
      await apiService.postDatatoken(URLS.DRIVER_UPDATE_PASSWORD, map);
      var jsonString = jsonDecode(response.data);
      log("password change Response: ${jsonString['result']}");

      if (jsonString['result'] == "successfully update") {
        call();
      } else {
        customSnackBar("⚠️ ${jsonString['result']}");
      }
    } catch (e) {
      customSnackBar("❌ Error updating password.");
    } finally {
      changePasswordLoader.value = false;
    }
  }



  void updateDriverProfile(File? file)async{
    updateImageLoader.value = true;

    DIO.FormData formData = DIO.FormData.fromMap({

      "driver_id"  : await secure.readData(secure.user_id),
      "image"      : await DIO.MultipartFile.fromFile(file!.path,filename: file.path.split("/").last)
    });

    log("parameter ------ ${formData.files}");
    
    try{
      final response = await apiService.multiPartFile(URLS.DRIVER_UPDATE_PROFILE_IMAGE, formData);
      var jsonString = jsonDecode(response.data);
      log("response --------$response");
      var result = jsonString["result"];
      if(result == "successfully update"){
        updateImageLoader.value = false;
        customSnackBar("successfully Updated".tr);
        fetchDriverDetail();
      }else{
        updateImageLoader.value = false;
        customSnackBar("Something Went Wrong".tr);
      }

    }catch(e){
      updateImageLoader.value = false;
      log("Exception-----",error: e.toString());
    }
  }
}