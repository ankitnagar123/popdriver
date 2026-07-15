import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';

import '../utils/colors.dart';

/// Web driver map — Google-like tiles, live GPS, markers & polylines (no JS API).
class WebDriverMap extends StatefulWidget {
  const WebDriverMap({
    super.key,
    required this.markers,
    required this.polylines,
    required this.center,
    required this.zoom,
    required this.topPadding,
  });

  final Set<gmaps.Marker> markers;
  final Set<gmaps.Polyline> polylines;
  final gmaps.LatLng center;
  final double zoom;
  final double topPadding;

  @override
  State<WebDriverMap> createState() => _WebDriverMapState();
}

class _WebDriverMapState extends State<WebDriverMap> {
  final MapController _mapController = MapController();
  gmaps.LatLng? _lastCenter;
  bool _userMovedMap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCamera(widget.center));
  }

  @override
  void didUpdateWidget(WebDriverMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasInvalid =
        oldWidget.center.latitude == 0 && oldWidget.center.longitude == 0;
    final nowValid = _hasValidCenter;
    if (wasInvalid && nowValid) {
      _userMovedMap = false;
      _lastCenter = null;
    }
    if (!_userMovedMap) {
      _syncCamera(widget.center);
    }
  }

  void _syncCamera(gmaps.LatLng target) {
    if (target.latitude == 0 && target.longitude == 0) return;
    if (_lastCenter != null) {
      final dLat = (target.latitude - _lastCenter!.latitude).abs();
      final dLng = (target.longitude - _lastCenter!.longitude).abs();
      if (dLat < 0.00003 && dLng < 0.00003) return;
    }
    _lastCenter = target;
    _mapController.move(
      LatLng(target.latitude, target.longitude),
      widget.zoom,
    );
  }

  void _recenterOnDriver() {
    setState(() => _userMovedMap = false);
    _syncCamera(widget.center);
  }

  bool get _hasValidCenter =>
      widget.center.latitude != 0 || widget.center.longitude != 0;

  LatLng get _mapCenter =>
      LatLng(widget.center.latitude, widget.center.longitude);

  List<Marker> _buildMarkers() {
    if (widget.markers.isNotEmpty) {
      return widget.markers.map((m) {
        final isPickup = m.markerId.value == '2';
        final isDriver = m.markerId.value == '1';
        return Marker(
          point: LatLng(m.position.latitude, m.position.longitude),
          width: isDriver ? 48 : 42,
          height: isDriver ? 48 : 42,
          child: isDriver
              ? Image.asset(
                  'assets/images/imagemarker.png',
                  fit: BoxFit.contain,
                )
              : Icon(
                  Icons.location_on,
                  size: 42,
                  color: isPickup ? Colors.blue : MyColors.primary,
                ),
        );
      }).toList();
    }

    if (_hasValidCenter) {
      return [
        Marker(
          point: _mapCenter,
          width: 48,
          height: 48,
          child: const _CurrentLocationPulse(),
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidCenter) {
      return Padding(
        padding: EdgeInsets.only(top: widget.topPadding),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Getting your location...'.tr,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                'Allow precise location in browser'.tr,
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
            ],
          ),
        ),
      );
    }

    final mapPolylines = widget.polylines.map((p) {
      return Polyline(
        points: p.points
            .map((pt) => LatLng(pt.latitude, pt.longitude))
            .toList(),
        color: p.color,
        strokeWidth: p.width.toDouble(),
      );
    }).toList();

    final mapMarkers = _buildMarkers();

    return Padding(
      padding: EdgeInsets.only(top: widget.topPadding),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: widget.zoom,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) _userMovedMap = true;
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.popdriver.app',
              ),
              if (mapPolylines.isNotEmpty)
                PolylineLayer(polylines: mapPolylines),
              if (_hasValidCenter)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _mapCenter,
                      radius: 28,
                      color: Colors.blue.withOpacity(0.15),
                      borderColor: Colors.blue.withOpacity(0.35),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              if (mapMarkers.isNotEmpty) MarkerLayer(markers: mapMarkers),
            ],
          ),
          if (_hasValidCenter)
            Positioned(
              right: 16,
              bottom: 24,
              child: FloatingActionButton.small(
                heroTag: 'web_map_recenter',
                backgroundColor: Colors.white,
                onPressed: _recenterOnDriver,
                child: Icon(Icons.my_location, color: MyColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentLocationPulse extends StatelessWidget {
  const _CurrentLocationPulse();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.2),
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.4),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
