import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'colors.dart';

String googleAPiKey = "AIzaSyBl3QyASJ6PHcxGWf5i4hSXieIywYloOl0";
String googleAPiKeyIos = "AIzaSyCcprS9RpevBbo6bTsbazyhtR1QT_Cd_ys";

/// **Bypass billing:** when `false`, no Google Directions HTTP call → **$0** Directions cost.
/// Road-following polyline ke liye build:  
/// `flutter run --dart-define=USE_GOOGLE_DIRECTIONS=true`
const bool _useGoogleDirections = bool.fromEnvironment(
  'USE_GOOGLE_DIRECTIONS',
  defaultValue: false,
);

Map<PolylineId, Polyline> polyline = {};
List<LatLng> polylineCoordinates = [];
final PolylinePoints polylinePoints = PolylinePoints();

String get _directionsApiKey =>
    defaultTargetPlatform == TargetPlatform.android ? googleAPiKey : googleAPiKeyIos;

/// Free path: interpolated great-circle points so the line looks smooth (no paid API).
List<LatLng> _freeGeodesicPath(LatLng start, LatLng end, {int segments = 24}) {
  if (segments < 2) return [start, end];
  final out = <LatLng>[];
  final lat1 = start.latitude * math.pi / 180;
  final lon1 = start.longitude * math.pi / 180;
  final lat2 = end.latitude * math.pi / 180;
  final lon2 = end.longitude * math.pi / 180;
  final d = 2 *
      math.asin(math.min(
        1.0,
        math.sqrt(
          math.pow(math.sin((lat2 - lat1) / 2), 2) +
              math.cos(lat1) * math.cos(lat2) * math.pow(math.sin((lon2 - lon1) / 2), 2),
        ),
      ));
  if (d < 1e-8) return [start, end];
  final sinD = math.sin(d);
  for (var i = 0; i <= segments; i++) {
    final f = i / segments;
    final a = math.sin((1 - f) * d) / sinD;
    final b = math.sin(f * d) / sinD;
    final x = a * math.cos(lat1) * math.cos(lon1) + b * math.cos(lat2) * math.cos(lon2);
    final y = a * math.cos(lat1) * math.sin(lon1) + b * math.cos(lat2) * math.sin(lon2);
    final z = a * math.sin(lat1) + b * math.sin(lat2);
    final lat = math.atan2(z, math.sqrt(x * x + y * y));
    final lon = math.atan2(y, x);
    out.add(LatLng(lat * 180 / math.pi, lon * 180 / math.pi));
  }
  return out;
}

Future<List<LatLng>?> _applyFreeRoute(LatLng start, LatLng end) async {
  final path = _freeGeodesicPath(start, end);
  polylineCoordinates = List<LatLng>.from(path);
  polyline.clear();
  addPolyLine(path, isFallback: true);
  log(
    "getPolyLine: FREE mode (no Google Directions) — straight/geodesic path. "
    "Zero Directions billing. For road routes use --dart-define=USE_GOOGLE_DIRECTIONS=true + enable API.",
  );
  return path;
}

/// Fetches route and updates [polyline].
/// Default: **free** geodesic path (no Directions API, no charge).
/// Paid road route: `USE_GOOGLE_DIRECTIONS=true` + Directions API enabled in GCP.
Future<List<LatLng>?> getPolyLine(LatLng start, LatLng end) async {
  if (!_useGoogleDirections) {
    return _applyFreeRoute(start, end);
  }

  log("getPolyLine: requesting Google Directions (paid API)");
  try {
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: _directionsApiKey,
      request: PolylineRequest(
        origin: PointLatLng(start.latitude, start.longitude),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates = [];
      polyline.clear();
      for (final point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      final copy = List<LatLng>.from(polylineCoordinates);
      addPolyLine(copy, isFallback: false);
      return copy;
    }
    log("getPolyLine: empty polyline — ${result.errorMessage}");
  } catch (e, st) {
    log("getPolyLine error", error: e, stackTrace: st);
  }

  log("getPolyLine: Directions failed — falling back to free geodesic path");
  return _applyFreeRoute(start, end);
}

void addPolyLine(List<LatLng> routePoints, {bool isFallback = false}) {
  const id = PolylineId("active_route");
  final polylines = Polyline(
    polylineId: id,
    color: isFallback ? MyColors.primary : MyColors.black,
    patterns: isFallback ? [PatternItem.dash(18), PatternItem.gap(12)] : [],
    points: routePoints,
    width: isFallback ? 4 : 5,
    geodesic: true,
    jointType: JointType.round,
    startCap: Cap.roundCap,
    endCap: Cap.roundCap,
  );
  polyline[id] = polylines;
}
