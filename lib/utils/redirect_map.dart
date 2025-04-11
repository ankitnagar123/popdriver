import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MapUtils {

  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'google.navigation:q=$latitude,$longitude&mode=d';
    String AppleUrl  = '';
    String url = "";

    if(Platform.isAndroid){
      if (await canLaunchUrl(Uri.parse(googleUrl))) {
        await launchUrlString(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    }else if(Platform.isIOS){
      AppleUrl = 'https://maps.apple.com/?q=$latitude,$longitude';
      url = 'comgooglemaps://?saddr=&daddr=$latitude,$longitude&directionsmode=driving';
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