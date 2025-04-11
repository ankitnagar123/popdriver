import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

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
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    mapInitialLocation.value = LatLng(position.latitude, position.longitude);
    log("currentLat------>:${mapInitialLocation.value}");

  }
}


