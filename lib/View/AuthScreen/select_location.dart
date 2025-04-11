import 'dart:async';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';

import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/text_field.dart';
import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
import '../../utils/snackBar.dart';

import 'package:flutter/material.dart';
 import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
 import 'package:google_api_headers/google_api_headers.dart';

class SelectAddress extends StatefulWidget {
  const SelectAddress({Key? key}) : super(key: key);

  @override
  State<SelectAddress> createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  TextEditingController searchCtr = TextEditingController();
  final controllers = Get.find<AuthController>();
  Completer<GoogleMapController> _controller = Completer();

  String googleAPiKey = "AIzaSyAzLg4OtHIybajy2dzlcdrZ2APf3gqvdfg";

  /* String location = "";*/

  double? latitude;
  double? long;

  /* LatLng destLocation = LatLng(22.719568, 75.857727);*/

  Position? _currentPosition;
  Set<Marker> markers = Set();

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primary,
        title: Text("Select Address"),
        centerTitle: true,
      ),
      body: Obx(
        () {
          searchCtr.text = controllers.location.value;
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controllers.destLocation.value,
                  zoom: 14.4746,
                ),
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                myLocationEnabled: true,
                markers: Set<Marker>.of(markers),
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onCameraMove: (CameraPosition cameraPosition) {
                  if (controllers.destLocation.value != cameraPosition.target) {
                    controllers.destLocation.value = cameraPosition.target;
                  }
                },
                onCameraIdle: () async {
                  _getAddressFromLatLng();
                },
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 35.0),
                  child: Image.asset(
                    "assets/images/markercustome.png",
                    height: 45,
                    width: 45,
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                top: 20,
                child: Container(
                  height: 50,
                  width: context.width,
                  padding: const EdgeInsets.only(left: 10),
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      color: MyColors.white,
                      border: Border.all(color: MyColors.TextField, width: 1)),
                  child: TextFormField(
                    controller: searchCtr,
                    keyboardType: TextInputType.text,
                    onTap: () async {
                      var place = await PlacesAutocomplete.show(
                          context: context,
                          apiKey: googleAPiKey,
                          mode: Mode.overlay,
                          types: [],
                          strictbounds: false,
                          components: [],
                          onError: (err) {
                            print(err);
                          });
                      if (place != null) {
                        controllers.location.value =
                            place.description.toString();
                        print("location-------------" +
                            controllers.location.value);

                        final plist = GoogleMapsPlaces(
                          apiKey: googleAPiKey,
                          apiHeaders: await GoogleApiHeaders().getHeaders(),
                        );
                        String placeId = place.placeId ?? "0";
                        final detail = await plist.getDetailsByPlaceId(placeId);
                        final geometry = detail.result.geometry!;
                        latitude = geometry.location.lat;
                        long = geometry.location.lng;
                        controllers.destLocation.value =
                            LatLng(latitude!, long!);
                        print(
                            "destination----->:-${controllers.destLocation.value}");
                        CameraPosition cameraPosition = new CameraPosition(
                          target: LatLng(
                              controllers.destLocation.value.latitude,
                              controllers.destLocation.value.longitude),
                          zoom: 14,
                        );
                        final GoogleMapController controller =
                            await _controller.future;
                        controller.animateCamera(
                            CameraUpdate.newCameraPosition(cameraPosition));
                      }
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: "Select Your Location",
                        prefixIcon: Icon(
                          Icons.search,
                          color: MyColors.primary,
                        ),
                        hintStyle: const TextStyle(
                            color: MyColors.DarkBlue, fontSize: 12)),
                  ),
                ),
              ),
              Positioned(
                top: Get.height / 1.3,
                right: 50,
                left: 50,
                child: custom_buttons(
                  voidCallback: () {
                    var data = [
                      controllers.location.value,
                      controllers.destLocation.value.latitude,
                      controllers.destLocation.value.longitude,
                    ];
                    Get.back(
                      result: data,
                    );
                  },
                  text: "Done",
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void getLocation() async {
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
    _currentPosition = await Geolocator.getCurrentPosition();
    print("latitude------->:${_currentPosition!.latitude}");
    print("longitude------->:${_currentPosition!.longitude}");
    controllers.destLocation.value =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    CameraPosition cameraPosition = new CameraPosition(
      target: LatLng(controllers.destLocation.value.latitude,
          controllers.destLocation.value.longitude),
      zoom: 16,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<void> _getAddressFromLatLng() async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(
        controllers.destLocation.value.latitude,
        controllers.destLocation.value.longitude,
        localeIdentifier: "en");
    print(placeMarks);

    Placemark place = placeMarks[0];
    controllers.location.value =
        '${place.subLocality},${place.locality},${place.administrativeArea},${place.postalCode}, ${place.country}';
    print("destination ------>:${controllers.location.value}");
  }
}
