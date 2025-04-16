import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart'as DIO;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtaanidriver/controller/home_screen_controller.dart';
import 'package:mtaanidriver/utils/shared_preferences.dart';
import 'package:mtaanidriver/utils/snackBar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SelfieController extends GetxController {
  late CameraController cameraController;
  Rx<File?> capturedImage = Rx<File?>(null);
  RxBool isCameraInitialized = false.obs;

  Future<void> initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      Get.snackbar("Permission Denied", "Camera permission is required");
      return;
    }

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    cameraController = CameraController(frontCamera, ResolutionPreset.high);
    await cameraController.initialize();
    isCameraInitialized.value = true;
  }

  final SecureStorageService secure = SecureStorageService();
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();


  var sendSelfieLoader = true.obs;
  var sendSelfieLoader1 = false.obs;


  DIO.Dio dioClient = DIO.Dio();

  Future<void> captureSelfie() async {
    if (!cameraController.value.isInitialized) return;

    final directory = await getTemporaryDirectory();
    final filePath = join(directory.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");
    await cameraController.takePicture().then((XFile file) {
      capturedImage.value = File(file.path);
    });
  }


  void selfieUpload(VoidCallback callback) async {
    sendSelfieLoader1.value = true;

    final imageFile = capturedImage.value;
    if (imageFile == null) {
      customSnackBar("Please capture your image first.");
      sendSelfieLoader1.value = false;
      return;
    }

    final formdata = DIO.FormData.fromMap({
      "driver_id": await secure.readData(secure.user_id),
      "image": await DIO.MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split("/").last,
      ),
    });

    log("parameter ------ ${formdata.fields}");

    try {
      final response = await dioClient.post(
        "https://ride.mtaani.com/API/update_driver_salfie.php",
        data: formdata,
      );

      final jsonString = jsonDecode(response.data);
      log("Driver selfie-Upload Response --------- $jsonString");

      if (jsonString['result'].toString() == "successfully update") {
        sp.setBoolValue(sp.DRIVER_ONLINE_STATUS, true);

        final homeController = Get.find<HomeController>();
        homeController.onOff.value = true;
        log("contoller.onOff.value---- Online Time${homeController.onOff.value}");

        log("Controller onOff Value Set: ${homeController.onOff.value}");

        // Print after setting the value
        bool? status = await sp.getBoolValue(sp.DRIVER_ONLINE_STATUS);
        log("SharedPref after selfie upload — DRIVER_ONLINE_STATUS: $status");
        sendSelfieLoader1.value = false;
        callback();
      } else {
        sendSelfieLoader1.value = false;
        customSnackBar("Something Went Wrong".tr);
      }
    } catch (e) {
      sendSelfieLoader1.value = false;
      log("Exception------", error: e.toString());
    }
  }


  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
