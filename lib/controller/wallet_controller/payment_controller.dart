
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Model/fetch_cart_model.dart';
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/snackBar.dart';

class PaymentController extends GetxController{

  var addLoader = false.obs;
  var fetchLoader = false.obs;
  var deleteLoader = false.obs;

  var cardList = <FetchCardModel>[].obs;

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  ApiService apiService = ApiService();
  SecureStorageService secure = SecureStorageService();

  void addCard(context,String holderName,String cvv,String expiryDate ,String cardNumber)async{
    addLoader.value  = true;
    Map<String,dynamic> addCard = {
      'driver_id'   : await secure.readData(secure.user_id),
      'card_number' : cardNumber,
      'card_holdername' : holderName,
      'card_cvv'        : cvv,
      'card_expiredate' : expiryDate
    };

    log("add parameter------>:$addCard");

    try{

      final response = await apiService.postData(URLS.ADD_DRIVER_CARD, addCard);
      var jsonString =  jsonDecode(response.body);
      var result = jsonString['result'];

      if(result == "success"){
        addLoader.value = false;
        customSnackBar("Card Added Successfully");
        Navigator.of(context).pop();
        fetchCart();
      }else{
        addLoader.value = false;
        customSnackBar(result.toString());
      }

    }catch(e){
      addLoader.value = false;
      log("Exception---",error: e.toString());
    }

  }

  void fetchCart()async{
    fetchLoader.value = true;
    Map<String,dynamic> map = {
      'driver_id'  : await secure.readData(secure.user_id),
    };

    try{

      final response = await apiService.postData(URLS.FETCH_DRIVER_CARD, map);

      log("fetch card response --- ->:${response.body}");

      cardList.value = fetchCardModelFromJson(response.body);
      fetchLoader.value = false;

    }catch(e){
      fetchLoader.value = false;
      log('Exception-----',error: e.toString());
    }

  }

  void deleteCard(context,String cardId,)async{
    deleteLoader.value  = true;
    Map<String,dynamic> deleteCard = {
      'driver_id'   : await secure.readData(secure.user_id),
      'card_id' : cardId,
    };

    log("add parameter------>:$deleteCard");

    try{

      final response = await apiService.postData(URLS.DELETE_DRIVER_CARD, deleteCard);
      var jsonString =  jsonDecode(response.body);
      var result = jsonString['result'];

      if(result == "success"){
        deleteLoader.value = false;
        customSnackBar("Card deleted Successfully");
        fetchCart();
      }else{
        deleteLoader.value = false;
        customSnackBar(result.toString());
      }

    }catch(e){
      deleteLoader.value = false;
      log("Exception---",error: e.toString());
    }

  }


}