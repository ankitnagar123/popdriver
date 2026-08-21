import 'web_geolocation_fix.dart';

Future<WebLatLngFix> getBrowserLocationImpl({
  Duration timeout = const Duration(seconds: 10),
}) {
  throw UnsupportedError('Browser geolocation is web-only');
}

Future<bool> isBrowserLocationPermissionGrantedImpl() async => false;
