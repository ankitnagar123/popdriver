import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController with WidgetsBindingObserver {
  var appLifecycleState = AppLifecycleState.resumed.obs;
  var isContentVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("state ----$state");
    appLifecycleState.value = state;
    if (state == AppLifecycleState.resumed) {
      isContentVisible.value = true;
    } else {
      isContentVisible.value = false;
    }
  }
}