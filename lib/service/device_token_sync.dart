import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mtaanidriver/Network/api_service.dart';
import 'package:mtaanidriver/Network/urls.dart';
import 'package:mtaanidriver/utils/firebase_messaging_config.dart';
import 'package:mtaanidriver/utils/platform_helper.dart';
import 'package:mtaanidriver/utils/shared_preferences.dart';

/// Resolves FCM token and posts it to [URLS.DEVICE_ID_UPDATE].
/// Pattern aligned with pop_user (retry + persist + single-flight).
class DeviceTokenSync {
  DeviceTokenSync._();

  static const String _firebaseTokenKey = 'FIREBASE_TOKEN_KEY';

  static bool _syncBlocked = false;
  static Future<bool>? _syncInFlight;
  static String? _lastUploadedToken;
  static bool _refreshListenerAttached = false;

  static final ApiService _apiService = ApiService();
  static final SecureStorageService _secure = SecureStorageService();
  static final SharedPreferencesCrDriver _sp = SharedPreferencesCrDriver();

  static void blockSyncForLogout() {
    _syncBlocked = true;
    _lastUploadedToken = null;
    log('DeviceTokenSync: BLOCKED — logout');
  }

  static void allowSyncAfterLogin() {
    _syncBlocked = false;
    log('DeviceTokenSync: ALLOWED — login session');
  }

  static void attachTokenRefreshListener() {
    if (_refreshListenerAttached || kIsWeb) return;
    if (!isMobile) return;

    _refreshListenerAttached = true;
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      if (token.isEmpty || _syncBlocked) return;
      await persistFirebaseToken(token);
      final userId = await _secure.readData(_secure.user_id);
      if (userId == null || userId.isEmpty) return;
      log('DeviceTokenSync: onTokenRefresh → sync');
      await syncDeviceToken(userId: userId, force: true);
    });
  }

  static Future<void> persistFirebaseToken(String token) async {
    if (token.isEmpty) return;
    await _sp.setStringValue(_firebaseTokenKey, token);
  }

  /// iOS: never call [getToken] until APNS is registered (avoids crash/log spam).
  static Future<bool> _isIosApnsReady() async {
    if (!isIOS) return true;
    final apns = await FirebaseMessaging.instance.getAPNSToken();
    return apns != null && apns.isNotEmpty;
  }

  /// Fetch latest FCM token (cached first on mobile, then refresh).
  static Future<String?> resolveFcmToken({bool forceRefresh = false}) async {
    try {
      if (kIsWeb) {
        final settings = await FirebaseMessaging.instance.requestPermission();
        final allowed =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
                settings.authorizationStatus ==
                    AuthorizationStatus.provisional;
        if (!allowed) return null;

        final token = await FirebaseMessaging.instance.getToken(
          vapidKey: FirebaseMessagingConfig.webVapidKey,
        );
        if (token != null && token.isNotEmpty) {
          await persistFirebaseToken(token);
        }
        return token ?? await _sp.getStringValue(_firebaseTokenKey);
      }

      if (!forceRefresh) {
        final cached = await _sp.getStringValue(_firebaseTokenKey);
        if (cached != null && cached.isNotEmpty) {
          log('DeviceTokenSync: using cached FCM token (len=${cached.length})');
          return cached;
        }
      }

      if (isIOS && !await _isIosApnsReady()) {
        log('DeviceTokenSync: APNS not ready — skip getToken');
        return await _sp.getStringValue(_firebaseTokenKey);
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await persistFirebaseToken(token);
        log('DeviceTokenSync: FCM token resolved (len=${token.length})');
        debugPrint('FCM token for Firebase Console test: $token');
      }
      return token ?? await _sp.getStringValue(_firebaseTokenKey);
    } catch (e, stack) {
      log('DeviceTokenSync: resolveFcmToken error: $e', stackTrace: stack);
      return await _sp.getStringValue(_firebaseTokenKey);
    }
  }

  static Future<String> resolveDeviceType() async {
    if (kIsWeb) return 'Web';
    if (isAndroid) return 'Android';
    return 'IOS';
  }

  static Future<bool> syncDeviceToken({
    required String userId,
    bool force = false,
  }) async {
    if (_syncBlocked) {
      log('DeviceTokenSync: skip — logout block');
      return false;
    }
    if (userId.isEmpty) {
      log('DeviceTokenSync: skip — empty userId');
      return false;
    }

    if (_syncInFlight != null) {
      log('DeviceTokenSync: await in-flight sync');
      return _syncInFlight!;
    }

    _syncInFlight = _syncDeviceTokenBody(userId: userId, force: force);
    try {
      return await _syncInFlight!;
    } finally {
      _syncInFlight = null;
    }
  }

  static Future<bool> _syncDeviceTokenBody({
    required String userId,
    required bool force,
  }) async {
    final deviceId = await resolveFcmToken(forceRefresh: force);
    if (deviceId == null || deviceId.isEmpty) {
      log('DeviceTokenSync: FCM token missing — skip API');
      return false;
    }

    if (!force && _lastUploadedToken == deviceId) {
      log('DeviceTokenSync: token already uploaded — skip');
      return true;
    }

    final deviceStatus = await resolveDeviceType();
    final payload = {
      'driver_id': userId,
      'device_id': deviceId,
      'device_status': deviceStatus,
    };

    log(
      'DeviceTokenSync: POST update_driverdevice_id '
      'driver=$userId device_status=$deviceStatus token_len=${deviceId.length}',
    );

    try {
      final response =
          await _apiService.postData(URLS.DEVICE_ID_UPDATE, payload);

      log(
        'DeviceTokenSync: response status=${response.statusCode} '
        'body=${response.body}',
      );

      if (response.statusCode != 200) return false;

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map) return false;

      final result = decoded['result']?.toString().toLowerCase() ?? '';
      final ok = result.contains('success') || result.contains('update');

      if (ok) {
        _lastUploadedToken = deviceId;
        log('DeviceTokenSync: backend sync success');
      } else {
        log('DeviceTokenSync: backend rejected: $decoded');
      }
      return ok;
    } catch (e, stack) {
      log('DeviceTokenSync: API error: $e', stackTrace: stack);
      return false;
    }
  }

  /// Call after login / home open — retries like pop_user.
  static Future<void> syncAfterLogin({String? userId}) async {
    allowSyncAfterLogin();

    final id = userId ?? await _secure.readData(_secure.user_id) ?? '';
    if (id.isEmpty) {
      log('DeviceTokenSync: syncAfterLogin — not logged in');
      return;
    }

    final attempts = isIOS ? 8 : 4;
    for (var i = 0; i < attempts; i++) {
      if (_syncBlocked) return;

      if (isIOS && i > 0) {
        final apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns == null || apns.isEmpty) {
          log('DeviceTokenSync: waiting for APNS (attempt ${i + 1})');
          await Future.delayed(Duration(milliseconds: 800 * (i + 1)));
        }
      }

      final synced = await syncDeviceToken(
        userId: id,
        force: i > 0,
      );
      if (synced) {
        log('DeviceTokenSync: syncAfterLogin OK (attempt ${i + 1})');
        return;
      }

      if (i < attempts - 1) {
        await Future.delayed(Duration(milliseconds: 700 * (i + 1)));
      }
    }
    log('DeviceTokenSync: syncAfterLogin failed after $attempts attempts');
  }
}
