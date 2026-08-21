import 'web_geolocation_fix.dart';
import 'web_geolocation_stub.dart'
    if (dart.library.html) 'web_geolocation_web.dart';

Future<WebLatLngFix> getBrowserLocation({
  Duration timeout = const Duration(seconds: 10),
}) =>
    getBrowserLocationImpl(timeout: timeout);

Future<bool> isBrowserLocationPermissionGranted() =>
    isBrowserLocationPermissionGrantedImpl();
