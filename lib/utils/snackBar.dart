import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'colors.dart';

void customSnackBar(String? message, {BuildContext? context}) {
  if (message == null || message.isEmpty) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _showSnackBar(message, context: context);
  });
}

void _showSnackBar(String message, {BuildContext? context}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
    ),
    backgroundColor: MyColors.black,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    duration: const Duration(seconds: 2),
  );

  BuildContext? targetContext = context;
  if (targetContext != null && !targetContext.mounted) {
    targetContext = null;
  }
  targetContext ??= Get.overlayContext ?? Get.context;

  if (targetContext != null) {
    try {
      final messenger = ScaffoldMessenger.maybeOf(targetContext);
      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(snackBar);
        return;
      }
    } catch (e) {
      debugPrint('ScaffoldMessenger snackbar failed: $e');
    }
  }

  try {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: MyColors.black,
      borderRadius: 10,
      duration: const Duration(seconds: 2),
      maxWidth: Get.width / 1.1,
      message: message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    ));
  } catch (e) {
    debugPrint('Snackbar failed: $message ($e)');
  }
}
