import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mtaanidriver/controller/permision_controller.dart';
import '../Network/api_service.dart';
import '../Network/urls.dart';
import '../utils/colors.dart';
import '../utils/driver_location_settings.dart';
import '../utils/shared_preferences.dart';

import 'auth_controller.dart';
import 'booking_controller.dart';

class HomeController extends GetxController {
  SecureStorageService secure = SecureStorageService();

  RxString arriveDriver = "".obs;
  RxBool driverArriveValue = false.obs;
  RxBool hide = false.obs;

  var bookingIndex = -1.obs;
  var polylineVariable = "".obs;
  var polylineVariable1 = "".obs;
  var polylineVariable2 = "".obs;
  var cancelIndex = -1.obs;
  RxBool onOff = false.obs;
  RxBool painButton = false.obs;
  var startLocation = const LatLng(0, 0).obs;
  final RxBool hasValidLocation = false.obs;
  var endLocation = LatLng(22.636383, 75.810692).obs;
  late StreamSubscription<Position> streamSubscription;
  PolylinePoints polylinePoints = PolylinePoints();

  var markers = <Marker>[].obs;
  List<LatLng> polylineCoordinates = [];
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  ApiService apiService = ApiService();

  // var googleMapController = Rx<GoogleMapController?>(null);

  Rx<GoogleMapController?> googleMapController = Rx<GoogleMapController?>(null);
  Uint8List? _driverMarkerBytes;
  DateTime? _lastDriverLatLongSyncAt;
  DateTime? _lastRideRefreshAt;
  DateTime? _lastPenaltyDialogAt;
  DateTime? _lastBookingFetchAfterLatLong;
  DateTime? _penaltyUntil;
  Timer? _penaltyExpiryTimer;
  Timer? _webLocationSyncTimer;
  bool _wasOnlineBeforePenalty = false;
  LatLng? _lastCameraTarget;
  bool _isListening = false;

  /// Bump so `HomeScreen` rebuilds polylines after async Directions fetch.
  final RxInt mapPolylineEpoch = 0.obs;
  final RxInt penaltyRemainingSeconds = 0.obs;

  void setGoogleMapController(GoogleMapController controller) {
    googleMapController.value = controller;
  }

  void updateCameraPosition(LatLng location) {
    if (location.latitude == 0 && location.longitude == 0) return;

    final controller = googleMapController.value;
    if (controller != null) {
      if (_lastCameraTarget != null) {
        final distance = Geolocator.distanceBetween(
          _lastCameraTarget!.latitude,
          _lastCameraTarget!.longitude,
          location.latitude,
          location.longitude,
        );
        if (distance < 8) return;
      }
      _lastCameraTarget = location;
      try {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: location,
              zoom: 16,
            ),
          ),
        );
      } on PlatformException catch (e) {
        log('animateCamera skipped: ${e.message}');
      } catch (e) {
        log('animateCamera skipped: $e');
      }
    }
  }

  /// Called after the route polyline is decoded so the map refreshes and fits the path.
  void onRoutePolylineReady(List<LatLng> points) {
    if (points.isEmpty) return;
    mapPolylineEpoch.value++;
    _fitCameraToRoute(points);
  }

  void _fitCameraToRoute(List<LatLng> points) {
    final mapCtl = googleMapController.value;
    if (mapCtl == null || points.length < 2) return;
    try {
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;
      for (final p in points) {
        minLat = minLat < p.latitude ? minLat : p.latitude;
        maxLat = maxLat > p.latitude ? maxLat : p.latitude;
        minLng = minLng < p.longitude ? minLng : p.longitude;
        maxLng = maxLng > p.longitude ? maxLng : p.longitude;
      }
      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      mapCtl.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } on PlatformException catch (e) {
      log('fitCameraToRoute skipped: ${e.message}');
    } catch (e) {
      log('fitCameraToRoute skipped: $e');
    }
  }

  @override
  void onClose() {
    _penaltyExpiryTimer?.cancel();
    _stopWebLocationSyncTimer();
    try {
      stopListening();
    } catch (e) {
      print("Error in onClose: $e");
    }
    super.onClose();
  }

  @override
  void dispose() {
    _penaltyExpiryTimer?.cancel();
    _stopWebLocationSyncTimer();
    try {
      stopListening();
    } catch (e) {
      print("Error in dispose: $e");
    }
    super.dispose();
  }

  /// Call when driver manually goes offline — don't auto-restore after penalty.
  void clearPenaltyAutoRestore() {
    _wasOnlineBeforePenalty = false;
    _penaltyExpiryTimer?.cancel();
  }

  // User location — on web, call [ensureLocationFromUserGesture] from Online toggle.
  Future<void> getLocation() async {
    if (!kIsWeb) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        log('[LOCATION] device location services disabled');
        return;
      }
    }

    final permission = await _requestLocationPermission();
    if (permission == null) return;

    startListening();
    await _fetchInitialPosition();
  }

  Future<LocationPermission?> _requestLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (kIsWeb) {
      debugPrint('[LOCATION] permission check: $permission');
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (kIsWeb) {
        debugPrint('[LOCATION] permission after request: $permission');
      }
    }
    if (permission == LocationPermission.denied) {
      log('[LOCATION] permission denied');
      if (kIsWeb) {
        debugPrint(
          '[LOCATION] Allow location: Chrome lock icon → Site settings → Location → Allow',
        );
      }
      return null;
    }
    if (permission == LocationPermission.deniedForever) {
      log('[LOCATION] permission denied forever');
      return null;
    }
    return permission;
  }

  Future<void> _fetchInitialPosition() async {
    if (hasValidLocation.value) return;
    try {
      final position = await getDriverPosition(
        timeLimit: const Duration(seconds: 25),
      );
      applyLivePosition(position, recenterMap: onOff.value);
      if (onOff.value) {
        _syncDriverAvailability(
          position,
          Get.overlayContext ?? Get.context,
        );
      }
    } catch (e) {
      log('[LOCATION] initial fix failed: $e');
      if (kIsWeb) debugPrint('[LOCATION] initial fix failed: $e');
    }
  }

  /// Must be called from a user tap (Online toggle) — browsers block GPS otherwise.
  Future<bool> ensureLocationFromUserGesture() async {
    if (hasValidLocation.value) return true;

    if (kIsWeb) {
      debugPrint('[LOCATION] requesting GPS from user gesture...');
    }
    final permission = await _requestLocationPermission();
    if (permission == null) return false;

    if (!_isListening) {
      startListening();
    }

    try {
      final position = await getDriverPosition(
        timeLimit: const Duration(seconds: 25),
      );
      applyLivePosition(position, recenterMap: true);
      _syncDriverAvailability(
        position,
        Get.overlayContext ?? Get.context,
      );
      return true;
    } catch (e) {
      log('[LOCATION] user-gesture GPS failed: $e');
      if (kIsWeb) debugPrint('[LOCATION] user-gesture GPS failed: $e');
      return hasValidLocation.value;
    }
  }

  Future<bool> waitForValidLocation({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (hasValidLocation.value) return true;
    await _fetchInitialPosition();
    if (hasValidLocation.value) return true;

    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (hasValidLocation.value) return true;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return hasValidLocation.value;
  }

  void startListening() {
    if (_isListening) return;
    _isListening = true;
    streamSubscription = Geolocator.getPositionStream(
      locationSettings: driverLocationSettings(),
    ).listen(
      (Position position) {
        applyLivePosition(position);
        final ctx = Get.overlayContext ?? Get.context;
        _syncDriverAvailability(position, ctx);
        if (ctx != null) {
          Data(position, ctx);
        }
      },
      onError: (Object e) {
        log('[LOCATION] stream error: $e');
        if (kIsWeb) debugPrint('[LOCATION] stream error: $e');
      },
    );
    if (kIsWeb) {
      _startWebLocationSyncTimer();
    }
  }

  void _startWebLocationSyncTimer() {
    if (!kIsWeb) return;
    _webLocationSyncTimer?.cancel();
    _webLocationSyncTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!onOff.value || !hasValidLocation.value) return;
      final loc = startLocation.value;
      if (loc.latitude == 0 && loc.longitude == 0) return;
      syncLocationFromLatLng(loc.latitude, loc.longitude);
    });
  }

  void _stopWebLocationSyncTimer() {
    _webLocationSyncTimer?.cancel();
    _webLocationSyncTimer = null;
  }

  void syncLocationFromLatLng(
    double latitude,
    double longitude, {
    double heading = 0,
  }) {
    _syncDriverAvailability(
      Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: heading,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
      Get.overlayContext ?? Get.context,
    );
  }

  /// Push GPS to server as Available, then refresh booking list (web needs this).
  Future<void> goOnlineAndSyncLocation(BuildContext context) async {
    try {
      if (!hasValidLocation.value) {
        final located = await ensureLocationFromUserGesture();
        if (!located && kIsWeb) {
          debugPrint('[LOCATION] online without GPS — allow browser location');
        }
      }
      if (!_isListening) {
        await getLocation();
      }

      if (hasValidLocation.value) {
        _lastCameraTarget = null;
        updateCameraPosition(startLocation.value);
        updateDriverLatLong(
          startLocation.value.latitude.toString(),
          startLocation.value.longitude.toString(),
          '0',
          'Available',
          context: context,
        );
      }
    } catch (e) {
      log('goOnlineAndSyncLocation failed: $e');
    }
    await Get.find<BookingController>().refreshAfterGoingOnline();
  }

  void applyLivePosition(Position position, {bool recenterMap = false}) {
    if (position.latitude == 0 && position.longitude == 0) return;
    if (recenterMap) _lastCameraTarget = null;
    hasValidLocation.value = true;
    if (kIsWeb && position.accuracy > 1000) {
      log('Web location ~${position.accuracy.round()}m accurate — turn on precise location in browser & Windows');
    }
    startLocation.value = LatLng(position.latitude, position.longitude);
    updateMarker(position);
    updateCameraPosition(startLocation.value);
    if (onOff.value) {
      _syncDriverAvailability(
        position,
        Get.overlayContext ?? Get.context,
      );
    }
  }

  void stopListening() {
    _stopWebLocationSyncTimer();
    try {
      _isListening = false;
      streamSubscription.cancel().then((_) {
        try {
          Get.find<PermissionController>().mapSubscription?.cancel();
          Get.find<PermissionController>().mapSubscription = null;
          print("Position stream subscription cancelled");
        } catch (e) {
          print("Error cancelling map subscription: $e");
        }
      }).catchError((error) {
        print("Error cancelling position stream subscription: $error");
      });
    } catch (e) {
      print("Error in stopListening: $e");
    }
  }

/*
   Future<void> updateMarker(Position position) async {
      Uint8List imageData = await getMarkers();
      markers.clear();
      markers.add(Marker(
         markerId: MarkerId("1"),
         position: LatLng(position.latitude, position.longitude),
         rotation: position.heading,
         draggable: true,
         zIndex: 2,
         flat: true,
         anchor: Offset(0.5, 0.5),
         icon: BitmapDescriptor.fromBytes(imageData),
      ));
   }
*/

  Future<void> updateMarker(Position position) async {
    BitmapDescriptor icon;
    try {
      _driverMarkerBytes ??= await getMarkers();
      icon = BitmapDescriptor.bytes(_driverMarkerBytes!);
    } catch (e) {
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    final marker =
        markers.firstWhereOrNull((m) => m.markerId == const MarkerId("1"));

    if (marker != null) {
      markers.remove(marker);
    }

    markers.add(Marker(
      markerId: const MarkerId("1"),
      position: LatLng(position.latitude, position.longitude),
      rotation: position.heading,
      draggable: false,
      zIndexInt: 2,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      icon: icon,
    ));
    markers.refresh();
  }

  Future<Uint8List> getMarkers() async {
    ByteData byteData = await rootBundle.load("assets/images/imagemarker.png");
    return byteData.buffer.asUint8List();
  }

  // User pickup Location Marker
  Future<void> userPickupMarker(BuildContext context) async {
    Uint8List imageData = await getMarker(context);
    markers.removeWhere((m) => m.markerId == const MarkerId("2"));
    markers.add(Marker(
      markerId: MarkerId("2"),
      position: endLocation.value,
      zIndex: 2,
      infoWindow: InfoWindow(
        title: 'User Current Location',
      ),
      icon: BitmapDescriptor.fromBytes(imageData),
    ));
  }

  // User pickup Location Marker
  Future<Uint8List> getMarker(BuildContext context) async {
    ByteData byteData = await DefaultAssetBundle.of(context)
        .load("assets/images/Picup_Marker.png");
    return byteData.buffer.asUint8List();
  }

  // Update Driver latLong.....
  Future<String?> _resolveDriverId() async {
    var id = await secure.readData(secure.user_id);
    if (id != null && id.isNotEmpty) return id;
    if (!kIsWeb) return null;

    for (var i = 0; i < 12; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      id = await secure.readData(secure.user_id);
      if (id != null && id.isNotEmpty) return id;
    }
    return null;
  }

  void updateDriverLatLong(
    String lat,
    String long,
    String rotation,
    String status, {
    BuildContext? context,
  }) async {
    final driverId = await _resolveDriverId();
    if (driverId == null || driverId.isEmpty) {
      log('[LOCATION] skipped — driver_id missing (lat=$lat long=$long)');
      if (kIsWeb) {
        debugPrint(
          '[LOCATION] skipped update_driver_latlong — driver_id not ready',
        );
      }
      return;
    }

    final latlong = <String, dynamic>{
      "driver_id": driverId,
      'lat': lat,
      "long": long,
      'rotation': rotation,
      'available_status': status,
    };

    log('[LOCATION] server sync: lat=$lat long=$long status=$status');
    log("update driver lat long ---->:$latlong");

    try {
      final response =
          await apiService.postData(URLS.DRIVER_LATLONG_UPDATE, latlong);
      if (kIsWeb) {
        debugPrint(
          '[LOCATION] update_driver_latlong status=${response.statusCode} '
          'body=${response.body.trim().isEmpty ? "(empty)" : response.body.trim()}',
        );
      }
      if (response.statusCode == 429) return;
      final body = response.body.trim();
      if (body.isEmpty || body.startsWith("<")) return;
      final decoded = jsonDecode(body);
      if (decoded is! Map) return;
      final data = Map<String, dynamic>.from(decoded);
      log("update driver latlong response ---->:$data");
      log("result------->:${data['result']}");
      _handleLatLongResponse(data, context: context);

      if (onOff.value && status == 'Available') {
        final now = DateTime.now();
        if (_lastBookingFetchAfterLatLong == null ||
            now.difference(_lastBookingFetchAfterLatLong!).inSeconds >= 8) {
          _lastBookingFetchAfterLatLong = now;
          Get.find<BookingController>().rideNowBooking();
        }
      }
    } catch (e) {
      log('Exception-----', error: e.toString());
    }
  }

  bool _isUnavailableStatus(String? status) {
    final normalized = (status ?? '').trim().toLowerCase().replaceAll(' ', '');
    return normalized == 'unavailable';
  }

  bool isPenaltyActive() {
    if (_penaltyUntil == null) return false;
    return DateTime.now().isBefore(_penaltyUntil!);
  }

  int _remainingPenaltySeconds() {
    if (_penaltyUntil == null) return 0;
    final remaining = _penaltyUntil!.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  String _penaltyMessage([int? seconds]) {
    final remaining = seconds ?? _remainingPenaltySeconds();
    if (remaining >= 3600) {
      final hours = remaining ~/ 3600;
      final minutes = (remaining % 3600) ~/ 60;
      return 'You are unavailable due to penalty. Try again in @hours h @minutes m'
          .trParams({'hours': '$hours', 'minutes': '$minutes'});
    }
    if (remaining >= 60) {
      return 'You are unavailable due to penalty. Try again in @minutes min'
          .trParams({'minutes': '${remaining ~/ 60}'});
    }
    return 'You are unavailable due to penalty. Try again in @seconds sec'
        .trParams({'seconds': '$remaining'});
  }

  void _applyPenaltyFromBackend(int penaltySeconds) {
    _penaltyExpiryTimer?.cancel();
    penaltyRemainingSeconds.value = penaltySeconds;
    if (penaltySeconds > 0) {
      _penaltyUntil = DateTime.now().add(Duration(seconds: penaltySeconds));
      _penaltyExpiryTimer = Timer(Duration(seconds: penaltySeconds), () {
        if (!isPenaltyActive()) {
          _onPenaltyCleared();
        }
      });
    } else {
      _penaltyUntil = null;
    }
  }

  void _onPenaltyCleared({BuildContext? context, Position? position}) {
    _penaltyExpiryTimer?.cancel();
    _penaltyUntil = null;
    penaltyRemainingSeconds.value = 0;

    if (!_wasOnlineBeforePenalty) return;
    _wasOnlineBeforePenalty = false;

    onOff.value = true;
    sp.setBoolValue(sp.DRIVER_ONLINE_STATUS, true);
    Get.find<BookingController>().rideNowBooking();

    if (position != null) {
      _lastDriverLatLongSyncAt = null;
      updateDriverLatLong(
        position.latitude.toString(),
        position.longitude.toString(),
        position.heading.toString(),
        'Available',
        context: context,
      );
    }

    log('Penalty cleared — driver restored to online');
  }

  void _showPenaltyDialog({
    required String message,
    BuildContext? context,
    bool isPenalty = true,
  }) {
    final now = DateTime.now();
    if (_lastPenaltyDialogAt != null &&
        now.difference(_lastPenaltyDialogAt!).inSeconds < 30) {
      return;
    }
    _lastPenaltyDialogAt = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen == true) return;

      final dialogContext = context ?? Get.overlayContext ?? Get.context;
      if (dialogContext == null || !dialogContext.mounted) return;

      showDialog<void>(
        context: dialogContext,
        barrierDismissible: false,
        builder: (dialogCtx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 52,
                ),
                const SizedBox(height: 16),
                Text(
                  isPenalty ? 'Penalty Applied'.tr : 'Unavailable'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: MyColors.DarkBlue.withOpacity(0.9),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _forceDriverUnavailable({
    required String message,
    BuildContext? context,
    bool showDialog = true,
    bool isPenalty = false,
  }) {
    final wasOnline = onOff.value;
    if (wasOnline && isPenalty) {
      _wasOnlineBeforePenalty = true;
    } else if (!isPenalty) {
      _wasOnlineBeforePenalty = false;
    }
    onOff.value = false;
    sp.setBoolValue(sp.DRIVER_ONLINE_STATUS, false);

    if (!wasOnline || !showDialog) return;

    _showPenaltyDialog(
      message: message,
      context: context,
      isPenalty: isPenalty,
    );
  }

  void _handleLatLongResponse(
    Map<String, dynamic> data, {
    BuildContext? context,
  }) {
    final backendStatus = data['available_status']?.toString();
    final penaltySeconds =
        int.tryParse(data['penalty_remaining_seconds']?.toString() ?? '0') ?? 0;

    _applyPenaltyFromBackend(penaltySeconds);

    // Backend penalty OR unavailable → driver must go offline.
    // Next GPS sync will send UnAvailable automatically (onOff = false).
    if (penaltySeconds > 0 || _isUnavailableStatus(backendStatus)) {
      final message = penaltySeconds > 0
          ? _penaltyMessage(penaltySeconds)
          : 'You have been marked unavailable by admin'.tr;
      _forceDriverUnavailable(
        message: message,
        context: context,
        isPenalty: penaltySeconds > 0,
      );
      return;
    }

    _onPenaltyCleared(context: context);
  }

  bool canGoOnline({bool showMessage = true}) {
    if (isPenaltyActive()) {
      if (showMessage) {
        _showPenaltyDialog(
          message: _penaltyMessage(),
          isPenalty: true,
        );
      }
      return false;
    }
    return true;
  }

  void _syncDriverAvailability(Position position, BuildContext? context) {
    final now = DateTime.now();
    final shouldSync = _lastDriverLatLongSyncAt == null ||
        now.difference(_lastDriverLatLongSyncAt!).inSeconds >= 3;
    if (!shouldSync) return;

    _lastDriverLatLongSyncAt = now;

    if (onOff.value) {
      if (isPenaltyActive()) {
        _forceDriverUnavailable(
          message: _penaltyMessage(),
          context: context,
          isPenalty: true,
        );
        updateDriverLatLong('0', '0', '0', 'UnAvailable', context: context);
        return;
      }
      updateDriverLatLong(
        position.latitude.toString(),
        position.longitude.toString(),
        position.heading.toString(),
        'Available',
        context: context,
      );
    } else {
      if (!isPenaltyActive() && _wasOnlineBeforePenalty) {
        _onPenaltyCleared(context: context, position: position);
        return;
      }
      updateDriverLatLong('0', '0', '0', 'UnAvailable', context: context);
    }
  }

  Future<void> Data(Position position, BuildContext context) async {
    try {
      // Check if Google Map controller is available
      if (googleMapController.value != null) {
        updateCameraPosition(LatLng(position.latitude, position.longitude));
      }

      final now = DateTime.now();
      // Slightly looser polling reduces duplicate requests (helps with HTTP 429).
      final shouldRefreshRideState = _lastRideRefreshAt == null ||
          now.difference(_lastRideRefreshAt!).inSeconds >= 12;
      if (shouldRefreshRideState) {
        _lastRideRefreshAt = now;
        var loginKey = await sp.getStringValue(sp.LOGIN_DEVICE_KEY.toString());
        var accessToken = await sp.getStringValue(sp.ACCESS_TOKEN.toString());
        var authController = Get.find<AuthController>();
        authController.loginCheck(loginKey.toString(), accessToken, context);
        Get.find<BookingController>().rideNowBooking();
        Get.find<BookingController>().userAcceptBooking();
      }

      var bookingController = Get.find<BookingController>();
      applyLivePosition(position);

      if (hide.value == false) {
        // Do nothing if hide is false
      } else if (bookingController.useracceptmodel.bookingId != "") {
        bookingController.updateLatLongStartRide(
          bookingController.useracceptmodel.bookingId,
          position.latitude.toString(),
          position.longitude.toString(),
        );
      }

      if (bookingController.useracceptmodel.status != "") {
        userPickupMarker(context);
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
