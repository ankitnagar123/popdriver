import 'dart:developer';

import 'package:dio/dio.dart' as DIO;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mtaanidriver/Network/urls.dart';
import '../utils/shared_preferences.dart';

class ApiService extends GetxService {
  DIO.Dio dioClient = DIO.Dio();
  final int timeoutInSecond = 30;
  final DIO.LogInterceptor logInterceptor = DIO.LogInterceptor();

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  SecureStorageService secure = SecureStorageService();

  /// Web-safe form body — avoids `null is not a subtype of String` on http.post.
  String _encodeFormBody(Map<String, dynamic> body) {
    return body.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value?.toString() ?? '')}',
        )
        .join('&');
  }

  /// Same [http.post] as mobile on all platforms — web gets retries only.
  Future<http.Response> postData(String url, Map<String, dynamic> body) async {
    final fullUrl = URLS.api(url);
    final maxAttempts = kIsWeb ? 3 : 1;
    Object? lastError;
    final encodedBody = _encodeFormBody(body);

    if (kIsWeb &&
        (url.contains('latlong') || url.contains('update_driver_latlong'))) {
      debugPrint('[LOCATION] POST $url payload=$encodedBody');
    }

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse(fullUrl),
              headers: const {
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: encodedBody,
            )
            .timeout(Duration(seconds: timeoutInSecond));

        if (kIsWeb) {
          debugPrint(
            '[API] POST $url attempt=$attempt status=${response.statusCode}',
          );
        }
        return response;
      } catch (e) {
        lastError = e;
        log('HTTP attempt $attempt failed ($url): $e');
        if (kIsWeb) {
          debugPrint('[API] POST $url attempt=$attempt FAILED: $e');
        }
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 400 * attempt));
        }
      }
    }

    log('HTTP failed after $maxAttempts attempts ($url): $lastError');
    if (kIsWeb) {
      return http.Response('', 503);
    }
    throw lastError ?? Exception('HTTP request failed');
  }

  Future<DIO.Response> postDatas(String url, Map<String, dynamic> body) async {
    DIO.FormData formData = DIO.FormData.fromMap(body);
    String jwtToken = await secure.readData(secure.Token) ?? "";

    log("Request URL: ${URLS.api(url)}");
    log("Request Body: $body");
    log("Bearer: $jwtToken");

    return await dioClient
        .post(
          URLS.api(url),
          data: formData,
          options: DIO.Options(
            responseType: DIO.ResponseType.plain,
          ),
        )
        .timeout(Duration(seconds: timeoutInSecond));
  }

  Future<DIO.Response> postDatatoken(
      String url, Map<String, dynamic> body) async {
    DIO.FormData formData = DIO.FormData.fromMap(body);
    log("Request URL: ${URLS.api(url)}");
    log("Request Body: $body");
    return await dioClient
        .post(
          URLS.api(url),
          data: formData,
          options: DIO.Options(
            responseType: DIO.ResponseType.plain,
          ),
        )
        .timeout(Duration(seconds: timeoutInSecond));
  }

  Future<DIO.Response> getData(
    String url,
  ) async {
    String jwtToken = await secure.readData(secure.Token) ?? "";
    return await dioClient
        .get(
          URLS.api(url),
          options: DIO.Options(
            responseType: DIO.ResponseType.plain,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
          ),
        )
        .timeout(Duration(seconds: timeoutInSecond));
  }

  Future<DIO.Response> multiPartFile(
    String url,
    DIO.FormData formData,
  ) async {
    String jwtToken = await secure.readData(secure.Token) ?? "";
    return await dioClient.post(
      URLS.api(url),
      data: formData,
      options: DIO.Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      ),
    );
  }
}
