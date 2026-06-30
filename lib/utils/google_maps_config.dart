import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Central Google Maps / Directions API keys (Android manifest + iOS Info.plist + web/index.html).
class GoogleMapsConfig {
  GoogleMapsConfig._();

  static const String androidApiKey = 'AIzaSyBRpd4WXkL8oX2TFYnVigpI7vq2e2YE5GY';
  static const String iosApiKey = 'AIzaSyCcprS9RpevBbo6bTsbazyhtR1QT_Cd_ys';
  static const String directionsApiKey = 'AIzaSyBl3QyASJ6PHcxGWf5i4hSXieIywYloOl0';

  /// Used in [web/index.html] — enable "Maps JavaScript API" for this key in Google Cloud.
  static const String webApiKey = 'AIzaSyBZ7GVlxPgOAdYFLQ8j0jJxDN4qPh0tnZk';

  static String get platformDirectionsKey {
    if (kIsWeb) return directionsApiKey;
    return defaultTargetPlatform == TargetPlatform.android
        ? directionsApiKey
        : iosApiKey;
  }
}
