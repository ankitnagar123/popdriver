import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import '../../Model/fetch_cart_model.dart';
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/snackBar.dart';
import 'package:get/get.dart';
import '../Model/message_fetch_model.dart';
import '../Network/urls.dart';

class MessageController  extends GetxController{
  SecureStorageService secure = SecureStorageService();



  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

  ApiService apiService = ApiService();

  var messageList = <MessageFetchModel>[].obs;



 void sendMessage( String receiverId, String massage,VoidCallback callback) async {
    final Map<String, dynamic> map = {
      'send_id': await secure.readData(secure.user_id),
      'user_id': receiverId,
      'message': massage
    };
    log('parameter=======>:$map');
    try {
      final response = await apiService.postData(URLS.SEND_MESSAGE,map );
      var jsonString = jsonDecode(response.body);
      log('response========>:$jsonString');
      var result = jsonString['result'];
      if (result == 'success') {
        print('message sent success');
        callback();
      }
    } catch (e) {
      log('Exception--------->:$e');
    }
  }


  void chatFetch( String receiverId,) async {
    final Map<String, dynamic> map = {
      'send_id': await  secure.readData(secure.user_id)??"",
      'user_id': receiverId
    };
    print('parameter------->:$map');

    try {
      final response = await apiService.postData(URLS.FETCH_MESSAGE, map);
        log('response------>:${response.body}');
        messageList.value = messageFetchModelFromJson(response.body);
        update();
    } catch (e) {
      log('Exception------->:$e');
    }
  }

}