import 'dart:async';
import 'dart:developer';
import 'dart:io';
import '../../controller/permision_controller.dart';
import '../../controller/splace_controller.dart';
import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/shared_preferences.dart';
import '../../controller/auth_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:root_check/root_check.dart';

class SplashScreen extends StatefulWidget {
   SplashScreen({Key? key,}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  SecureStorageService secure = SecureStorageService();
  PermissionController controller = Get.find<PermissionController>();
  AuthController controllers = Get.find<AuthController>();
  SplashController splashController = Get.put(SplashController());
  static const platform = MethodChannel('com.taxi.columbia/developer_mode');
  bool _isDeveloperModeOn = false;

  @override
  void initState() {
    super.initState();
    /*requestLocationPermission();*/
    /*controllers.sendEncryptedData("12", "vishnu", "vishnuprajapati6131@gmail.com")*/
   if(Platform.isAndroid){
     if (kReleaseMode) {
       _checkDeveloperMode();
     } else {
       requestLocationPermission();
     }
   }else{
     requestLocationPermission();
   }

    /*  getData();*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Center(child: Image.asset("assets/images/logo.png",height: 220,))
            ],
          ),
        )
    
    );
  }

  Future<void> _checkDeveloperMode() async {
    if (Platform.isAndroid) {
      var deviceInfo = DeviceInfoPlugin();
      var androidInfo = await deviceInfo.androidInfo;
      bool isDeveloperModeEnabled = false;

      try {
        final bool result = await platform.invokeMethod('isDeveloperModeEnabled');
        isDeveloperModeEnabled = result;
      } on PlatformException catch (e) {
        print("Failed to check developer mode: '${e.message}'.");
      }

      setState(() {
        _isDeveloperModeOn = androidInfo.isPhysicalDevice && isDeveloperModeEnabled;
      });

      bool isRooted = await RootCheck.isRooted??false;
      bool hasRootDirectories = await checkRootDirectories();

      if (_isDeveloperModeOn) {
        _showDeveloperModeAlert();
      } else if(isRooted || hasRootDirectories){
        handleRootDetection();
      }else {
        requestLocationPermission();
      }
    }
  }
  Future<void> _openDeveloperOptions() async {
    try {
      await platform.invokeMethod('openDeveloperOptions');
    } on PlatformException catch (e) {
      print("Failed to open developer options: '${e.message}'.");
    }
  }
  void _showDeveloperModeAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Turn of USB debugging"),
          content: Text("USB debugging mode seems to be active on your phone. This makes your device vulnerable to data theft"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                SystemNavigator.pop();
                _openDeveloperOptions(); // Developer options settings page kholta hai
              },
            ),
          ],
        );
      },
    );
  }

  void handleRootDetection() {

    // Show an alert or prevent app functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rooted Device Detected'),
          content: Text('Your device is rooted. This app cannot run on rooted devices for security reasons.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Handle app exit or restricted functionality
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

  }


  void requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted, proceed to get data
      getData();
      controller.getCurrentPosition();
      controller.permissionHandle();
    } else if (status.isDenied) {
      requestLocationPermission();
    } else if (status.isPermanentlyDenied) {
      Get.snackbar('', "Location permission is permanently denied. Please enable it from settings.",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offNamed(RouteHelper.getLocationPermissionPageScreen());
    }
  }

  void getData() async {
    log("OnBoarding key ------>:${await sp.getBoolValue(sp.ON_BOARDING_KEY)}");
    log("Language key ------>:${await sp.getStringValue(sp.LANGUAGE)}");
    log("secure key ------>:${await secure.readData(secure.user_id)}");
   controllers.updateDeviceId();
    if (await sp.getStringValue(sp.LANGUAGE) == "en_US") {
      Get.updateLocale(Locale('en', 'US'));
    }else{
      var local = Locale('es', 'ES');
      sp.setStringValue(sp.LANGUAGE, local.toString());
    }
    if (await sp.getBoolValue(sp.ON_BOARDING_KEY) != true)
    {
      Timer(const Duration(seconds: 3), () {
        Get.offNamed(RouteHelper.getOnBoardingScreenRoute());
      }
      );
    }
    else if (await sp.getBoolValue(sp.LOGIN_KEY) != true)
    {
      Timer(const Duration(seconds: 3), () {
        Get.offNamed(RouteHelper.getLoginScreenRoute());
      }
      );
    }
    else {
      Timer(const Duration(seconds: 3), () {
        Get.offNamed(RouteHelper.getHomeScreenScreenRoute(),
            arguments: {"ArriveDriver": ""});
      });
    }
  }

  Future<bool> checkRootDirectories() async {
    final List<String> rootPaths = [
      '/system/xbin/su',
      '/system/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
      '/sbin/su',
      '/system/app/Superuser.apk',
      '/system/xbin/daemonsu',
    ];

    for (String path in rootPaths) {
      if (await File(path).exists()) {
        return true;
      }
    }
    return false;
  }

}
