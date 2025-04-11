
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtaanidriver/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';

import 'View/AuthScreen/splace_screen.dart';
import 'controller/permision_controller.dart';


class LocationPermissionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Permission'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset(
              "assets/images/location.png", height: 200, width: 150,)),
            Center(
              child: Text(
                "To provide you with the best experience, we need access to your device's location. Please grant us permission to access your location.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        child: ElevatedButton(
          style: ButtonStyle(
              minimumSize: MaterialStatePropertyAll(
                Size(50, 50),
              ),
              backgroundColor: MaterialStatePropertyAll(MyColors.primary)
          ),
          onPressed: () {
            requestLocationPermission(context);
          },
          child: Obx(() {
            return  Get.find<PermissionController>().permission.value == true?
              Text('Next', style: TextStyle(fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black),):
              Text('Request Permission', style: TextStyle(fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black),);
          }),
        ),
      ),
    );
  }

  void requestLocationPermission(BuildContext context) async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted, navigate to next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } else if (status.isDenied) {
      // Permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission denied.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location permission is permanently denied. Please enable it from settings.'),
          duration: Duration(seconds: 3),
        ),
      );
      Get.find<PermissionController>().permission.value = true;
      await openAppSettings();
    }
  }
}


class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: Text(
            'You are on the next page after granting location permission.'),
      ),
    );
  }
}
