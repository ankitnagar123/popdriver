import 'dart:async';

import '../../../controller/booking_controller.dart';
import '../../../utils/web_auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadyForRide extends StatefulWidget {
  const ReadyForRide({Key? key}) : super(key: key);

  @override
  State<ReadyForRide> createState() => _ReadyForRideState();
}

class _ReadyForRideState extends State<ReadyForRide> {
  BookingController controller = Get.find<BookingController>();

  @override
  void initState() {
    super.initState();
    controller.rideNowBooking();
    Timer(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = WebAuthLayout.isWide(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: wide ? 420 : double.infinity,
              ),
              child: Image.asset(
                'assets/images/readforride.png',
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
