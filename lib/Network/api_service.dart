import 'dart:developer';

import 'package:dio/dio.dart' as DIO;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mtaanidriver/Network/urls.dart';
import '../utils/session_auth.dart';
import '../utils/shared_preferences.dart';

class ApiService extends GetxService {
  DIO.Dio dioClient = DIO.Dio();
  final int timeoutInSecond = 30;
  final DIO.LogInterceptor logInterceptor = DIO.LogInterceptor();

  ApiService() {
    dioClient.interceptors.add(
      DIO.InterceptorsWrapper(
        onResponse: (response, handler) {
          _maybeHandleSession(
            endpoint: response.requestOptions.uri.path,
            statusCode: response.statusCode ?? 0,
            body: _responseBody(response.data),
          );
          handler.next(response);
        },
        onError: (error, handler) {
          final res = error.response;
          if (res != null) {
            _maybeHandleSession(
              endpoint: res.requestOptions.uri.path,
              statusCode: res.statusCode ?? 0,
              body: _responseBody(res.data),
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  SecureStorageService secure = SecureStorageService();

  static const _sensitiveKeys = {
    'password',
    'Password',
    'access_token',
    'login_device_key',
  };

  void _apiLog(String message) {
    debugPrint(message);
    log(message);
  }

  String _maskValue(String key, Object? value) {
    if (value == null) return '';
    final text = value.toString();
    if (_sensitiveKeys.contains(key)) {
      if (text.isEmpty) return '';
      return '*** (${text.length} chars)';
    }
    if (key.toLowerCase() == 'token' || key == 'Authorization') {
      if (text.length <= 8) return '***';
      return '***${text.substring(text.length - 4)}';
    }
    return text;
  }

  Map<String, String> _maskMap(Map<String, dynamic> body) {
    return body.map(
      (key, value) => MapEntry(key, _maskValue(key, value)),
    );
  }

  Map<String, String> _maskHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, _maskValue('Authorization', value));
      }
      return MapEntry(key, value);
    });
  }

  void _logRequest({
    required String method,
    required String endpoint,
    required String fullUrl,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    int? attempt,
  }) {
    final buffer = StringBuffer()
      ..writeln('══════════════ API REQUEST ══════════════')
      ..writeln('BASE_URL   : ${URLS.BASE_URL}')
      ..writeln('METHOD     : $method')
      ..writeln('ENDPOINT   : $endpoint')
      ..writeln('FULL_URL   : $fullUrl');
    if (attempt != null) {
      buffer.writeln('ATTEMPT    : $attempt');
    }
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('HEADERS    : ${_maskHeaders(headers)}');
    }
    if (body != null) {
      buffer.writeln('REQ_BODY   : ${_maskMap(body)}');
    }
    buffer.writeln('══════════════════════════════════════════');
    _apiLog(buffer.toString());
  }

  void _logResponse({
    required String method,
    required String endpoint,
    required String fullUrl,
    required int statusCode,
    required String body,
    int? attempt,
  }) {
    final buffer = StringBuffer()
      ..writeln('══════════════ API RESPONSE ═════════════')
      ..writeln('BASE_URL   : ${URLS.BASE_URL}')
      ..writeln('METHOD     : $method')
      ..writeln('ENDPOINT   : $endpoint')
      ..writeln('FULL_URL   : $fullUrl');
    if (attempt != null) {
      buffer.writeln('ATTEMPT    : $attempt');
    }
    buffer
      ..writeln('STATUS     : $statusCode')
      ..writeln('RES_BODY   : ${body.isEmpty ? '<empty>' : body}')
      ..writeln('══════════════════════════════════════════');
    _apiLog(buffer.toString());
  }

  void _logError({
    required String method,
    required String endpoint,
    required String fullUrl,
    required Object error,
    int? attempt,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer()
      ..writeln('══════════════ API ERROR ═════════════════')
      ..writeln('BASE_URL   : ${URLS.BASE_URL}')
      ..writeln('METHOD     : $method')
      ..writeln('ENDPOINT   : $endpoint')
      ..writeln('FULL_URL   : $fullUrl');
    if (attempt != null) {
      buffer.writeln('ATTEMPT    : $attempt');
    }
    buffer
      ..writeln('ISSUE      : $error')
      ..writeln('══════════════════════════════════════════');
    _apiLog(buffer.toString());
    if (stackTrace != null) {
      log('API stack ($endpoint)', error: error, stackTrace: stackTrace);
    }
  }

  String _responseBody(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    return data.toString();
  }

  static const _publicEndpoints = {
    URLS.DRIVER_LOGIN,
    URLS.DRIVER_SIGNUP,
    URLS.DRIVER_SIGNUP_CHECK,
    URLS.DRIVER_FORGET_PASSWORD,
    URLS.send_otp,
    URLS.verify_driver_otp,
    URLS.DRIVER_SET_PASSWORD,
  };

  bool _isPublic(String endpoint) {
    final path = endpoint.split('/').last;
    return _publicEndpoints.contains(path) ||
        _publicEndpoints.contains(endpoint);
  }

  void _maybeHandleSession({
    required String endpoint,
    required int statusCode,
    required String body,
  }) {
    if (_isPublic(endpoint)) return;
    SessionAuth.handleUnauthorized(statusCode: statusCode, body: body);
  }

  Future<Map<String, String>> _headersFor(
    String endpoint, {
    Map<String, String> extra = const {},
  }) async {
    final headers = Map<String, String>.from(extra);
    if (_isPublic(endpoint)) return headers;

    final jwtToken = await secure.readData(secure.Token) ?? '';
    if (jwtToken.isEmpty) return headers;

    headers['Authorization'] = 'Bearer $jwtToken';
    headers.putIfAbsent('Accept', () => 'application/json');
    return headers;
  }

  /// True when the browser can read API responses (CORS allow-origin).
  /// Localhost is not on the API allowlist — a failed probe must not POST
  /// login, or the server still replaces the mobile session.
  Future<bool> canBrowserReadApi() async {
    if (!kIsWeb) return true;
    try {
      final response = await http
          .get(Uri.parse(URLS.api(URLS.DRIVER_FAQ)))
          .timeout(Duration(seconds: timeoutInSecond));
      return response.body.isNotEmpty;
    } catch (e) {
      log('Web CORS probe failed: $e');
      return false;
    }
  }

  /// Web-safe form body — avoids `null is not a subtype of String` on http.post.
  String _encodeFormBody(Map<String, dynamic> body) {
    return body.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value?.toString() ?? '')}',
        )
        .join('&');
  }

  Future<http.Response> postData(String url, Map<String, dynamic> body) async {
    final fullUrl = URLS.api(url);
    final headers = await _headersFor(
      url,
      extra: const {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    _logRequest(
      method: 'POST',
      endpoint: url,
      fullUrl: fullUrl,
      body: body,
      headers: headers,
    );

    try {
      final response = await http
          .post(
            Uri.parse(fullUrl),
            headers: headers,
            body: _encodeFormBody(body),
          )
          .timeout(Duration(seconds: timeoutInSecond));

      _logResponse(
        method: 'POST',
        endpoint: url,
        fullUrl: fullUrl,
        statusCode: response.statusCode,
        body: response.body,
      );
      _maybeHandleSession(
        endpoint: url,
        statusCode: response.statusCode,
        body: response.body,
      );
      return response;
    } catch (e, stack) {
      _logError(
        method: 'POST',
        endpoint: url,
        fullUrl: fullUrl,
        error: e,
        stackTrace: stack,
      );
      if (kIsWeb) {
        return http.Response('', 503);
      }
      Error.throwWithStackTrace(
        e is Exception ? e : Exception(e.toString()),
        stack,
      );
    }
  }

  Future<DIO.Response> postDatas(String url, Map<String, dynamic> body) async {
    final fullUrl = URLS.api(url);
    final formData = DIO.FormData.fromMap(body);
    final headers = await _headersFor(url);

    _logRequest(
      method: 'POST',
      endpoint: url,
      fullUrl: fullUrl,
      body: body,
      headers: headers,
    );

    try {
      final response = await dioClient
          .post(
            fullUrl,
            data: formData,
            options: DIO.Options(
              responseType: DIO.ResponseType.plain,
              headers: headers,
            ),
          )
          .timeout(Duration(seconds: timeoutInSecond));

      _logResponse(
        method: 'POST',
        endpoint: url,
        fullUrl: fullUrl,
        statusCode: response.statusCode ?? 0,
        body: _responseBody(response.data),
      );
      return response;
    } catch (e, stack) {
      _logError(
        method: 'POST',
        endpoint: url,
        fullUrl: fullUrl,
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<DIO.Response> postDatatoken(
    String url,
    Map<String, dynamic> body,
  ) async {
    final fullUrl = URLS.api(url);
    final formData = DIO.FormData.fromMap(body);
    final headers = await _headersFor(url);

    _logRequest(
      method: 'POST',
      endpoint: url,
      fullUrl: fullUrl,
      body: body,
      headers: headers,
    );

    try {
      final response = await dioClient
          .post(
            fullUrl,
            data: formData,
            options: DIO.Options(
              responseType: DIO.ResponseType.plain,
              headers: headers,
            ),
          )
          .timeout(Duration(seconds: timeoutInSecond));

      _logResponse(
        method: 'POST',
        endpoint: url,
        fullUrl: fullUrl,
        statusCode: response.statusCode ?? 0,
        body: _responseBody(response.data),
      );
      return response;
    } catch (e, stack) {
      _logError(
        method: 'POST',
        endpoint: url,
        fullUrl: fullUrl,
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<DIO.Response> getData(String url) async {
    final fullUrl = URLS.api(url);
    final headers = await _headersFor(
      url,
      extra: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _logRequest(
      method: 'GET',
      endpoint: url,
      fullUrl: fullUrl,
      headers: headers,
    );

    try {
      final response = await dioClient
          .get(
            fullUrl,
            options: DIO.Options(
              responseType: DIO.ResponseType.plain,
              headers: headers,
            ),
          )
          .timeout(Duration(seconds: timeoutInSecond));

      _logResponse(
        method: 'GET',
        endpoint: url,
        fullUrl: fullUrl,
        statusCode: response.statusCode ?? 0,
        body: _responseBody(response.data),
      );
      return response;
    } catch (e, stack) {
      _logError(
        method: 'GET',
        endpoint: url,
        fullUrl: fullUrl,
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<DIO.Response> multiPartFile(
    String url,
    DIO.FormData formData,
  ) async {
    final fullUrl = URLS.api(url);
    final headers = await _headersFor(
      url,
      extra: const {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      },
    );
    final body = <String, dynamic>{
      for (final field in formData.fields) field.key: field.value,
      for (final file in formData.files)
        file.key: '<file: ${file.value.filename ?? 'unknown'}>',
    };

    _logRequest(
      method: 'POST (multipart)',
      endpoint: url,
      fullUrl: fullUrl,
      body: body,
      headers: headers,
    );

    try {
      final response = await dioClient.post(
        fullUrl,
        data: formData,
        options: DIO.Options(
          headers: headers,
        ),
      );

      _logResponse(
        method: 'POST (multipart)',
        endpoint: url,
        fullUrl: fullUrl,
        statusCode: response.statusCode ?? 0,
        body: _responseBody(response.data),
      );
      return response;
    } catch (e, stack) {
      _logError(
        method: 'POST (multipart)',
        endpoint: url,
        fullUrl: fullUrl,
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
