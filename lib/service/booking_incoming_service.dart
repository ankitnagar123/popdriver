import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/ride_now_booking_model.dart';
import '../controller/booking_controller.dart';
import '../controller/home_screen_controller.dart';
import '../route_helper/route_helper.dart';
import 'notification_service.dart';

/// Minimal Rapido-style incoming booking UI (in-app popup + background alert).
class BookingIncomingService with WidgetsBindingObserver {
  BookingIncomingService._();
  static final BookingIncomingService instance = BookingIncomingService._();

  static const String actionAccept = 'booking_accept';
  static const String actionPass = 'booking_pass';
  static const String payloadPrefix = 'booking_incoming';

  static const String _prefPendingAction = 'notif_pending_action';
  static const String _prefPendingBookingId = 'notif_pending_booking_id';
  static const String _prefLastIncomingBookingId = 'last_incoming_booking_id';

  AppLifecycleState _lifecycle = AppLifecycleState.resumed;
  String? _lastShownBookingId;
  String? _pendingAction;
  String? _pendingBookingId;
  bool _observerAttached = false;
  bool _processingPending = false;

  bool get isAppInForeground => _lifecycle == AppLifecycleState.resumed;

  bool get isAppInBackground => !isAppInForeground;

  Future<bool> _canShowIncoming() async {
    if (BookingRingManager.canRingFromControllers()) return true;
    return BookingRingManager.canRingFromStorage();
  }

  void attach() {
    if (_observerAttached || kIsWeb) return;
    WidgetsBinding.instance.addObserver(this);
    _observerAttached = true;
    processPendingWhenReady();
  }

  /// Persist Accept/Pass tap — works from background isolate when app is killed.
  static Future<void> persistNotificationResponse({
    required String? actionId,
    required String? payload,
  }) async {
    try {
      final data = parsePayload(payload);
      var bookingId = (data['booking_id'] ?? '').trim();

      final prefs = await SharedPreferences.getInstance();
      if (bookingId.isEmpty || bookingId == 'pending') {
        bookingId = (prefs.getString(_prefLastIncomingBookingId) ?? '').trim();
      }

      String? action;
      if (actionId == actionAccept) {
        action = actionAccept;
      } else if (actionId == actionPass) {
        action = actionPass;
      }

      if (bookingId.isEmpty) {
        log('notification action ignored — booking id missing');
        return;
      }

      if (action != null) {
        await prefs.setString(_prefPendingAction, action);
        await prefs.setString(_prefPendingBookingId, bookingId);
        log('notification action saved: $action booking #$bookingId');
      } else {
        await prefs.remove(_prefPendingAction);
        await prefs.setString(_prefPendingBookingId, bookingId);
        log('notification open saved for booking #$bookingId');
      }
    } catch (e, st) {
      log('persistNotificationResponse failed', error: e, stackTrace: st);
    }
  }

  static Future<void> rememberIncomingBookingId(String bookingId) async {
    final id = bookingId.trim();
    if (id.isEmpty || id == 'pending') return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastIncomingBookingId, id);
    } catch (_) {
      /* ignore */
    }
  }

  static Future<void> clearPendingNotificationAction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefPendingAction);
      await prefs.remove(_prefPendingBookingId);
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> _hydratePendingFromPrefs() async {
    if (_pendingAction != null && _pendingBookingId != null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _pendingAction ??= prefs.getString(_prefPendingAction);
      _pendingBookingId ??= prefs.getString(_prefPendingBookingId);
    } catch (_) {
      /* ignore */
    }
  }

  /// After cold start / splash — run Accept or Pass once controllers are ready.
  Future<void> processPendingWhenReady({int maxAttempts = 30}) async {
    if (kIsWeb || _processingPending) return;
    await _hydratePendingFromPrefs();
    if (_pendingAction == null || _pendingBookingId == null) return;

    _processingPending = true;
    try {
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        await _hydratePendingFromPrefs();
        final action = _pendingAction;
        final bookingId = _pendingBookingId;
        if (action == null || bookingId == null || bookingId.isEmpty) return;

        if (!Get.isRegistered<BookingController>() ||
            !Get.isRegistered<HomeController>()) {
          await Future.delayed(const Duration(milliseconds: 400));
          continue;
        }

        final route = Get.currentRoute;
        if (route == RouteHelper.getSplashScreenRoute() ||
            route == RouteHelper.getLoginScreenRoute()) {
          await Future.delayed(const Duration(milliseconds: 400));
          continue;
        }

        if (route != RouteHelper.getHomeScreenScreenRoute()) {
          Get.offAllNamed(RouteHelper.getHomeScreenScreenRoute());
          await Future.delayed(const Duration(milliseconds: 500));
        }

        await _processPendingAction();
        return;
      }
      log('processPendingWhenReady timed out for booking #${_pendingBookingId}');
    } finally {
      _processingPending = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    if (state == AppLifecycleState.resumed) {
      BookingRingManager.stopImmediate();
      processPendingWhenReady();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      BookingRingManager.stopImmediate();
    }
  }

  /// Background only — in-app home card already handles foreground bookings.
  Future<void> presentIncomingBooking({
    RideNowBookingModel? booking,
    String? bookingId,
  }) async {
    if (kIsWeb) return;
    if (isAppInForeground) return;
    if (!await _canShowIncoming()) return;

    final id = (booking?.bookingId ?? bookingId ?? '').trim();
    if (id.isEmpty) return;
    if (_lastShownBookingId == id) return;
    _lastShownBookingId = id;

    RideNowBookingModel? resolved = booking;
    if (resolved == null) {
      try {
        final list = Get.find<BookingController>().rideNowList;
        for (final item in list) {
          if (item.bookingId == id) {
            resolved = item;
            break;
          }
        }
      } catch (_) {
        /* ignore */
      }
    }

    await NotificationService.showIncomingBookingAlert(
      bookingId: id,
      userName: resolved?.userName ?? 'New ride request',
      pickup: resolved?.sourceAdd ?? 'Tap to open and view pickup',
      destination: resolved?.destinationAdd ?? '',
      offer: resolved?.userOfferPrice ?? '',
      distance: resolved?.distance ?? '',
    );
  }

  static String buildPayload({
    required String bookingId,
    String userName = '',
    String pickup = '',
    String destination = '',
    String offer = '',
    String distance = '',
  }) {
    return jsonEncode({
      'type': payloadPrefix,
      'booking_id': bookingId,
      'user_name': userName,
      'pickup': pickup,
      'destination': destination,
      'offer': offer,
      'distance': distance,
    });
  }

  static Map<String, String> parsePayload(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {
      if (raw.startsWith('$payloadPrefix|')) {
        final parts = raw.split('|');
        return {'booking_id': parts.length > 1 ? parts[1] : ''};
      }
    }
    return {};
  }

  Future<void> handleNotificationResponse({
    required String? actionId,
    required String? payload,
  }) async {
    await persistNotificationResponse(
      actionId: actionId,
      payload: payload,
    );
    await _hydratePendingFromPrefs();

    BookingRingManager.stopImmediate();
    _openHomeForBooking();
    await processPendingWhenReady();
  }

  void _openHomeForBooking() {
    try {
      if (Get.currentRoute != RouteHelper.getHomeScreenScreenRoute()) {
        Get.offAllNamed(RouteHelper.getHomeScreenScreenRoute());
      }
      Get.find<BookingController>().rideNowBooking();
    } catch (e, st) {
      log('open home for booking failed', error: e, stackTrace: st);
    }
  }

  Future<String?> _resolveBookingId(String bookingId) async {
    var resolved = bookingId.trim();
    if (resolved.isNotEmpty && resolved != 'pending') return resolved;

    try {
      final prefs = await SharedPreferences.getInstance();
      resolved = (prefs.getString(_prefLastIncomingBookingId) ?? '').trim();
      if (resolved.isNotEmpty && resolved != 'pending') return resolved;
    } catch (_) {
      /* ignore */
    }

    if (!Get.isRegistered<BookingController>()) return null;
    final bookingController = Get.find<BookingController>();
    await bookingController.rideNowBooking();
    if (bookingController.rideNowList.isEmpty) return null;
    return bookingController.rideNowList.first.bookingId;
  }

  Future<void> _processPendingAction() async {
    final action = _pendingAction;
    final rawBookingId = _pendingBookingId;
    if (action == null || rawBookingId == null || rawBookingId.isEmpty) return;
    if (!Get.isRegistered<BookingController>() ||
        !Get.isRegistered<HomeController>()) {
      return;
    }

    final bookingId = await _resolveBookingId(rawBookingId);
    if (bookingId == null || bookingId.isEmpty) {
      log('pending notification action waiting for booking id');
      return;
    }

    _pendingAction = null;
    _pendingBookingId = null;
    await clearPendingNotificationAction();

    final bookingController = Get.find<BookingController>();
    await bookingController.rideNowBooking();

    if (action == actionAccept) {
      Get.find<HomeController>().bookingIndex = 0;
      bookingController.acceptBooking(bookingId, () {
        Get.toNamed(RouteHelper.getReadyForRideScreenRoute());
      });
      return;
    }

    if (action == actionPass) {
      bookingController.cancelBooking(bookingId, 'Pass', () {
        bookingController.rideNowBooking();
      });
    }
  }

  void clearShownState() {
    _lastShownBookingId = null;
  }
}
