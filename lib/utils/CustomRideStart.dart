
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mtaanidriver/utils/polyline_handler.dart';
import 'package:mtaanidriver/utils/snackBar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:slidable_button/slidable_button.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../controller/booking_controller.dart';
import '../controller/home_screen_controller.dart';
import '../controller/my_ride_controller.dart';
import '../route_helper/route_helper.dart';
import 'colors.dart';
import 'custom_button.dart';

class CustomRideStart extends StatefulWidget {
  VoidCallback callCallback;
  VoidCallback msgCallBack;
  VoidCallback mapCallback;
  VoidCallback cancelCallBack;
  String image;
  String userName;
  String paymentType;
  String price;
  String pickupLocation;
  String dropLocation;

  CustomRideStart({
    super.key,
    required this.callCallback,
    required this.mapCallback,
    required this.msgCallBack,
    required this.cancelCallBack,
    required this.image,
    required this.userName,
    required this.paymentType,
    required this.price,
    required this.pickupLocation,
    required this.dropLocation,
  }) : super();

  @override
  State<CustomRideStart> createState() => _CustomRideStartState();
}

class _CustomRideStartState extends State<CustomRideStart> {
  HomeController contoller = Get.find<HomeController>();

  MyRidesController myRidesController = Get.find<MyRidesController>();

  BookingController controller = Get.find<BookingController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Card(
                color: MyColors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(80)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/loader.gif',
                                fit: BoxFit.cover,
                                image: widget.image,
                                imageErrorBuilder: (c, o, s) =>
                                    Image.asset(
                                      "assets/images/logo.png",
                                      fit: BoxFit.cover,
                                    ),
                              ),
                            ),
                          ),
                          Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.userName,
                                        style: TextStyle(fontSize: 15)),
                                    Text(
                                      widget.paymentType,
                                      style: TextStyle(
                                          color: MyColors.primary,
                                          fontSize: 11),
                                    )
                                  ],
                                ),
                              )),
                          Align(
                            alignment: Alignment.topRight,
                            child: Column(
                              children: [
                                Text(
                                  widget.price,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    String message =
                                        controller.useracceptmodel.locationUrl;
                                    Share.share(message);
                                  },
                                  child: Text(
                                    "Share Location".tr,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 23),
                        child: Text(
                          "pickup point".tr,
                          style: TextStyle(fontSize: 12,fontFamily: "Poppins"),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: Get.width / 1.5,
                            child: Text(
                              widget.pickupLocation,
                              maxLines: 2,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: SizedBox(
                          height: 30,
                          child: VerticalDivider(
                            color: MyColors.black,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: MyColors.primary,
                          ),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Destination Point".tr,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  SizedBox(
                                    width: Get.width / 1.5,
                                    child: Text(
                                      widget.dropLocation,
                                      maxLines: 2,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Obx(
                            () =>
                        controller.statusChangeLoader.value ||
                            myRidesController.fetchBookLoader.value
                            ? Center(
                          child: myIndicator(),
                        )
                            : HorizontalSlidableButton(
                            height: 45.0,
                            borderRadius: BorderRadius.circular(5.0),
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            buttonWidth: 45.0,
                            color: MyColors.TextField,
                            buttonColor: MyColors.primary,
                            dismissible: false,
                            isRestart: true,
                            label: const Center(
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Obx(() {
                                    return Text(
                                      controller.completeText.value,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins'),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            onChanged: (position) async {
                              if (position == SlidableButtonPosition.end) {
                                String tdata = DateFormat("hh:mm a")
                                    .format(DateTime.now());
                                print("date---------" + tdata);
                                String cdate = DateFormat("dd-MM-yyyy")
                                    .format(DateTime.now());
                                print(cdate);
                                if (controller.useracceptmodel.status == "Confirmed") {
                                  controller.statusChange("arrived",
                                      controller.useracceptmodel.bookingId,
                                      "",
                                      "",
                                          () {
                                        setState(() {

                                        });
                                      });

                                  /* contoller.arriveDriver.value = "Start";*/
                                } else if (controller.useracceptmodel.status ==
                                    "Arrived") {
                                  setState(() {

                                  });
                                  Get.toNamed(RouteHelper.getStartRideOtpScreenRoute(),arguments: {
                                    'id' : controller.useracceptmodel.bookingId
                                  }
                                  );
                                } else if (controller.useracceptmodel.status ==
                                    "Start Ride") {
                                  controller.statusChange("end_ride",
                                    controller.useracceptmodel.bookingId,
                                    cdate,
                                    tdata,
                                        () {
                                      setState(() {
                                        customSnackBar("Booking completed");
                                        contoller.onOff.value = true;
                                        polyline.clear();
                                        contoller.markers.clear();
                                        contoller.hide.value = false;
                                        controller.completeText.value = "";
                                        contoller.polylineVariable.value = "";
                                        contoller.polylineVariable2.value = "";
                                        myRidesController
                                            .fetchDriverBookingDetails(
                                          controller
                                              .useracceptmodel.bookingId,
                                              () {},
                                        );
                                        contoller.driverArriveValue.value =
                                        false;
                                        contoller.arriveDriver.value = "";
                                        controller.completeText.value = "";
                                        contoller.painButton.value = false;

                                      });

                                      dialogueBox(context);
                                    },
                                  );
                                }
                              } else {
                                print('Button is on the left');
                              }
                            }),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          left: controller.useracceptmodel.status == "Start Ride"?Get.width / 2.5:Get.width / 3.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: widget.mapCallback,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: MyColors.buttonColor,
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.DarkBlue,
                        offset: const Offset(
                          0.0,
                          0.0,
                        ),
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on,
                      color: MyColors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8,),
              /*ZegoSendCallInvitationButton(
                isVideoCall: false,
                invitees: getInvitesFromTextCtrl(
                    '${controller.useracceptmodel.userId}',
                    '${controller.useracceptmodel.userName}'),
                resourceID: 'zego_data',
                iconSize: const Size(50, 50),
                buttonSize: const Size(50, 50),
                onPressed: onSendCallInvitationFinished,
                clickableBackgroundColor: MyColors.white,
                icon: ButtonIcon(
                    icon: Icon(
                      Icons.call,
                      color: MyColors.white,
                    ),
                    backgroundColor: MyColors.buttonColor),
              ),*/
              ElevatedButton(onPressed: () {
                makePhoneCall('${controller.useracceptmodel.contact}');
              }, style: ElevatedButton.styleFrom(
                  minimumSize: Size(50, 50),
                  shape: CircleBorder(),
                  backgroundColor: MyColors.buttonColor
              ),
                  child: Icon(Icons.call, color: Colors.white,)),
              SizedBox(
                width: 8,
              ),
              InkWell(
                onTap: widget.msgCallBack,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: MyColors.buttonColor,
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.DarkBlue,
                        offset: const Offset(
                          0.0,
                          0.0,
                        ),
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chat,
                      color: MyColors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              /* InkWell(
                  onTap: mapCallback,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: MyColors.buttonColor,
                      borderRadius: BorderRadius.circular(80),
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.DarkBlue,
                          offset: const Offset(
                            0.0,
                            0.0,
                          ),
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.directions,color: MyColors.white,),
                    ),
                  ),
                ),
                SizedBox(width: 8,),*/
              controller.cancelStartBookLoader.value
                  ? Center(
                child: myIndicator(),
              )
                  : controller.useracceptmodel.status == "Start Ride"?
                  SizedBox():
                  InkWell(
                onTap: widget.cancelCallBack,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: MyColors.buttonColor,
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.DarkBlue,
                        offset: const Offset(
                          0.0,
                          0.0,
                        ),
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.clear,
                      color: MyColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void dialogueBox(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations
          .of(context)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      pageBuilder: (context, anim1, anim2) {
        return Obx(() {
          if (myRidesController.fetchBookLoader.value) {
            return Center(
              child: myIndicator(),
            );
          } else {
            var list = myRidesController.bookingDetailsModel!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height / 1.8,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xff0FB970),
                                            width: 4.0),
                                        borderRadius:
                                        BorderRadius.circular(60)),
                                    child: Center(
                                      child: Icon(
                                        Icons.check,
                                        color: Color(0xff0FB970),
                                        size: 50,
                                        weight: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Text(
                                    "Your Trip Has Ended".tr,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      list.rideTime,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                      width: Get.width / 1.8,
                                      child: Text(
                                        list.sourceAdd,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        softWrap: false,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 53),
                                  child: SizedBox(
                                    height: 35,
                                    child: VerticalDivider(
                                      color: MyColors.black,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      list.rideEndTime,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Icon(
                                      Icons.location_on,
                                      color: MyColors.primary,
                                    ),
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: Get.width / 1.5,
                                              child: Text(
                                                list.destinationAdd,
                                                maxLines: 2,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight
                                                        .bold),
                                              ),
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                      /*  Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            color: MyColors.buttonColor,
                                            borderRadius:
                                            BorderRadius.circular(60),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "KSh",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: MyColors.white),
                                            ),
                                          ),
                                        ),*/
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "${list.paymentMode}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    Text(
                                      "KSh ${list.totalPrice}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50),
                                  child: custom_button(
                                      voidCallback: () {
                                        setState(() {
                                          polyline.clear();
                                          contoller.hide.value = false;
                                          contoller.driverArriveValue.value =
                                          false;
                                          contoller.arriveDriver.value = "";
                                          contoller.painButton.value = false;
                                          controller.completeText.value = "";
                                          Get.back();
                                        });
                                      },
                                      text: "Next Ride".tr),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }
        });
      },
    );
  }

  void makePhoneCall(String phoneNumber) async {
    PermissionStatus permissionStatus = await Permission.phone.request();
    launchUrlString("tel://$phoneNumber");
    /*if (permissionStatus.isGranted) {

    } else {
      openAppSettings();
    }*/
  }
}
