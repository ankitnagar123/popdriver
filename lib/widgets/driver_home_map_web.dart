import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Google Map on web — requires Maps JavaScript API script in [web/index.html].
Widget buildDriverHomeMap({
  required Set<Marker> markers,
  required Set<Polyline> polylines,
  required LatLng initialTarget,
  required double initialZoom,
  required double topPadding,
  required void Function(GoogleMapController controller) onMapCreated,
  VoidCallback? onCameraMoveStarted,
}) {
  final hasTarget = initialTarget.latitude != 0 || initialTarget.longitude != 0;

  // Stable key — never include lat/lng. Changing the key remounts the whole
  // Maps JS view and causes blink/flicker on every GPS tick (Chrome/Edge/Safari).
  return GoogleMap(
    key: const ValueKey('driver_home_map_web'),
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
      zoom: hasTarget ? initialZoom : 5,
    ),
  );
}
