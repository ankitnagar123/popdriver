import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'driver_home_map_mobile.dart'
    if (dart.library.html) 'driver_home_map_web.dart' as map_impl;

/// Home-screen map widget.
/// - **Mobile (Android/iOS):** native [GoogleMap]
/// - **Web:** [GoogleMap] via Maps JavaScript API ([web/index.html])
class DriverHomeMap extends StatelessWidget {
  const DriverHomeMap({
    super.key,
    required this.markers,
    required this.polylines,
    required this.initialTarget,
    required this.initialZoom,
    required this.topPadding,
    required this.onMapCreated,
  });

  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final LatLng initialTarget;
  final double initialZoom;
  final double topPadding;
  final void Function(GoogleMapController controller) onMapCreated;

  @override
  Widget build(BuildContext context) {
    return map_impl.buildDriverHomeMap(
      markers: markers,
      polylines: polylines,
      initialTarget: initialTarget,
      initialZoom: initialZoom,
      topPadding: topPadding,
      onMapCreated: onMapCreated,
    );
  }
}
