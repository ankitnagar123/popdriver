import 'dart:async';

import 'package:flutter/foundation.dart';

import '../service/notification_service.dart';
import 'web_geolocation.dart';

/// Web splash Allow: native permission from a user tap. Token/GPS must not block UI.
class WebSplashBootstrap {
  WebSplashBootstrap._();

  static Future<void> requestPermissionsOnUserGesture() async {
    if (!kIsWeb) return;

    await NotificationService.requestWebPermissionOnUserGesture(
      syncDeviceToApi: true,
    );

    unawaited(() async {
      try {
        await getBrowserLocation(timeout: const Duration(seconds: 8));
      } catch (e) {
        debugPrint('Web splash location prompt: $e');
      }
    }());
  }
}
