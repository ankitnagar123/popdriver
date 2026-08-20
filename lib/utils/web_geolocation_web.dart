import 'dart:async';
import 'dart:html' as html;

import 'web_geolocation_fix.dart';

Future<WebLatLngFix> getBrowserLocationImpl({
  Duration timeout = const Duration(seconds: 10),
}) async {
  final geo = html.window.navigator.geolocation;
  final pos = await geo
      .getCurrentPosition(
        enableHighAccuracy: false,
        timeout: timeout,
        maximumAge: const Duration(seconds: 60),
      )
      .timeout(
        timeout + const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('browser geolocation timed out');
        },
      );

  final coords = pos.coords;
  final lat = coords?.latitude;
  final lng = coords?.longitude;
  if (lat == null || lng == null) {
    throw StateError('geolocation returned empty coordinates');
  }

  return WebLatLngFix(
    latitude: lat.toDouble(),
    longitude: lng.toDouble(),
    accuracy: (coords?.accuracy ?? 0).toDouble(),
  );
}
