import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef DriverMapCreated = void Function(GoogleMapController controller);

/// Native Google Map — used on Android & iOS only (via conditional import).
Widget buildDriverHomeMap({
  required Set<Marker> markers,
  required Set<Polyline> polylines,
  required LatLng initialTarget,
  required double initialZoom,
  required double topPadding,
  required DriverMapCreated onMapCreated,
  VoidCallback? onCameraMoveStarted,
}) {
  return GoogleMap(
    key: const ValueKey('driver_home_map'),
    myLocationButtonEnabled: false,
    myLocationEnabled: false,
    zoomControlsEnabled: false,
    zoomGesturesEnabled: true,
    scrollGesturesEnabled: true,
    padding: EdgeInsets.only(top: topPadding),
    buildingsEnabled: true,
    cameraTargetBounds: CameraTargetBounds.unbounded,
    compassEnabled: true,
    indoorViewEnabled: false,
    mapToolbarEnabled: false,
    rotateGesturesEnabled: true,
    tiltGesturesEnabled: true,
    liteModeEnabled: false,
    minMaxZoomPreference: const MinMaxZoomPreference(3, 20),
    markers: markers,
    polylines: polylines,
    mapType: MapType.normal,
    onMapCreated: onMapCreated,
    onCameraMoveStarted: onCameraMoveStarted,
    initialCameraPosition: CameraPosition(
      target: initialTarget,
      zoom: initialZoom,
    ),
  );
}
