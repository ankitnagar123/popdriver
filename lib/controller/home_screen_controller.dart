import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:math' as Math;

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
import '../service/notification_service.dart';

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
  BitmapDescriptor? _driverMarkerIcon;
  /// Visual smoothing state (marker interpolation).
  Timer? _markerAnimTimer;
  LatLng? _markerVisualPos;
  LatLng? _markerTargetPos;
  double? _markerVisualBearing;
  DateTime? _markerTargetAt;
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
  bool _cameraMoveFromCode = false;
  bool _mapReady = false;
  bool _cameraAnimInFlight = false;
  DateTime? _lastAnimateAt;

  /// When true, map camera follows the driver car (Restart-style).
  final RxBool mapFollowDriver = true.obs;

  /// Clears all map markers except the driver's own marker (`MarkerId("1")`).
  /// Many flows reset map state on booking cancel/complete; driver marker should persist.
  void clearMarkersExceptDriver() {
    markers.removeWhere((m) => m.markerId != const MarkerId('1'));
    markers.refresh();
  }

  Future<BitmapDescriptor> _getDriverMarkerIcon() async {
    // Match Restart driver's look: use the same car asset + fixed size.
    final existing = _driverMarkerIcon;
    if (existing != null) return existing;
    final icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(23, 34)),
      'assets/images/restart_car.png',
    );
    _driverMarkerIcon = icon;
    return icon;
  }

  /// Bump so `HomeScreen` rebuilds polylines after async Directions fetch.
  final RxInt mapPolylineEpoch = 0.obs;
  final RxInt penaltyRemainingSeconds = 0.obs;

  void setGoogleMapController(GoogleMapController controller) {
    googleMapController.value = controller;
    _mapReady = true;
  }

  /// Call when GoogleMap widget is disposed / left Home so GPS sync
  /// cannot animate a dead platform channel.
  void clearGoogleMapController() {
    _mapReady = false;
    _cameraMoveFromCode = false;
    _cameraAnimInFlight = false;
    googleMapController.value = null;
  }

  void onUserMapGesture() {
    if (mapFollowDriver.value) {
      mapFollowDriver.value = false;
    }
  }

  void onCameraMoveStarted() {
    if (_cameraMoveFromCode) return;
    onUserMapGesture();
  }

  void recenterMapOnDriver() {
    if (!hasValidLocation.value) return;
    mapFollowDriver.value = true;
    _lastCameraTarget = null;
    updateCameraPosition(startLocation.value, force: true);
  }

  Future<void> _safeAnimateCamera(CameraUpdate update) async {
    if (!_mapReady) return;
    final controller = googleMapController.value;
    if (controller == null) return;
    if (_cameraAnimInFlight) return;

    final now = DateTime.now();
    if (_lastAnimateAt != null &&
        now.difference(_lastAnimateAt!).inMilliseconds < 250) {
      return;
    }
    _lastAnimateAt = now;
    _cameraAnimInFlight = true;
    _cameraMoveFromCode = true;
    try {
      await controller.animateCamera(update);
    } on PlatformException catch (e) {
      // Map platform view torn down / channel reconnect — ignore.
      log('animateCamera skipped: ${e.code} ${e.message}');
      if (e.code == 'channel-error') {
        clearGoogleMapController();
      }
    } catch (e) {
      log('animateCamera skipped: $e');
    } finally {
      _cameraAnimInFlight = false;
      _cameraMoveFromCode = false;
    }
  }

  void updateCameraPosition(LatLng location, {bool force = false}) {
    if (location.latitude == 0 && location.longitude == 0) return;
    if (!force && !mapFollowDriver.value) return;
    if (!_mapReady || googleMapController.value == null) return;

    if (_lastCameraTarget != null && !force) {
      final distance = Geolocator.distanceBetween(
        _lastCameraTarget!.latitude,
        _lastCameraTarget!.longitude,
        location.latitude,
        location.longitude,
      );
      if (distance < 8) return;
    }
    _lastCameraTarget = location;
    // Fire-and-forget; errors are handled inside _safeAnimateCamera.
    unawaited(
      _safeAnimateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 16,
            bearing: (_markerVisualBearing ?? 0) % 360.0,
          ),
        ),
      ),
    );
  }

  /// Called after the route polyline is decoded so the map refreshes and fits the path.
  void onRoutePolylineReady(List<LatLng> points) {
    if (points.isEmpty) return;
    mapPolylineEpoch.value++;
    _fitCameraToRoute(points);
  }

  void _fitCameraToRoute(List<LatLng> points) {
    if (!_mapReady || googleMapController.value == null || points.length < 2) {
      return;
    }
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
    unawaited(
      _safeAnimateCamera(CameraUpdate.newLatLngBounds(bounds, 100)),
    );
  }

  @override
  void onClose() {
    _penaltyExpiryTimer?.cancel();
    _markerAnimTimer?.cancel();
    clearGoogleMapController();
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
    _markerAnimTimer?.cancel();
    clearGoogleMapController();
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
      locationSettings: driverLocationSettings(
        enableForegroundService: onOff.value && !kIsWeb,
      ),
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
        mapFollowDriver.value = true;
        _lastCameraTarget = null;
        updateCameraPosition(startLocation.value, force: true);
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
    await restartLocationStreamForOnlineState();
  }

  void applyLivePosition(Position position, {bool recenterMap = false}) {
    if (position.latitude == 0 && position.longitude == 0) return;
    if (recenterMap) {
      _lastCameraTarget = null;
      mapFollowDriver.value = true;
    }
    hasValidLocation.value = true;
    if (kIsWeb && position.accuracy > 1000) {
      log('Web location ~${position.accuracy.round()}m accurate — turn on precise location in browser & Windows');
    }
    startLocation.value = LatLng(position.latitude, position.longitude);
    updateMarker(position);
    updateCameraPosition(startLocation.value, force: recenterMap);
    if (onOff.value) {
      _syncDriverAvailability(
        position,
        Get.overlayContext ?? Get.context,
      );
    }
  }

  Future<void> restartLocationStreamForOnlineState() async {
    if (!_isListening) return;
    try {
      await streamSubscription.cancel();
    } catch (e) {
      log('[LOCATION] stream cancel before restart: $e');
    }
    _isListening = false;
    startListening();
  }

  Future<void> onDriverOnlineStatusChanged(bool online) async {
    if (!online) {
      await BookingRingManager.stopImmediate();
    }
    await restartLocationStreamForOnlineState();
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
      icon = await _getDriverMarkerIcon();
    } catch (_) {
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    final nextTarget = LatLng(position.latitude, position.longitude);
    final nextBearing = _chooseBearing(
      position: position,
      target: nextTarget,
    );

    // Initialize visual state on first fix.
    _markerVisualPos ??= nextTarget;
    _markerVisualBearing ??= nextBearing;

    _markerTargetPos = nextTarget;
    _markerTargetAt = DateTime.now();
    _markerStartOrKickAnimation(icon: icon);
  }

  double _chooseBearing({
    required Position position,
    required LatLng target,
  }) {
    // Prefer plugin-provided heading when moving; otherwise compute from delta.
    final speed = position.speed;
    final hasMotion = speed.isFinite && speed > 1.0; // m/s

    double candidate;
    if (hasMotion && position.heading.isFinite && position.heading >= 0) {
      candidate = position.heading % 360.0;
    } else if (_markerVisualPos != null) {
      candidate = _bearingBetween(_markerVisualPos!, target);
    } else {
      candidate = 0;
    }

    // Low-pass filter angle to reduce jitter.
    final prev = _markerVisualBearing ?? candidate;
    // alpha: 0 → stick, 1 → no smoothing
    const alpha = 0.22;
    return _lerpAngleDegrees(prev, candidate, alpha);
  }

  void _markerStartOrKickAnimation({required BitmapDescriptor icon}) {
    // If we're already animating, just let it converge to the new target.
    if (_markerAnimTimer?.isActive == true) return;

    _markerAnimTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final target = _markerTargetPos;
      final targetAt = _markerTargetAt;
      if (target == null || targetAt == null) return;

      final from = _markerVisualPos ?? target;
      final to = target;

      // Smoothly converge towards target; faster if far, slower if near.
      final distMeters = Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );

      // If we are basically at target, snap and stop.
      if (distMeters < 1.2) {
        _markerVisualPos = to;
        _pushDriverMarker(icon: icon);
        timer.cancel();
        _markerAnimTimer = null;
        return;
      }

      // Step factor: 0.08..0.35 (bigger gap → bigger step).
      final t = (distMeters / 25.0).clamp(0.08, 0.35);
      _markerVisualPos = _lerpLatLng(from, to, t);

      // Bearing should keep moving towards the last chosen bearing.
      // When target updates quickly, _markerVisualBearing is updated in updateMarker().
      _pushDriverMarker(icon: icon);
    });
  }

  void _pushDriverMarker({required BitmapDescriptor icon}) {
    final pos = _markerVisualPos ?? _markerTargetPos;
    if (pos == null) return;

    final marker =
        markers.firstWhereOrNull((m) => m.markerId == const MarkerId("1"));
    if (marker != null) {
      markers.remove(marker);
    }

    markers.add(Marker(
      markerId: const MarkerId("1"),
      position: pos,
      rotation: (_markerVisualBearing ?? 0) % 360.0,
      draggable: false,
      zIndexInt: 2,
      flat: true,
      // Restart uses centered anchor for top-view car.
      anchor: const Offset(0.5, 0.5),
      icon: icon,
    ));
    markers.refresh();
  }

  static LatLng _lerpLatLng(LatLng a, LatLng b, double t) {
    final clamped = t.clamp(0.0, 1.0);
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * clamped,
      a.longitude + (b.longitude - a.longitude) * clamped,
    );
  }

  static double _lerpAngleDegrees(double a, double b, double t) {
    // Shortest-path interpolation over wrap-around at 360.
    final delta = ((b - a + 540) % 360) - 180;
    return (a + delta * t) % 360.0;
  }

  static double _bearingBetween(LatLng from, LatLng to) {
    final lat1 = from.latitude * (3.141592653589793 / 180.0);
    final lat2 = to.latitude * (3.141592653589793 / 180.0);
    final dLon = (to.longitude - from.longitude) * (3.141592653589793 / 180.0);
    final y = Math.sin(dLon) * Math.cos(lat2);
    final x = Math.cos(lat1) * Math.sin(lat2) -
        Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
    final brng = Math.atan2(y, x) * (180.0 / 3.141592653589793);
    return (brng + 360.0) % 360.0;
  }

  // NOTE: legacy marker-byte loader removed in favor of [BitmapDescriptor.asset]
  // to keep sizing consistent like Restart driver.

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
    BookingRingManager.stopImmediate();

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
