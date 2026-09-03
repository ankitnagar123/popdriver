import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controller/auth_controller.dart';
import '../route_helper/route_helper.dart';
import '../service/device_token_sync.dart';

/// Central 401 session handling — do not retry the failed request.
class SessionAuth {
  SessionAuth._();

  static bool _handling = false;

  static const Set<String> _sessionResults = {
    'session_replaced',
    'session_revoked',
    'session_expired',
    'authentication_required',
  };

  static bool isSessionResult(String? result) {
    final normalized = result?.trim().toLowerCase() ?? '';
    return _sessionResults.contains(normalized);
  }

  static void handleHttpResponse(http.Response response) {
    handleUnauthorized(statusCode: response.statusCode, body: response.body);
  }

  static void handleDioResponse(dio.Response response) {
    handleUnauthorized(
      statusCode: response.statusCode ?? 0,
      body: response.data?.toString() ?? '',
    );
  }

  static void handleError(Object error) {
    if (error is dio.DioException && error.response != null) {
      handleDioResponse(error.response!);
    }
  }

  static void handleUnauthorized({
    required int statusCode,
    required String body,
  }) {
    if (statusCode != 401) return;

    final loginRoute = RouteHelper.getLoginScreenRoute();
    if (Get.currentRoute == loginRoute) return;

    var result = '';
    var message = '';
    final raw = body.trim();
    if (raw.isEmpty) {
      result = 'authentication_required';
    } else {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          result = decoded['result']?.toString() ?? '';
          message = decoded['message']?.toString() ?? '';
        }
      } catch (_) {
        result = 'authentication_required';
      }
    }

    if (isSessionResult(result)) {
      unawaitedForceLogout(message: message);
    }
  }

  static void unawaitedForceLogout({String? message}) {
    if (_handling) return;
    _handling = true;
    Future<void>(() async {
      try {
        await forceLogout(message: message);
      } finally {
        _handling = false;
      }
    });
  }

  static Future<void> forceLogout({String? message}) async {
    DeviceTokenSync.blockSyncForLogout();

    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().forceLogoutToLogin(message: message);
      return;
    }

    final loginRoute = RouteHelper.getLoginScreenRoute();
    if (Get.currentRoute != loginRoute) {
      Get.offAllNamed(loginRoute);
    }
  }
}
