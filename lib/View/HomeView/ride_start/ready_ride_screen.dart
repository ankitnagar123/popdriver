import 'dart:async';


import '../../../controller/auth_controller.dart';
import '../../../controller/booking_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/home_screen_controller.dart';

class ReadyForRide extends StatefulWidget {
  const ReadyForRide({Key? key}) : super(key: key);

  @override
  State<ReadyForRide> createState() => _ReadyForRideState();
}

class _ReadyForRideState extends State<ReadyForRide> {
  BookingController controller = Get.find<BookingController>();

  @override
  void initState() {
    controller.rideNowBooking();
    Timer(Duration(seconds: 3), () {
      Get.find<HomeController>().selectedValueIndex.value = 0;
      Navigator.of(context).pop();
    });

    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/images/readforride.png',
        height: Get.height,
        width: Get.width,
        fit: BoxFit.fill,
      ));

  }
}
