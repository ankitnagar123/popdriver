import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'platform_helper.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    if (isWeb) {
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrlString(url, webOnlyWindowName: '_blank');
      }
      return;
    }

    String googleUrl = 'google.navigation:q=$latitude,$longitude&mode=d';
    String AppleUrl = '';
    String url = "";

    if (isAndroid) {
      if (await canLaunchUrl(Uri.parse(googleUrl))) {
        await launchUrlString(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    } else if (isIOS) {
      AppleUrl = 'https://maps.apple.com/?q=$latitude,$longitude';
      url =
          'comgooglemaps://?saddr=&daddr=$latitude,$longitude&directionsmode=driving';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrlString(url);
      } else if (await canLaunchUrl(Uri.parse(AppleUrl))) {
        await launchUrlString(AppleUrl);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
