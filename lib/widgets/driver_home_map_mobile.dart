import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'web_driver_map.dart';

typedef DriverMapCreated = void Function(GoogleMapController controller);

/// Native Google Map on Android; [WebDriverMap] on iOS when Google Maps tiles
/// fail to load (misconfigured `GMSApiKey` / Maps SDK for iOS in GCP).
Widget buildDriverHomeMap({
  required Set<Marker> markers,
  required Set<Polyline> polylines,
  required LatLng initialTarget,
  required double initialZoom,
  required double topPadding,
  required DriverMapCreated onMapCreated,
  VoidCallback? onCameraMoveStarted,
}) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return WebDriverMap(
      markers: markers,
      polylines: polylines,
      center: initialTarget,
      zoom: initialZoom,
      topPadding: topPadding,
    );
  }

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
