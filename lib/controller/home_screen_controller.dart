import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mtaanidriver/controller/permision_controller.dart';
import '../Network/api_service.dart';
import '../Network/urls.dart';
import '../utils/shared_preferences.dart';

import 'auth_controller.dart';
import 'booking_controller.dart';

class HomeController extends GetxController {
  SecureStorageService secure = SecureStorageService();

  RxString arriveDriver = "".obs;
  RxBool driverArriveValue = false.obs;
  RxBool hide = false.obs;

  var bookingIndex = -1.obs;
  var polylineVariable = "".obs;
  var polylineVariable1 = "".obs;
  var polylineVariable2 = "".obs;
  var cancelIndex = -1.obs;
  RxBool onOff = false.obs;
  RxBool painButton = false.obs;
  var startLocation = LatLng(22.6832, 75.8576).obs;
  var endLocation = LatLng(22.636383, 75.810692).obs;
  late StreamSubscription<Position> streamSubscription;
  PolylinePoints polylinePoints = PolylinePoints();

  var markers = <Marker>[].obs;
  List<LatLng> polylineCoordinates = [];
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  ApiService apiService = ApiService();

  // var googleMapController = Rx<GoogleMapController?>(null);

  Rx<GoogleMapController?> googleMapController = Rx<GoogleMapController?>(null);
  Uint8List? _driverMarkerBytes;
  DateTime? _lastDriverLatLongSyncAt;
  DateTime? _lastRideRefreshAt;
  LatLng? _lastCameraTarget;
  bool _isListening = false;

  void setGoogleMapController(GoogleMapController controller) {
    googleMapController.value = controller;
  }

  void updateCameraPosition(LatLng location) {
    final controller = googleMapController.value;
    if (controller != null) {
      // Avoid over-animating camera on each GPS tick; it causes jitter on iOS.
      if (_lastCameraTarget != null) {
        final distance = Geolocator.distanceBetween(
          _lastCameraTarget!.latitude,
          _lastCameraTarget!.longitude,
          location.latitude,
          location.longitude,
        );
        if (distance < 8) return;
      }
      _lastCameraTarget = location;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 16,
          ),
        ),
      );
    }
  }

  @override
  void onClose() {
    try {
      stopListening();
    } catch (e) {
      print("Error in onClose: $e");
    }
    super.onClose();
  }

  @override
  void dispose() {
    try {
      stopListening();
    } catch (e) {
      print("Error in dispose: $e");
    }
    super.dispose();
  }

  // User location
  getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    startListening();
  }

  void startListening() {
    if (_isListening) return;
    _isListening = true;
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      print("listening -----");
      startLocation.value = LatLng(position.latitude, position.longitude);
      updateMarker(position);
      Data(position, Get.context!);
    });
  }

  void stopListening() {
    try {
      _isListening = false;
      streamSubscription.cancel().then((_) {
        try {
          Get.find<PermissionController>().mapSubscription?.cancel();
          Get.find<PermissionController>().mapSubscription = null;
          print("Position stream subscription cancelled");
        } catch (e) {
          print("Error cancelling map subscription: $e");
        }
      }).catchError((error) {
        print("Error cancelling position stream subscription: $error");
      });
    } catch (e) {
      print("Error in stopListening: $e");
    }
  }

/*
   Future<void> updateMarker(Position position) async {
      Uint8List imageData = await getMarkers();
      markers.clear();
      markers.add(Marker(
         markerId: MarkerId("1"),
         position: LatLng(position.latitude, position.longitude),
         rotation: position.heading,
         draggable: true,
         zIndex: 2,
         flat: true,
         anchor: Offset(0.5, 0.5),
         icon: BitmapDescriptor.fromBytes(imageData),
      ));
   }
*/

  Future<void> updateMarker(Position position) async {
    _driverMarkerBytes ??= await getMarkers();
    final marker =
        markers.firstWhereOrNull((m) => m.markerId == const MarkerId("1"));

    if (marker != null) {
      markers.remove(marker);
    }

    markers.add(Marker(
      markerId: const MarkerId("1"),
      position: LatLng(position.latitude, position.longitude),
      rotation: position.heading,
      draggable: true,
      zIndex: 2,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      icon: BitmapDescriptor.fromBytes(_driverMarkerBytes!),
    ));
  }

  Future<Uint8List> getMarkers() async {
    ByteData byteData = await rootBundle.load("assets/images/imagemarker.png");
    return byteData.buffer.asUint8List();
  }

  // User pickup Location Marker
  Future<void> userPickupMarker(BuildContext context) async {
    Uint8List imageData = await getMarker(context);
    markers.removeWhere((m) => m.markerId == const MarkerId("2"));
    markers.add(Marker(
      markerId: MarkerId("2"),
      position: endLocation.value,
      zIndex: 2,
      infoWindow: InfoWindow(
        title: 'User Current Location',
      ),
      icon: BitmapDescriptor.fromBytes(imageData),
    ));
  }

  // User pickup Location Marker
  Future<Uint8List> getMarker(BuildContext context) async {
    ByteData byteData = await DefaultAssetBundle.of(context)
        .load("assets/images/Picup_Marker.png");
    return byteData.buffer.asUint8List();
  }

  // Update Driver latLong.....
  void updateDriverLatLong(
      String lat, String long, String rotation, String status) async {
    Map<String, dynamic> latlong = {
      "driver_id": await secure.readData(secure.user_id),
      'lat': lat,
      "long": long,
      'rotation': rotation,
      'available_status': status,
    };

    log("update driver lat long ---->:$latlong");

    try {
      final response =
          await apiService.postData(URLS.DRIVER_LATLONG_UPDATE, latlong);
      var jsonString = jsonDecode(response.body);
      log("update driver latlong response ---->:$jsonString");
      var result = jsonString['result'];
      log("result------->:$result");
    } catch (e) {
      log('Exception-----', error: e.toString());
    }
  }

  Future<void> Data(Position position, BuildContext context) async {
    try {
      // Check if Google Map controller is available
      if (googleMapController.value != null) {
        updateCameraPosition(LatLng(position.latitude, position.longitude));
      }

      final now = DateTime.now();
      final shouldRefreshRideState = _lastRideRefreshAt == null ||
          now.difference(_lastRideRefreshAt!).inSeconds >= 8;
      if (shouldRefreshRideState) {
        _lastRideRefreshAt = now;
        var loginKey = await sp.getStringValue(sp.LOGIN_DEVICE_KEY.toString());
        var accessToken = await sp.getStringValue(sp.ACCESS_TOKEN.toString());
        var authController = Get.find<AuthController>();
        authController.loginCheck(loginKey.toString(), accessToken, context);
        Get.find<BookingController>().rideNowBooking();
        Get.find<BookingController>().userAcceptBooking();
      }

      if (onOff.value == true) {
        final shouldSyncDriver = _lastDriverLatLongSyncAt == null ||
            now.difference(_lastDriverLatLongSyncAt!).inSeconds >= 3;
        if (shouldSyncDriver) {
          _lastDriverLatLongSyncAt = now;
          updateDriverLatLong(
            position.latitude.toString(),
            position.longitude.toString(),
            position.heading.toString(),
            "Available",
          );
        }
      } else {
        updateDriverLatLong("0", "0", "0", "UnAvailable");
      }

      var bookingController = Get.find<BookingController>();
      startLocation.value = LatLng(position.latitude, position.longitude);

      if (hide.value == false) {
        // Do nothing if hide is false
      } else if (bookingController.useracceptmodel.bookingId != "") {
        bookingController.updateLatLongStartRide(
          bookingController.useracceptmodel.bookingId,
          position.latitude.toString(),
          position.longitude.toString(),
        );
      }

      if (bookingController.useracceptmodel.status != "") {
        userPickupMarker(context);
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
