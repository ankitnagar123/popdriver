import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/driver_location_settings.dart';
import '../utils/platform_helper.dart';
import 'home_screen_controller.dart';

class PermissionController extends GetxController{

  var  mapInitialLocation = LatLng(0.0, 0.0).obs;
  var permission = false.obs;
  StreamSubscription? mapSubscription;


  @override
  void onInit() {
    super.onInit();
    mapSubscription = mapInitialLocation.listen((location) {
      Get.find<HomeController>().updateCameraPosition(location);
    });
  }

  Future<void> permissionHandle()async{
    if (kIsWeb || isWeb) return;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
      Permission.photos,
      Permission.notification,

      //add more permission to request here.
    ].request();

    if(statuses[Permission.storage]!.isDenied){
      await Permission.storage.request();//check each permission status after.
      print("storage permission is denied.");
    }
    if(statuses[Permission.photos]!.isDenied){ //check each permission status after.
      print("Photos permission is denied.");
    }
    if(statuses[Permission.notification]!.isDenied){ //check each permission status after.
      print("Notification permission is denied.");
    }

    if(statuses[Permission.camera]!.isDenied){ //check each permission status after.
      print("Camera permission is denied.");
    }
  }


  Future<void> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await getDriverPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      mapInitialLocation.value = latLng;
      final home = Get.find<HomeController>();
      home.applyLivePosition(position, recenterMap: true);
      log("currentLat------>:${mapInitialLocation.value} accuracy:${position.accuracy}m");
    } catch (e) {
      log('getCurrentPosition failed: $e');
    }
  }
}


