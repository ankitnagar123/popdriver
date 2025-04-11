import 'dart:developer';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'colors.dart';
/*List<LatLng> polyList = [];
bool internet = true;
String googleAPiKey = "AIzaSyBl3QyASJ6PHcxGWf5i4hSXieIywYloOl0";
//String googleAPiKey = "AIzaSyC4YRWY4K4mNXpNJ30k1e8SIqUuJW7p_wI";
String googleAPiKeyIos = "AIzaSyCcprS9RpevBbo6bTsbazyhtR1QT_Cd_ys";
//String googleAPiKeyIos = "AIzaSyC4YRWY4K4mNXpNJ30k1e8SIqUuJW7p_wI";
getPolylines(LatLng pickUp,LatLng drop,) async {
  print("polyline -------------------------");
  polyList.clear();
  String pickLat = '';
  String pickLng = '';
  String dropLat = '';
  String dropLng = '';

  pickLat = pickUp.latitude.toString();
  pickLng = pickUp.longitude.toString();
  dropLat = drop.latitude.toString();
  dropLng = drop.longitude.toString();

  try {

    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&key=${Platform.isAndroid?googleAPiKey:googleAPiKeyIos}'));

      print("poly line handler>${response.body}");
    if (response.statusCode == 200) {
      var steps = jsonDecode(response.body)['routes'][0]['overview_polyline']['points'];
     print("polyline response ---${steps}");
      decodeEncodedPolyline(steps);
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return polyList;
}

//polyline decode

Set<Polyline> polyline = {};

List<PointLatLng> decodeEncodedPolyline(String encoded) {
  List<PointLatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;
  polyline.clear();

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    polyList.add(p);
  }

  polyline.add(
    Polyline(
        polylineId: const PolylineId('1'),
        color: Colors.black,
        visible: true,
        width: 4,
        points: polyList),
  );

  return poly;
}

class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
  // ignore: unnecessary_null_comparison
      : assert(latitude != null),
  // ignore: unnecessary_null_comparison
        assert(longitude != null),
  // ignore: unnecessary_this, prefer_initializing_formals
        this.latitude = latitude,
  // ignore: unnecessary_this, prefer_initializing_formals
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}*/
/*Set<Polyline> polyline = {};*/
String googleAPiKey = "AIzaSyBl3QyASJ6PHcxGWf5i4hSXieIywYloOl0";
String googleAPiKeyIos = "AIzaSyCcprS9RpevBbo6bTsbazyhtR1QT_Cd_ys";
Map<PolylineId, Polyline> polyline = {};
List<LatLng> polylineCoordinates = [];
PolylinePoints polylinePoints = PolylinePoints();
 getPolyLine(LatLng start,LatLng end) async {
      log("vishnu 2 ==============");
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
         googleApiKey: googleAPiKey,
        request: PolylineRequest(
          origin: PointLatLng(start.latitude, start.longitude),
          destination: PointLatLng(end.latitude, end.longitude),
          mode: TravelMode.driving,
          //wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
        ),
      );
      if (result.points.isNotEmpty)
      {
         polylineCoordinates.clear();
         polyline.clear();
         polyline.remove(polyline);
         result.points.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
         });
      } else {
         print(result.errorMessage);
      }
      addPolyLine(polylineCoordinates);
   }


// PolyLines....
   addPolyLine(List<LatLng> polylineCoordinates) {
      print("vishnu----");
      PolylineId id = PolylineId("poly");
      Polyline polylines = Polyline(
         polylineId: id,
         color: MyColors.black,
         points: polylineCoordinates,
         width: 3,
      );
      polyline[id] = polylines;
   }