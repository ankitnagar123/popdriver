import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtaanidriver/utils/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../View/HomeView/membership_screen.dart';
import '../controller/auth_controller.dart';
import '../controller/booking_controller.dart';
import '../controller/home_screen_controller.dart';
import '../controller/my_ride_controller.dart';
import '../controller/profile_controller.dart';
import '../route_helper/route_helper.dart';
import 'colors.dart';
import 'custom_button.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  AuthController controller = Get.find<AuthController>();
  ProfileController ctr = Get.put(ProfileController());
  BookingController bookingController = Get.find<BookingController>();

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Flexible(
            flex: 11,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                Container(
                  height: Get.height / 4,
                  child: DrawerHeader(
                    decoration: BoxDecoration(color: MyColors.primary),
                    child: Column(
                      children: [
                        Image.asset("assets/images/mtaaniLogo.png",height: 25,),
                        SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: Get.height / 10,
                              width: Get.width / 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/images/loader.gif',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  image: ctr.Image.value,
                                  imageErrorBuilder: (c, o, s) => Image.asset(
                                    "assets/images/logo.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    maxLines: 1,
                                    softWrap: true,
                              
                                    overflow: TextOverflow.ellipsis,
                                    "${ctr.Name.value} ${ctr.lastName.value}",
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 20.0),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                    width: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      ctr.CountryCode.value + "" + ctr.Contact.value,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 14.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset('assets/menu/request.png',fit: BoxFit.fill,height: 35,),
                  title: Text(
                    'New Requests'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Get.back();
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/menu/notification.png',fit: BoxFit.fill,height: 35,),
                  title: Text(
                    'Notifications'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Get.toNamed(RouteHelper.getNotificationScreenRoute());
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/menu/wallet.png',fit: BoxFit.fill,height: 35,),
                  title: Text(
                    'Wallet'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Get.toNamed(RouteHelper.getWallletScreenRout(),arguments: "drawer");
                  },
                ),
                ListTile(
                  leading: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/images/background.png',fit: BoxFit.fill,height: 35,)),
                  title: Text(
                    'Membership'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MemberShipScreen(type: '2',)));
                  },
                ),
                ListTile(
                leading: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: Colors.blueAccent),
                  child: Center(
                    child: Icon(
                      Icons.language,
                      color: MyColors.white,
                    ),
                  ),
                ),
                title:  Text('Language'.tr),
                onTap: () {
                  show(context);
                },
              ),
                ListTile(
                  leading: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        color: Colors.brown),
                    child: Center(
                      child: Icon(
                        Icons.repeat,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    'Upcoming Rides'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Get.toNamed(RouteHelper.getMyRideScreenScreenRoute());
                  },
                ),
                ListTile(
                  leading: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        color: MyColors.primary),
                    child: Center(
                      child: Icon(
                        Icons.star_border_outlined,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    'Rate & Reviews'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Get.toNamed(RouteHelper.getRatingScreenScreenRoute());
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/menu/invite.png',fit: BoxFit.fill,height: 35,),
                  title: Text(
                    'Invite Friends'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Get.toNamed(RouteHelper.getInviteFriendScreenScreenRoute());
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/menu/edit.png',fit: BoxFit.fill,height: 35,),
                  title: Text(
                    'Edit Profile'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Get.toNamed(RouteHelper.getProfileScreenScreenRoute());
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/menu/ridehistory.png',fit: BoxFit.fill,height: 35,),
                  title: Text(
                    'Ride History'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Get.toNamed(RouteHelper.getRideHistoryScreenRoute());
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/menu/support.png',fit: BoxFit.fill,height: 35,),
                  title: Text(
                    'Support'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Get.toNamed(RouteHelper.getSupportScreenRoute());
                  },
                ),
                ListTile(
                  leading: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        color: Colors.red),
                    child: Center(
                      child: Icon(
                        Icons.delete,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                  title: Obx(() {
                    if (controller.deleteLoader.value) {
                      return Center(
                        child: myIndicator(),
                      );
                    } else
                      return Text(
                        'Delete Account'.tr,
                        style: TextStyle(fontWeight: FontWeight.w400),
                      );
                  }),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 30),
                            child: Center(
                              child: SizedBox(
                                height: bookingController.deleteId.value == "" && Get.find<MyRidesController>().rideLaterScreenList.isEmpty?140:Get.height/5,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Column(
                                      children: [
                                        Text(bookingController.deleteId.value == "" && Get.find<MyRidesController>().rideLaterScreenList.isEmpty?
                                          "Are you sure want to delete account".tr : "Are you not able to delete your account because you have already accepted the booking",textAlign: TextAlign.center,style: TextStyle(fontSize: 13,fontFamily: "Poppins"),),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Text(
                                                "Cancel".tr,
                                                style:
                                                TextStyle(color: Colors.red),
                                              ),
                                            ),
                                            Obx(() {
                                              if (controller.deleteLoader.value) {
                                                return Center(
                                                  child: myIndicator(),
                                                );
                                              } else {
                                                return TextButton(
                                                  onPressed: () {
                                                    if(bookingController.deleteId.value == "" && Get.find<MyRidesController>().rideLaterScreenList.length == 0){
                                                      controller.deleteAccount();
                                                    }else{
                                                      Get.back();
                                                    }


                                                  },
                                                  child: Text(
                                                    "Ok".tr,
                                                    style: TextStyle(
                                                        color: Colors.green),
                                                  ),
                                                );
                                              }
                                            })
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/menu/signout.png',fit: BoxFit.fill,height: 35,),
                  title: Text(
                    'Sign Out'.tr,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Center(
                              child: SizedBox(
                                height: 120,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Column(
                                      children: [
                                        Text("Are you sure want to Logout".tr),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                "Cancel".tr,
                                                style:
                                                    TextStyle(color: Colors.red),
                                              ),
                                            ),
                                            Obx(() {
                                              if (controller.logoutLoader.value) {
                                                return Center(
                                                  child: myIndicator(),
                                                );
                                              } else {
                                                return TextButton(
                                                  onPressed: () {
                                                    controller.driverLogout("",() {
                                                      Future.delayed(Duration.zero,(){
                                                        Get.find<HomeController>().streamSubscription.cancel();
                                                      });
                                                     /* onUserLogout();*/
                                                      Get.find<HomeController>()
                                                          .updateDriverLatLong(
                                                              "0",
                                                              "0",
                                                              "0",
                                                              "UnAvailable");
                                                      Get.offAllNamed(RouteHelper.getLoginScreenRoute());
                                                    });
                                                  },
                                                  child: Text(
                                                    "Ok".tr,
                                                    style: TextStyle(
                                                        color: Colors.green),
                                                  ),
                                                );
                                              }
                                            })
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 20),
                  child: Text.rich(
                    TextSpan(
                      text: 'Develop By',
                      children: <InlineSpan>[
                        WidgetSpan(
                          child: SizedBox(width: 10),
                        ),
                        TextSpan(
                            text: 'Cyber Impulses',
                            style: TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(Uri.parse(
                                    "https://cyberimpulses.com/"));
                              })
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

}

void show(BuildContext context) async {
  AuthController controller = Get.find<AuthController>();
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  controller.language.value = (await sp.getStringValue(sp.LANGUAGE)) ?? "";

  if (controller.language.value == "en_US") {
    controller.language.value = "English";
  } else {
    controller.language.value = "Spanish";
  }

  print("controller.language.value: ${controller.language.value}");

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Do You Want to Change Language".tr),
        content: Obx(
              () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text("English".tr),
                value: "English",
                groupValue: controller.language.value,
                onChanged: (value) {
                  controller.language.value = value!;
                  log("language-----${controller.language.value}");
                },
              ),
              RadioListTile(
                title: Text("Spanish".tr),
                value: "Spanish",
                groupValue: controller.language.value,
                onChanged: (value) {
                  controller.language.value = value!;
                  log("language-----${controller.language.value}");
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.language.value == "Spanish") {
                var local = Locale('es', 'ES');
                Get.updateLocale(local);
                sp.setStringValue(sp.LANGUAGE, local.toString());
              } else {
                var local = Locale('en', 'US');
                Get.updateLocale(local);
                sp.setStringValue(sp.LANGUAGE, local.toString());
              }
              Get.offAllNamed(RouteHelper.getSplashScreenRoute());
            },
            child: Text("Done".tr),
          ),
        ],
      );
    },
  );
}

