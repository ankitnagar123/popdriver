import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'driver_home_map_mobile.dart'
    if (dart.library.html) 'driver_home_map_web.dart' as map_impl;

/// Home-screen map widget.
/// - **Mobile (Android/iOS):** native [GoogleMap]
/// - **Web:** [GoogleMap] via Maps JavaScript API ([web/index.html])
class DriverHomeMap extends StatefulWidget {
  const DriverHomeMap({
    super.key,
    required this.markers,
    required this.polylines,
    required this.initialTarget,
    required this.initialZoom,
    required this.topPadding,
    required this.onMapCreated,
    this.onCameraMoveStarted,
    this.onMapDisposed,
  });

  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final LatLng initialTarget;
  final double initialZoom;
  final double topPadding;
  final void Function(GoogleMapController controller) onMapCreated;
  final VoidCallback? onCameraMoveStarted;
  final VoidCallback? onMapDisposed;

  @override
  State<DriverHomeMap> createState() => _DriverHomeMapState();
}

class _DriverHomeMapState extends State<DriverHomeMap> {
  @override
  void dispose() {
    // GoogleMap platform view is gone — drop channel so GPS sync
    // cannot call animateCamera on a dead pigeon connection.
    widget.onMapDisposed?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return map_impl.buildDriverHomeMap(
      markers: widget.markers,
      polylines: widget.polylines,
      initialTarget: widget.initialTarget,
      initialZoom: widget.initialZoom,
      topPadding: widget.topPadding,
      onMapCreated: widget.onMapCreated,
      onCameraMoveStarted: widget.onCameraMoveStarted,
    );
  }
}
