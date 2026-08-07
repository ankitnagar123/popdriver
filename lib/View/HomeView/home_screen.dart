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
import '../../utils/polyline_handler.dart';
import '../../utils/redirect_map.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/booking_cancellation_dialog.dart';
import '../../utils/snackBar.dart';
import '../../utils/web_auth_layout.dart';
import '../../utils/web_driver_layout.dart';
import '../../widgets/driver_home_map.dart';
import '../../service/booking_incoming_service.dart';
import '../../service/device_token_sync.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/painic_controller.dart';
import '../../controller/vehicle_controller.dart';

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
    // "Ride Later".tr,
  ];

  String getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Morning Captain 🌅';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon Captain 🌞';
    } else if (hour >= 17 && hour < 20) {
      return 'Evening Captain 🌇';
    } else {
      return 'Night Captain 🌙';
    }
  }

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  TextEditingController reasonCtr = TextEditingController();
  VehicleController controllerss = Get.put(VehicleController());

  @override
  void initState() {
    super.initState(); // <--- this should be called first

    print("-----------message");
    log("onOff------------Direct ${contoller.onOff.value}");

    getData();
    contrl.getCurrentPosition();
    contoller.getLocation();
    controller.adminApprove();
    controller.userAcceptBooking();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      contoller.arriveDriver.value = Get.arguments["ArriveDriver"];
      ctr.fetchDriverDetail();
      DeviceTokenSync.syncAfterLogin();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BookingIncomingService.instance.processPendingWhenReady();
    });
  }

  /* Timer? timer1;
  Timer? timer2;*/

  RouteController routeController = Get.put(RouteController());

  void getData() async {
    if (await sp.getBoolValue(sp.DRIVER_ONLINE_STATUS) == true) {
      if (contoller.canGoOnline(showMessage: false)) {
        contoller.onOff.value = true;
        await contoller.goOnlineAndSyncLocation(context);
        var loginKey = await sp.getStringValue(sp.LOGIN_DEVICE_KEY.toString());
        var accessToken = await sp.getStringValue(sp.ACCESS_TOKEN.toString());
        authController.loginCheck(loginKey.toString(), accessToken, context);
      } else {
        await sp.setBoolValue(sp.DRIVER_ONLINE_STATUS, false);
        contoller.onOff.value = false;
      }
    }
    setState(() {});
    ctr.fetchDriverDetail();
  }

  @override
  void dispose() {
    contoller.clearGoogleMapController();
    _webRideSheetController.dispose();
    controller.cancel();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ScrollController _webRideSheetController = ScrollController();

  double _rideSheetBottomClearance(BuildContext context) {
    if (WebDriverLayout.isWidePanel(context)) return 16;
    // BottomAppBar is 60; keep sheet just above it (not under FAB notch).
    const bottomAppBarHeight = 60.0;
    final gestureInset = MediaQuery.viewPaddingOf(context).bottom;
    return bottomAppBarHeight + gestureInset + 12;
  }

  LatLng _resolveMapTarget() {
    if (contoller.hasValidLocation.value) {
      return contoller.startLocation.value;
    }
    final initial = contrl.mapInitialLocation.value;
    if (initial.latitude != 0 || initial.longitude != 0) return initial;
    return contoller.startLocation.value;
  }

  Widget _buildHomeInfoButton() {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade100,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.info_outline, size: 20, color: Colors.red),
      ),
      onPressed: showMoreInfo,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("-----------message");

    return Obx(() {
      // Rebuild for markers / route / online toggle only.
      // Do NOT read startLocation here — every GPS tick would rebuild the map
      // and caused blink/flicker on some web browsers.
      contoller.mapPolylineEpoch.value;
      contoller.markers.length;
      contoller.onOff.value;
      contoller.mapFollowDriver.value;
      return Scaffold(
        key: _scaffoldKey,
        body: contoller.onOff.value == false
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SafeArea(
                      child: SizedBox(
                        width: Get.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (WebDriverLayout.isMobileLayout(context))
                              InkWell(
                                onTap: () {
                                  Get.to(() => MtaaniSidebar(),
                                      arguments: "Home");
                                },
                                child: Icon(
                                  Icons.menu,
                                  color: MyColors.black,
                                ),
                              ),
                            Expanded(
                              child: Center(
                                child: contoller.arriveDriver.value == "Arrived"
                                    ? Text(
                                        "Start Ride".tr,
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : contoller.arriveDriver.value == "Start"
                                        ? Text(
                                            "Start Ride".tr,
                                            style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : controller.completeText.value ==
                                                "Complete Ride"
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
                              ),
                            ),
                            _buildHomeInfoButton(),
                            Row(
                              children: [
                                Text(contoller.onOff.value == true
                                    ? "Online".tr
                                    : "Offline".tr),
                                contoller.hide.value == false
                                    ?
                                    /*  Switch(
                              value: contoller.onOff.value,
                              activeColor: contoller.onOff.value == true
                                  ? Colors.green
                                  : Colors.grey,
                              onChanged: (value) {
                                if (value == true) {
                                  contoller.onOff.value = value;

                                  // Get.to(() => SelfieScreen());
                                     sp.setBoolValue(
                                  sp.DRIVER_ONLINE_STATUS, true);
                              controller.rideNowBooking();
                                  */ /* timer1 = Timer.periodic(
                                      Duration(seconds: 5), (timer) {
                                    controller.rideNowBooking();
                                  });*/ /*
                                  */ /*startStreaming();*/ /*
                                } else {
                                  contoller.onOff.value = value;

                                  sp.setBoolValue(
                                      sp.DRIVER_ONLINE_STATUS, false);
                                  contoller.updateDriverLatLong("0",
                                      "0", "0", "UnAvailable");
                                  */ /* timer1!.cancel();
                                  timer2!.cancel();*/ /*
                                }
                              })*/
                                    Switch(
                                        value: contoller.onOff.value,
                                        activeColor:
                                            contoller.onOff.value == true
                                                ? Colors.green
                                                : Colors.grey,
                                        onChanged: (value) async {
                                          if (value) {
                                            if (!contoller.canGoOnline()) {
                                              return;
                                            }
                                            contoller.onOff.value = true;
                                            await sp.setBoolValue(
                                                sp.DRIVER_ONLINE_STATUS, true);
                                            await contoller
                                                .goOnlineAndSyncLocation(
                                                    context);
                                          } else {
                                            contoller.clearPenaltyAutoRestore();
                                            contoller.onOff.value = false;
                                            sp.setBoolValue(
                                                sp.DRIVER_ONLINE_STATUS, false);
                                            await contoller
                                                .onDriverOnlineStatusChanged(
                                                    false);
                                            contoller.updateDriverLatLong(
                                                '0',
                                                '0',
                                                '0',
                                                'UnAvailable',
                                                context: context);
                                          }
                                        })
                                    : Switch(
                                        value: contoller.onOff.value,
                                        activeTrackColor: Colors.green,
                                        onChanged: (value) {
                                          customSnackBar(
                                              "You can't offline until booking completed");
                                        },
                                      )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                        child: Image(
                      image: AssetImage("assets/images/offline.png"),
                      width: 230,
                    )),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Good ${getTimeOfDayGreeting()} ",
                      style: TextStyle(
                        letterSpacing: 1.0,
                        fontSize: 16,
                        color: Colors.grey,
                        // fontWeight: FontWeight.,
                      ),
                    ),
                    Text(
                      "Go ON DUTY to start earning ",
                      style: TextStyle(
                        letterSpacing: 1.0,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        // fontWeight: FontWeight.,
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  DriverHomeMap(
                    markers: Set<Marker>.of(contoller.markers),
                    polylines: Set<Polyline>.of(polyline.values),
                    topPadding: MediaQuery.paddingOf(context).top + 56,
                    initialTarget: _resolveMapTarget(),
                    initialZoom: 16,
                    onCameraMoveStarted: contoller.onCameraMoveStarted,
                    onMapDisposed: contoller.clearGoogleMapController,
                    onMapCreated: (GoogleMapController mapCtl) {
                      contoller.setGoogleMapController(mapCtl);
                      if (contoller.hasValidLocation.value) {
                        contoller.recenterMapOnDriver();
                      }
                    },
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
                          if (WebDriverLayout.isMobileLayout(context))
                            InkWell(
                              onTap: () {
                                Get.to(() => MtaaniSidebar(), arguments: "Home");
                              },
                              child: Icon(
                                Icons.menu,
                                color: MyColors.black,
                              ),
                            ),
                          Expanded(
                            child: Center(
                              child: contoller.arriveDriver.value == "Arrived"
                                  ? Text(
                                      "Start Ride".tr,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : contoller.arriveDriver.value == "Start"
                                      ? Text(
                                          "Start Ride".tr,
                                          style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : controller.completeText.value ==
                                              "Complete Ride"
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
                            ),
                          ),
                          _buildHomeInfoButton(),
                          Row(
                            children: [
                              Text(contoller.onOff.value == true
                                  ? "Online".tr
                                  : "Offline".tr),
                              contoller.hide.value == false
                                  ? Switch(
                                      value: contoller.onOff.value,
                                      activeColor: contoller.onOff.value == true
                                          ? Colors.green
                                          : Colors.grey,
                                      onChanged: (value) {
                                        if (value == true) {
                                          if (!contoller.canGoOnline()) {
                                            return;
                                          }
                                          Get.to(() => SelfieScreen());
                                        } else {
                                          contoller.clearPenaltyAutoRestore();
                                          contoller.onOff.value = false;
                                          sp.setBoolValue(
                                              sp.DRIVER_ONLINE_STATUS, false);
                                          contoller.onDriverOnlineStatusChanged(
                                              false);
                                          contoller.updateDriverLatLong(
                                              '0',
                                              '0',
                                              '0',
                                              'UnAvailable',
                                              context: context);
                                        }
                                      })
                                  : Switch(
                                      value: contoller.onOff.value,
                                      activeTrackColor: Colors.green,
                                      onChanged: (value) {
                                        customSnackBar(
                                            "You can't offline until booking completed");
                                      },
                                    )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
/*-----------------painButton-------------------*/
/*
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
                        child: painButtonController.painLoader.value
                            ? Center(
                                child: myIndicator(),
                              )
                            : Container(
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
                                      "Emergency\nButton".tr,
                                      style: TextStyle(
                                        color: MyColors.white,
                                        fontSize: 9,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
*/
                  contoller.hide.value == false
                      ? SizedBox.shrink()
                      : Visibility(
                          visible: contoller.driverArriveValue.value,
                          child: WebDriverLayout.isWidePanel(context)
                              ? Positioned(
                                  top: 64,
                                  right: 20,
                                  bottom: 20,
                                  width: WebDriverLayout.panelWidth,
                                  child: Material(
                                    elevation: 10,
                                    shadowColor: Colors.black26,
                                    borderRadius: BorderRadius.circular(16),
                                    clipBehavior: Clip.antiAlias,
                                    child: _buildActiveRideCard(
                                      context,
                                      _webRideSheetController,
                                    ),
                                  ),
                                )
                              : Positioned.fill(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          _rideSheetBottomClearance(context),
                                    ),
                                    child: SafeArea(
                                      top: false,
                                      bottom: false,
                                      child: DraggableScrollableSheet(
                                        // Tall enough for full card (incl. Arrive)
                                        // so default state needs no scroll.
                                        initialChildSize: 0.58,
                                        minChildSize: 0.52,
                                        maxChildSize: 0.92,
                                        snap: true,
                                        snapSizes: const <double>[
                                          0.52,
                                          0.58,
                                          0.72,
                                          0.92,
                                        ],
                                        builder: (context, scrollController) {
                                          return _buildActiveRideCard(
                                            context,
                                            scrollController,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                  contoller.driverArriveValue.value == true
                      ? SizedBox.shrink()
                      : contoller.onOff.value == true
                          ? Positioned(
                              top: 80,
                              left: WebDriverLayout.isWidePanel(context) ? null : 5,
                              right: WebDriverLayout.isWidePanel(context) ? 20 : 15,
                              bottom: WebDriverLayout.isWidePanel(context) ? 20 : null,
                              width: WebDriverLayout.isWidePanel(context)
                                  ? WebDriverLayout.panelWidth
                                  : null,
                              child: IgnorePointer(
                                ignoring: controller.rideNowList.isEmpty,
                                child: WebDriverLayout.isWidePanel(context)
                                    ? Material(
                                        color: Colors.transparent,
                                        child: rideNow(),
                                      )
                                    : SizedBox(
                                        height: Get.height * 0.85,
                                        child: rideNow(),
                                      ),
                              ),
                            )
                          : SizedBox.shrink(),
                  if (WebDriverLayout.isMobileLayout(context) &&
                      !contoller.mapFollowDriver.value)
                    Positioned(
                      right: 16,
                      bottom: _rideSheetBottomClearance(context) + 12,
                      child: FloatingActionButton.small(
                        heroTag: 'recenter_map',
                        backgroundColor: Colors.white,
                        foregroundColor: MyColors.primary,
                        elevation: 4,
                        onPressed: contoller.recenterMapOnDriver,
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                ],
              ),
      );
    });
  }

  Widget _buildActiveRideCard(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return CustomRideStart(
      sheetScrollController: scrollController,
      bookingId: controller.useracceptmodel.bookingId,
      userID: controller.useracceptmodel.userId,
      distance: controller.useracceptmodel.distance,
      time: controller.useracceptmodel.duration,
      callCallback: () {},
      msgCallBack: () {
        Get.toNamed(RouteHelper.getMessageScreenRout(), arguments: {
          "userId": controller.useracceptmodel.userId
        });
      },
      cancelCallBack: () {
        showCustomDialog(context, controller.useracceptmodel.bookingId);
      },
      image: controller.useracceptmodel.image,
      userName: controller.useracceptmodel.userName,
      paymentType: controller.useracceptmodel.paymentMode,
      price: "\$ ${controller.useracceptmodel.totalPrice}",
      pickupLocation: controller.useracceptmodel.sourceAdd,
      dropLocation: controller.useracceptmodel.destinationAdd,
      mapCallback: () {
        if (controller.useracceptmodel.status == "Confirmed".tr) {
          MapUtils.openMap(
            double.parse(controller.useracceptmodel.sourceLat),
            double.parse(controller.useracceptmodel.sourceLong),
          );
        } else {
          MapUtils.openMap(
            double.parse(controller.useracceptmodel.destinationLat),
            double.parse(controller.useracceptmodel.destinationLong),
          );
        }
      },
    );
  }

  Widget rideNow() {
    return Obx(() {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: WebDriverLayout.isMobileLayout(context),
        padding: EdgeInsets.symmetric(
          horizontal: WebDriverLayout.isWidePanel(context) ? 4 : 10,
          vertical: 8,
        ),
        itemCount: controller.rideNowList.length,
        itemBuilder: (context, index) {
          var reverseList = controller.rideNowList.reversed.toList();
          var list = reverseList[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: WebDriverLayout.isWidePanel(context) ? 12 : 0,
            ),
            child: Card(
            elevation: WebDriverLayout.isWidePanel(context) ? 6 : 3,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                WebDriverLayout.isWidePanel(context) ? 16 : 15,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          list.userName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MyColors.black,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "#${list.bookingId}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "${list.rideDate} • ${list.rideTime}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer_outlined,
                              size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Row(
                            children: [
                              Text(
                                "Offer \$ ${list.userOfferPrice}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 7),

                  // Price & Distance Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        children: [
                          _buildInfoBadge(
                            icon: Icons.directions_car,
                            value: "${list.distance}",
                            color: MyColors.primary,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          _buildInfoBadge(
                            icon: Icons.access_time,
                            value: list.duration,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          showMoreInfo();
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info,
                                  size: 25, color: Colors.red.shade400),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 9,
                  ),
                  // In the Price & Distance Row section, replace with:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBadge1(

                        icon: Icons.local_taxi,
                        value: "Taxi \$ ${list.taxiPrice}",
                        color: Colors.red,
                      ),
                      _buildInfoBadge1(
                        icon: Icons.people,
                        value: "R/S \$ ${list.sharePrice}",
                        color: Colors.black,
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Location Section
                  _buildLocationRow(
                    icon: Icons.location_pin,
                    iconColor: Colors.green,
                    title: "Pickup Point".tr,
                    address: list.sourceAdd,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Divider(
                      color: Colors.grey[300],
                      height: 20,
                      thickness: 1,
                    ),
                  ),
                  _buildLocationRow(
                    icon: Icons.flag,
                    iconColor: MyColors.primary,
                    title: "Destination Point".tr,
                    address: list.destinationAdd,
                  ),
                  SizedBox(height: 16),

                  // Action Buttons
                  Obx(() {
                    bool isLoadingAccept = controller.acceptBookLoader.value &&
                        contoller.bookingIndex == index;
                    bool isLoadingPass = controller.cancelBookLoader.value &&
                        contoller.cancelIndex == index;

                    return Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            text: "Accept".tr,
                            color: MyColors.black,
                            isLoading: isLoadingAccept,
                            onPressed: () {
                              if (list.userOfferPrice == "0" ||
                                  list.userOfferPrice == 0) {
                                customSnackBar(
                                    'your company is not offering this City ride contact your company '
                                        .tr);
                              } else {
                                contoller.bookingIndex = index;
                                controller.acceptBooking(
                                  list.bookingId,
                                  () => Get.toNamed(
                                      RouteHelper.getReadyForRideScreenRoute()),
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildActionButton(
                            text: "Pass".tr,
                            color: Colors.grey,
                            isLoading: isLoadingPass,
                            isSecondary: true,
                            onPressed: () {
                              _showPassConfirmationDialog(
                                context,
                                list.bookingId,
                                index,
                              );
                            },
                          ),
                        ),
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
    });
  }

// Helper Widgets

  Widget _buildInfoBadge(
      {required IconData icon, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge1(
      {required IconData icon, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
      {required IconData icon,
      required Color iconColor,
      required String title,
      required String address}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required bool isLoading,
    bool isSecondary = false,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: isSecondary ? color : Colors.white,
        backgroundColor: isSecondary ? Colors.transparent : color,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSecondary ? BorderSide(color: color) : BorderSide.none,
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isSecondary ? color : Colors.white,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  void _showPassConfirmationDialog(
    BuildContext context,
    String bookingId,
    int index,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WebAuthLayout.dialog(
        context: dialogContext,
        maxWidth: 400,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                "Sure to PASS ?".tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        "No".tr,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        contoller.cancelIndex = index;
                        controller.cancelBooking(
                          bookingId,
                          "",
                          () => controller.rideNowBooking(),
                        );
                      },
                      child: Text(
                        "Yes".tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showCustomDialog(BuildContext context, String bookingId) {
    final String dialogTitle =
        "Are you sure you want to cancel this booking".tr;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => WebAuthLayout.dialog(
              context: dialogContext,
              maxWidth: 420,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Icon
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 40,
                    ),
                    const SizedBox(height: 16),

                    // Message Text
                    Text(
                      dialogTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      "If you cancel this booking, you will not receive any new bookings for the next 10 minutes",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Buttons Row
                    Obx(() {
                      if (controller.cancelBookLoader.value ||
                          controller.cancelStartBookLoader.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Cancel Button
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: Colors.grey),
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(
                                "Back".tr,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Confirm Button
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                if (controller.cancelBookLoader.value ||
                                    controller.cancelStartBookLoader.value) {
                                  return;
                                }
                                controller.driverBookingCancel(bookingId, '',
                                    () {
                                  polyline.clear();
                                  contoller.clearMarkersExceptDriver();
                                  contoller.hide.value = false;
                                  contoller.onOff.value = true;
                                  controller.completeText.value = "";
                                  contoller.polylineVariable.value = "";
                                  contoller.polylineVariable2.value = "";
                                  contoller.driverArriveValue.value = false;
                                  controller.reason.value = "";
                                  controller.selectedIndex.value = -1;
                                  contoller.arriveDriver.value = "";
                                  contoller.painButton.value = false;

                                  // iOS-safe: close confirm dialog by context,
                                  // not Get.back() (often pops wrong route).
                                  void closeConfirmDialog() {
                                    if (dialogContext.mounted) {
                                      final nav = Navigator.of(
                                        dialogContext,
                                        rootNavigator: true,
                                      );
                                      if (nav.canPop()) nav.pop();
                                    } else {
                                      BookingCancellationDialog
                                          .dismissOpenDialogs();
                                    }
                                  }

                                  closeConfirmDialog();
                                  // Refresh active booking after dialog closed.
                                  controller.userAcceptBooking(() {});
                                });
                              },
                              child: Text(
                                "Cancel".tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ));
  }

  Future showMoreInfo() {
    return showDialog(
      context: context,
      builder: (dialogContext) => WebAuthLayout.dialog(
        context: dialogContext,
        maxWidth: 480,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pricing Information",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          fontFamily: "Poppins"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 22),
                      onPressed: () => Navigator.pop(dialogContext),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Pricing info in rows
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard(
                        "💳", "Card Payment", "4% surcharge", context),
                    _buildInfoCard(
                        "⏳", "Waiting Time", "\$1 per minute", context),
                  ],
                ),

                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard(
                        "🛣️", "Extra Travel", "\$3 per km", context),
                    _buildInfoCard("💸️", "Prepaid Service",
                        "Taxi cards on Meter", context),
                  ],
                ),
                SizedBox(height: 8),

                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "— \$\$ extra for toll roads",
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontFamily: "Poppins"),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        "— Price compare as guide only and may NOT be 100% accurate",
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontFamily: "Poppins"),
                        textAlign: TextAlign.start,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Vehicle capacities section
                Text(
                  "Vehicle Capacities",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      fontFamily: "Poppins"),
                ),

                SizedBox(height: 12),

                Column(
                  children: [
                    _buildVehicleCapacity(
                        "🚗", "Sedan", "4 passengers + small luggage"),
                    SizedBox(height: 12),
                    Divider(),
                    _buildVehicleCapacity(
                        "🚙", "SUV", "4 passengers + extra space"),
                    SizedBox(height: 12),
                    Divider(),
                    _buildVehicleCapacity(
                        "🚐", "VAN", "Up to 10 passengers + extra space"),
                  ],
                ),

                SizedBox(height: 16),

                // Action button
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff019ba5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      elevation: 2,
                    ),
                    child: Text(
                      "Got it!",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: "Poppins"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String emoji, String title, String subtitle, BuildContext context) {
    return Container(
      width: WebAuthLayout.isWide(context)
          ? 150
          : MediaQuery.of(context).size.width * 0.35,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Poppins",
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
                fontSize: 13, color: Colors.grey[600], fontFamily: "Poppins"),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCapacity(String emoji, String type, String capacity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: TextStyle(fontSize: 20)),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    fontFamily: "Poppins"),
              ),
              SizedBox(height: 4),
              Text(
                capacity,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontFamily: "Poppins"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
