import 'dart:developer';
import 'dart:io';

import '../../../controller/auth_controller.dart';
import '../../../controller/profile_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController controller = Get.put(ProfileController());

  File? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    controller.fetchDriverDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          appBar:AppBar(
            iconTheme: IconThemeData(
                color: MyColors.white
            ),
            backgroundColor: MyColors.primary,
            title: Text("Profile".tr,
              style: TextStyle(fontSize: 20, color: MyColors.white,fontFamily: "Poppins"),),
            centerTitle: true,

          ),

          body: controller.fetchDetailLoader.value
              ? Center(
                  child: myIndicator(),
                )
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: Get.height / 6.5,
                                  width: Get.width / 2.9,
                                  child: InkWell(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: controller.updateImageLoader.value
                                          ? Center(
                                              child: SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: myIndicator(),
                                              ),
                                            )
                                          : FadeInImage.assetNetwork(
                                              placeholder:
                                              'assets/images/loader.gif',
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              image: controller.Image.value,
                                              imageErrorBuilder: (c, o, s) =>
                                                  Image.asset(
                                                "assets/images/logo.png",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                      onTap:(){
                                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                                          return DetailScreen();
                                        }));
                                      }

                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(
                              controller.Name.value +
                                  " " +
                                  controller.lastName.value,
                              style: TextStyle(
                                  color: MyColors.primary, fontSize: 18),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 10),
                            child: custom_buttons(
                                voidCallback: () {
                                  Get.toNamed(
                                      RouteHelper.getEditProfileScreenRoute());
                                },
                                text: "Edit Profile".tr),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: MyColors.primary,
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    color: MyColors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                controller.Name.value,
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: MyColors.primary,
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.phone,
                                    color: MyColors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                controller.CountryCode.value +
                                    " " +
                                    controller.Contact.value,
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          /*Row(
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: MyColors.primary,
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.email,
                                    color: MyColors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                controller.Email.value,
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          ),*/
                        ],
                      ),
                    ),
                    Positioned(
                      top: Get.height / 5.5,
                      left: Get.width / 1.8,
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: MyColors.buttonColor,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              takePhoto(ImageSource.gallery);
                              /*showModalBottomSheet(
                          context: context,
                          builder: ((builder) => bottomSheet()),
                        );*/
                            },
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: MyColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
    });
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(
        source: source,imageQuality: 60);
    print("picked file -----$pickedFile");
    if (pickedFile != null) {
      controller.imageString.value = File(pickedFile.path);
      log('image path---------->:${controller.imageString.value}');
      controller.updateDriverProfile(controller.imageString.value);
    } else {
      print('No image selected.');
    }
  }

}

class DetailScreen extends StatelessWidget {
  ProfileController controller = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
          child: PhotoView(
            imageProvider: NetworkImage(controller.Image.value,),
            minScale: PhotoViewComputedScale.contained * 1,
            maxScale: PhotoViewComputedScale.covered * 1,
            enableRotation: false,
            initialScale: PhotoViewComputedScale.contained * 1,

          )
      ),
    );

   /* DoubleTappableInteractiveViewer(
        scaleDuration: const Duration(milliseconds: 600),
    child: Image.network(controller.Image.value,height: double.infinity,width: double.infinity,));*/
  }
}


