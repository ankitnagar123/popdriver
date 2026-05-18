import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'colors.dart';

void customSnackBar(String? message){
  if (message != null && message.isNotEmpty) {
    // Prevent GetX snackbar crashes when no Overlay/Navigator is ready.
    final hasOverlay = Get.overlayContext != null;
    if (!hasOverlay) {
      debugPrint("Snackbar skipped (no overlay): $message");
      return;
    }
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
