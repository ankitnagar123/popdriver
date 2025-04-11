import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'colors.dart';

void customSnackBar(String? message){
  if (message != null && message.isNotEmpty) {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: MyColors.black,
      borderRadius: 10,
      duration: Duration(seconds: 2),
      maxWidth: Get.width/1.1,
      message: message,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 20),
    ));
  }
}
