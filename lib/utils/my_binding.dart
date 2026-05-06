import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

import '../controller/auth_controller.dart';
import '../controller/booking_controller.dart';
import '../controller/home_screen_controller.dart';
import '../controller/my_ride_controller.dart';
import '../controller/permision_controller.dart';

class MyBinding extends Bindings {
  @override
  void dependencies() {
    try {
      Get.put(AuthController());
      Get.put(MyRidesController());
      Get.put(HomeController());
      Get.put(BookingController());
      Get.put(PermissionController());
    } catch (e) {
      print("Error initializing controllers in binding: $e");
      // Re-throw to ensure the error is visible
      rethrow;
    }
  }
}
