import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:geolocator/geolocator.dart';

import 'platform_helper.dart';

/// Platform-specific geolocation settings for the driver app.
LocationSettings driverLocationSettings({
  Duration? timeLimit,
  bool enableForegroundService = false,
}) {
  if (kIsWeb) {
    return WebSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      maximumAge: Duration.zero,
      timeLimit: timeLimit ?? const Duration(seconds: 20),
    );
  }
  if (isAndroid && enableForegroundService) {
    return AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
      timeLimit: timeLimit,
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'POP Driver',
        notificationText: 'You are online — waiting for ride requests',
        notificationIcon: AndroidResource(
          name: 'ic_launcher',
          defType: 'mipmap',
        ),
        enableWakeLock: true,
      ),
    );
  }
  return LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 5,
    timeLimit: timeLimit,
  );
}

/// Web fallback when high-accuracy GPS times out (common on laptop + Wi‑Fi).
LocationSettings driverLocationFallbackSettings({Duration? timeLimit}) {
  if (kIsWeb) {
    return WebSettings(
      accuracy: LocationAccuracy.medium,
      maximumAge: const Duration(seconds: 60),
      timeLimit: timeLimit ?? const Duration(seconds: 15),
    );
  }
  return LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
    timeLimit: timeLimit,
  );
}

/// Fetch driver position — retries with lower accuracy on web if needed.
Future<Position> getDriverPosition({Duration? timeLimit}) async {
  final limit = timeLimit ?? const Duration(seconds: 20);

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: driverLocationSettings(timeLimit: limit),
    );
    if (kIsWeb) {
      debugPrint(
        '[LOCATION] GPS fix: ${position.latitude}, ${position.longitude} '
        'accuracy=${position.accuracy.round()}m',
      );
    }
    return position;
  } catch (highAccuracyError) {
    if (!kIsWeb) rethrow;

    debugPrint('[LOCATION] high-accuracy failed: $highAccuracyError — trying medium');
    final position = await Geolocator.getCurrentPosition(
      locationSettings: driverLocationFallbackSettings(timeLimit: limit),
    );
    debugPrint(
      '[LOCATION] fallback fix: ${position.latitude}, ${position.longitude} '
      'accuracy=${position.accuracy.round()}m',
    );
    return position;
  }
}
