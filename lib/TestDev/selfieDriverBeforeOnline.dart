import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtaanidriver/selfieCtr.dart';

class SelfieScreen extends StatelessWidget {
  final SelfieController controller = Get.put(SelfieController());

  @override
  Widget build(BuildContext context) {
    controller.initCamera();

    return Scaffold(
      floatingActionButton:Obx(()=> controller.sendSelfieLoader1.value?CupertinoActivityIndicator()
      :
      ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: const Text(
            "Capture Selfie",
          ),
          onPressed: () async{
           await controller.captureSelfie();
            controller.selfieUpload(() {

Get.back();
            },);
          }),),
      appBar: AppBar(
          title: const Text(
        "Take a Selfie",
        style: TextStyle(fontSize: 14),
      )),
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: controller.cameraController.value.aspectRatio / 3,
                child: CameraPreview(controller.cameraController),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.capturedImage.value != null) {
                  return Image.file(
                    controller.capturedImage.value!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  );
                } else {
                  return const Text("No selfie taken yet.");
                }
              }),
            ],
          ),
        );
      }),
    );
  }
}
