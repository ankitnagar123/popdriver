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
      accuracy: LocationAccuracy.high,
      maximumAge: const Duration(seconds: 30),
      timeLimit: timeLimit ?? const Duration(seconds: 12),
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
  if (kIsWeb) {
    final mediumLimit = timeLimit ?? const Duration(seconds: 10);
    try {
      // Laptop / Chrome: medium + cached fix is enough to go Online.
      // High-accuracy GPS often times out on Wi‑Fi and looks like a stuck toggle.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: driverLocationFallbackSettings(timeLimit: mediumLimit),
      );
      debugPrint(
        '[LOCATION] GPS fix: ${position.latitude}, ${position.longitude} '
        'accuracy=${position.accuracy.round()}m',
      );
      return position;
    } catch (mediumError) {
      debugPrint('[LOCATION] medium failed: $mediumError — trying high');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: driverLocationSettings(
          timeLimit: const Duration(seconds: 12),
        ),
      );
      debugPrint(
        '[LOCATION] high fix: ${position.latitude}, ${position.longitude} '
        'accuracy=${position.accuracy.round()}m',
      );
      return position;
    }
  }

  final limit = timeLimit ?? const Duration(seconds: 20);
  return Geolocator.getCurrentPosition(
    locationSettings: driverLocationSettings(timeLimit: limit),
  );
}
