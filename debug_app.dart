// Debug script to test app initialization
// Run this with: flutter run debug_app.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'lib/main.dart';

void main() {
  print("Starting debug mode...");

  // Test controller initialization
  try {
    print("Testing GetX initialization...");
    Get.testMode = true;
    print("GetX test mode enabled");
  } catch (e) {
    print("Error with GetX: $e");
  }

  // Run the main app
  main();
}
