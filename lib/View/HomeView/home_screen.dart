
import 'dart:developer';

import 'package:mtaanidriver/View/HomeView/Menu_bar/menu_bar_screen.dart';

import '../../TestDev/selfieDriverBeforeOnline.dart';
import '../../controller/auth_controller.dart';
import '../../controller/booking_controller.dart';
import '../../controller/home_screen_controller.dart';
import '../../controller/my_ride_controller.dart';
import '../../controller/permision_controller.dart';
import '../../controller/profile_controller.dart';
import '../../controller/route_controller.dart';
import '../../route_helper/route_helper.dart';
import '../../utils/CustomRideStart.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
import '../../utils/polyline_handler.dart';
import '../../utils/redirect_map.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/snackBar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/painic_controller.dart';
import '../../controller/vehicle_controller.dart';
import '../../utils/drawer.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  HomeController contoller = Get.find<HomeController>();
  BookingController controller = Get.find<BookingController>();

  ProfileController ctr = Get.put(ProfileController());
  PermissionController contrl = Get.find<PermissionController>();
  MyRidesController myRidesController = Get.find<MyRidesController>();
  PainButtonController painButtonController = Get.put(PainButtonController());
  AuthController authController = Get.find<AuthController>();
  TextEditingController tollCtr = TextEditingController();
  List<String> buttonText = [
    "Ride Now".tr,
    "Ride Later".tr,
  ];


  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  TextEditingController reasonCtr = TextEditingController();
  VehicleController controllerss = Get.put(VehicleController());
  @override
  void initState() {
    super.initState(); // <--- this should be called first
print("-----------message");
    log("onOff------------Direct ${contoller.onOff.value}");

    getData();
    contoller.getLocation();
    controller.adminApprove();
    controller.userAcceptBooking(() { });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      contoller.arriveDriver.value = Get.arguments["ArriveDriver"];
      ctr.fetchDriverDetail();
    });

    authController.updateDeviceId();
  }


 /* Timer? timer1;
  Timer? timer2;*/

  RouteController routeController = Get.put(RouteController());

  void getData() async {

    if (await sp.getBoolValue(sp.DRIVER_ONLINE_STATUS) == true) {
      contoller.onOff.value = true;
      controller.rideNowBooking();
      /* startStreaming();*/
      var loginKey = await sp.getStringValue(sp.LOGIN_DEVICE_KEY.toString());
      var accessToken = await sp.getStringValue(sp.ACCESS_TOKEN.toString());
      authController.loginCheck(loginKey.toString(), accessToken, context);
    }
    setState(() {
    });
    ctr.fetchDriverDetail();
  }


  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    print("-----------message");

    return Obx(() {
      return  Scaffold(
        key: _scaffoldKey,
        
        body: Stack(
          children: [
            GoogleMap(
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              padding: const EdgeInsets.all(0),
              buildingsEnabled: true,
              cameraTargetBounds: CameraTargetBounds.unbounded,
              compassEnabled: true,
              indoorViewEnabled: false,
              mapToolbarEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              markers: Set<Marker>.of(contoller.markers),
              polylines: Set<Polyline>.of(polyline.values),
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                contoller.setGoogleMapController(controller);
                contoller.updateCameraPosition(contrl.mapInitialLocation.value);
              },
              initialCameraPosition: CameraPosition(
                  target: LatLng(contrl.mapInitialLocation.value.latitude,
                      contrl.mapInitialLocation.value.longitude),
                  zoom: 16),
            ),
            Positioned(
              top: 30,

              left: 20,
              right: 20,
              child: SizedBox(
                width: Get.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(()=>MtaaniSidebar(),arguments: "Home");
                      },
                      child: Icon(
                        Icons.menu,
                        color: MyColors.black,
                      ),
                    ),
                    SizedBox(),
                    contoller.arriveDriver.value == "Arrived"
                        ? Text(
                      "Start Ride".tr,
                      style: TextStyle(
                        fontFamily: "Poppins",
                          fontSize: 18, fontWeight: FontWeight.bold),
                    )
                        : contoller.arriveDriver.value == "Start"
                        ? Text(
                      "Start Ride".tr,
                      style: TextStyle(
                          fontFamily: "Poppins",

                          fontSize: 18, fontWeight: FontWeight.bold),
                    )
                        : controller.completeText.value == "Complete Ride"
                        ? Text("Complete Ride".tr,
                        style: TextStyle(
                          fontFamily: "Poppins",
                            fontSize: 18,
                            fontWeight: FontWeight.bold))
                        : Text(
                      "Home".tr,
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),


                    Row(
                      children: [
                        Text(contoller.onOff.value == true ?
                        "Online".tr : "Offline".tr),
                        contoller.hide.value == false ?
                        Switch(
                            value: contoller.onOff.value,
                            activeColor: contoller.onOff.value == true
                                ? Colors.green
                                : Colors.grey,
                            onChanged: (value) {
                              if (value == true) {
                                Get.to(() => SelfieScreen());
                             /*   sp.setBoolValue(
                                    sp.DRIVER_ONLINE_STATUS, true);
                                controller.rideNowBooking();*/
                                /* timer1 = Timer.periodic(
                                        Duration(seconds: 5), (timer) {
                                      controller.rideNowBooking();
                                    });*/
                                /*startStreaming();*/
                              } else {
                                contoller.onOff.value = value;

                                sp.setBoolValue(
                                    sp.DRIVER_ONLINE_STATUS, false);
                                contoller.updateDriverLatLong("0",
                                    "0", "0", "UnAvailable");
                                /* timer1!.cancel();
                                    timer2!.cancel();*/
                              }
                            })
                            : Switch(

                          value: contoller.onOff.value,

                          activeTrackColor: Colors.green,

                          onChanged: (value) {
                            customSnackBar("You can't offline until booking completed");
                          },
                        )
                      ],
                    )
/*
                    Row(
                      children: [
                        Text(

                          contoller.onOff.value ? "Online".tr : "Offline".tr,
                          style: TextStyle(
                            color: contoller.onOff.value ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(() => Switch(
                          value: contoller.onOff.value,
                          activeColor: Colors.green,
                          onChanged: contoller.hide.value
                              ? null
                              : (value) async {
                            if (value == true) {
                              await Get.to(() => SelfieScreen());
                              // After returning from SelfieScreen, you can update the value again
                           */
/*   contoller.onOff.value = true;
                              sp.setBoolValue(sp.DRIVER_ONLINE_STATUS, true);*//*

                            } else {
                              contoller.onOff.value = false;
                              sp.setBoolValue(sp.DRIVER_ONLINE_STATUS, false);
                              contoller.updateDriverLatLong("0", "0", "0", "UnAvailable");
                            }
                          },
                        ))

                      ],
                    )
*/

                  ],
                ),
              ),
            ),
/*-----------------painButton-------------------*/
            Visibility(
              visible: contoller.painButton.value,
              child: Positioned(
                left: Get.width / 1.4,
                top: Get.height / 7,
                child: InkWell(
                  onTap: () {
                    painButtonController
                        .getAddressFromLatLng(controller.bookingId.value);
                  },
                  child: painButtonController.painLoader.value ?
                  Center(
                    child: myIndicator(),
                  ) :
                  Container(
                    height: 75,
                    width: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: Color(0xffFF1A14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/penic.png',
                          height: 30,
                        ),
                        Text(
                          "Panic\nButton".tr,
                          style: TextStyle(
                            color: MyColors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            contoller.hide.value == false
                ? SizedBox.shrink()
                : Visibility(
              visible: contoller.driverArriveValue.value,
              child: Positioned(
                top: Get.height / 2.25,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: Get.height / 1.7,
                          width: Get.width,
                          child: CustomRideStart(
                            callCallback: () {
                            },
                            msgCallBack: () {
                              Get.toNamed(
                                  RouteHelper.getMessageScreenRout(),
                                  arguments: {
                                    "userId":
                                    controller.useracceptmodel.userId
                                  });
                            },
                            cancelCallBack: () {
                              Get.toNamed(
                                  RouteHelper.getCancelBookingScreenRoute(),
                                  arguments: {
                                    "ID": controller.useracceptmodel
                                        .bookingId,
                                    "type": "Ride Now".tr
                                  });
                            },
                            image: controller.useracceptmodel.image,
                            userName: controller.useracceptmodel.userName,
                            paymentType:
                            controller.useracceptmodel.paymentMode,
                            price:
                            "KSh ${controller.useracceptmodel.totalPrice}",
                            pickupLocation:
                            controller.useracceptmodel.sourceAdd,
                            dropLocation:
                            controller.useracceptmodel.destinationAdd,
                            mapCallback: () {
                              if (controller.useracceptmodel.status == "Confirmed".tr) {
                                MapUtils.openMap(double.parse(controller.useracceptmodel.sourceLat),
                                  double.parse(controller.useracceptmodel.sourceLong),);
                              } else {
                                MapUtils.openMap(double.parse(
                                    controller.useracceptmodel
                                        .destinationLat),
                                  double.parse(controller.useracceptmodel
                                      .destinationLong),);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            contoller.driverArriveValue.value == true
                ? SizedBox.shrink()
                : contoller.onOff.value == true
                ? Positioned(
              top: 100,
              left: 5,
              right: 15,
              child: Column(
                children: [
                  Container(

                    width: Get.width,
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        ...List.generate(
                          buttonText.length,
                              (index) =>
                              button(
                                index: index,
                                text: buttonText[index],
                              ),
                        ),
                      ],
                    ),
                  ),
                  contoller.selectedValueIndex.value == 0
                      ? controller.datas.value == ""
                      ? SizedBox()
                      : rideNow()
                      : controller.datass.value == ""
                      ? SizedBox()
                      : rideLater()
                ],
              ),
            )
                : SizedBox()
          ],
        ),
      );
    }

    );
  }




  Widget button({required String text, required int index}) {
    return InkWell(
      splashColor: Colors.cyanAccent,
      onTap: () {
        setState(() {
          contoller.selectedValueIndex.value = index;
          if (contoller.selectedValueIndex.value == 1) {
            controller.rideLaterBooking();
          /*  timer1!.cancel();
            timer2 = Timer.periodic(Duration(seconds: 5), (timer) {
              controller.rideLaterBooking();
            });*/
          } else {
           /* timer2!.cancel();*/
            controller.rideNowBooking();
          }
        });
      },
      child: Row(
        children: [
          SizedBox(
            width: 5,
          ),
          Container(
            height: 50,
            width: Get.width / 2.3,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient:  index == contoller.selectedValueIndex.value? LinearGradient(colors: [
                MyColors.primary,
                Colors.cyan,
              ]):null,
                color: index == contoller.selectedValueIndex.value
                    ? MyColors.primary
                    : Colors.grey.shade500,
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: index == contoller.selectedValueIndex.value
                      ? MyColors.white
                      : MyColors.white,
                  fontSize: index == contoller.selectedValueIndex.value
                      ? 15
                      : 13,
                  fontWeight: index == contoller.selectedValueIndex.value
                      ?FontWeight.w600:FontWeight.normal
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget rideNow() {
    return Container(
      height: Get.height,
      width: Get.width,
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: controller.rideNowList.length,
                itemBuilder: (context, index) {
                  var reverseList = controller.rideNowList.reversed.toList();
                  var list = reverseList[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: MyColors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(list.userName),
                                Text("#${list.bookingId}"),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("KSh ${list.totalPrice}"),
                                Text("${list.distance} KM"),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            /* Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(list.rideTime),

                                ],
                              ),*/
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Pickup Point".tr,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    SizedBox(
                                      width: Get.width / 1.5,
                                      child: Text(
                                        list.sourceAdd,
                                        maxLines: 2,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, top: 5),
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Destination Point".tr,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      SizedBox(
                                        width: Get.width / 1.5,
                                        child: Text(
                                          list.destinationAdd,
                                          maxLines: 2,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Obx(() {
                              return Row(
                                children: [
                                  Expanded(
                                    child: controller.acceptBookLoader.value &&
                                        contoller.bookingIndex == index
                                        ? Center(
                                      child: myIndicator(),
                                    )
                                        : custom_buttons(
                                        voidCallback: () {
                                          if (list.totalPrice == "0") {
                                            customSnackBar(
                                                'your company is not offering this City ride contact your company '.tr);
                                          } else if (list.totalPrice == 0) {
                                            customSnackBar(
                                                'your company is not offering this City ride contact your company '.tr);
                                          } else
                                            contoller.bookingIndex = index;
                                            controller.acceptBooking(
                                                list.bookingId,
                                                () {
                                              Get.toNamed(RouteHelper.getReadyForRideScreenRoute());
                                            });
                                        },
                                        text: "Accept".tr),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Obx((){

                                    return Expanded(
                                      child: controller.cancelBookLoader.value && contoller.cancelIndex == index?

                                          Center(child: myIndicator(),):

                                      InkWell(
                                        onTap: () {
                                          contoller.cancelIndex = index;
                                          controller.cancelBooking(
                                              list.bookingId, "", () {

                                            controller.rideNowBooking();
                                          });
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 150,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              color: MyColors.TextField),
                                          child:
                                          Center(child: Text("Pass".tr)),
                                        ),
                                      ),
                                    );
                                  })
                                ],
                              );
                            })
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SizedBox(
            height: Get.height / 5,
          )
        ],
      ),
    );
  }

  Widget rideLater() {
    return Container(
      height: Get.height,
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: controller.rideLaterList.length,
                itemBuilder: (context, index) {
                  var reverseList = controller.rideLaterList.reversed.toList();
                  var list = reverseList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: MyColors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(list.userName),
                                Text("#${list.bookingId}"),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("KSh ${list.totalPrice}"),
                                Text("${list.distance} KM"),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            /* Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(list.rideTime),

                                ],
                              ),*/
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 20,
                              width: Get.width,
                              color: MyColors.primary,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Ride Later".tr,
                                    style: TextStyle(color: MyColors.white),
                                  ),
                                  Text(
                                    "${list.rideDate}" +
                                        " " +
                                        "${list.rideTime}",
                                    style: TextStyle(color: MyColors.white),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Pickup Point".tr,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    SizedBox(
                                      width: Get.width / 1.4,
                                      child: Text(
                                        list.sourceAdd,
                                        maxLines: 2,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Destination Point".tr,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      SizedBox(
                                        width: Get.width / 1.2,
                                        child: Text(
                                          list.destinationAdd,
                                          maxLines: 2,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Obx(() {
                              return Row(
                                children: [
                                  Expanded(
                                    child: controller.acceptBookLoader.value &&
                                        contoller.bookingIndex == index
                                        ? Center(
                                      child: myIndicator(),
                                    )
                                        : custom_buttons(
                                        voidCallback: () {
                                          if (list.totalPrice == "0") {
                                          } else if (list.totalPrice == 0) {
                                          } else
                                            contoller.bookingIndex = index;
                                            controller.acceptBooking(
                                                list.bookingId,
                                                () {
                                              Get.toNamed(RouteHelper
                                                  .getReadyForRideScreenRoute());
                                            });
                                        },
                                        text: "Accept".tr),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Obx(() {
                                    return Expanded(
                                      child: controller.cancelBookLoader
                                          .value &&
                                          contoller.cancelIndex == index
                                          ? Center(
                                        child: myIndicator(),
                                      )
                                          : Container(
                                        height: 50,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            color: MyColors.TextField),
                                        child: Center(
                                            child: InkWell(
                                                onTap: () {
                                                  contoller.cancelIndex = index;
                                                  controller.cancelBooking(
                                                      list.bookingId, "", () {
                                                    controller.rideLaterBooking();
                                                  });
                                                },
                                                child: Text("Pass".tr))),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SizedBox(
            height: Get.height / 5,
          )
        ],
      ),
    );
  }

 /* Future<void> getLocation() async {
    contoller.getLocation().then((value) async {
      BookingController controllers = Get.find<BookingController>();
      contoller.startLocation.value = LatLng(value.latitude, value.longitude);
      if (contoller.hide.value == false) {

      } else {
        if (controllers.useracceptmodel.bookingId != "") {
          controllers.updateLatLongStartRide(controllers.useracceptmodel.bookingId,
              value.latitude.toString(), value.longitude.toString());
        }
      }

      Uint8List imageData = await getMarkers(context);
      contoller.markers.add(Marker(
          markerId: MarkerId("1"),
          position: LatLng(value.latitude, value.longitude),
          rotation: value.heading,
          draggable: true,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          //anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData)));


      if (polyline.isNotEmpty) {
        contoller.userPickupMarker(context);
      }

      if (contoller.onOff.value == true) {
        contoller.updateDriverLatLong(value.latitude.toString(),
            value.longitude.toString(), value.heading.toString(), "Available");
      }
      else {
        contoller.updateDriverLatLong("0",
            "0", "0", "UnAvailable");
      }

      CameraPosition cameraPosition = new CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 16,
      );


      contoller.googleMapController.value!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
     *//* setState(() {
      });*//*
    });
    var loginKey = await sp.getStringValue(sp.LOGIN_DEVICE_KEY.toString());
    var accessToken = await sp.getStringValue(sp.ACCESS_TOKEN.toString());
    authController.loginCheck(loginKey.toString(), accessToken, context);
  }

  startStreaming() {
    contoller.streamSubscription =
        Geolocator.getPositionStream().listen((event) {
          getLocation();
        });
  }

  Future<Uint8List> getMarkers(context) async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(
      "assets/images/imagemarker.png",
    );
    return byteData.buffer.asUint8List();
  }*/

}
