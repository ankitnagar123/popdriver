import 'dart:developer';

import 'package:dio/dio.dart'as DIO;
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:mtaanidriver/Network/urls.dart';
import '../utils/shared_preferences.dart';


class ApiService extends GetxService{

  DIO.Dio  dioClient = DIO.Dio();
  final int timeoutInSecond = 30;
  final DIO.LogInterceptor logInterceptor = DIO.LogInterceptor();


  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  SecureStorageService secure = SecureStorageService();

  Future<http.Response> postData(String url, Map<String, dynamic> body) async {

    String jwtToken = await secure.readData(secure.Token) ?? "";
    log("Request URL: ${URLS.BASE_URL + url}");
    log("Request Body: $body");
    log("Bearer: $jwtToken");

    /*final headers = {
      'Authorization': 'Bearer $jwtToken',
    };*/

    try {
      return await http.post(
        Uri.parse(URLS.BASE_URL + url),
        // headers: headers,
        body: body,
      )
          .timeout(Duration(seconds: timeoutInSecond));
    } catch (e) {
      log("HTTP Exception: ${e.toString()}");
      rethrow;
    }
  }

  Future<DIO.Response> postDatas(String url, Map<String, dynamic>body)async{
    DIO.FormData formData = DIO.FormData.fromMap(body);
    String jwtToken = await secure.readData(secure.Token)?? "";

    log("Request URL: ${URLS.BASE_URL + url}");
    log("Request Body: $body");
    log("Bearer: $jwtToken");

    return await dioClient.post(
      url,
      data: formData,
      options: DIO.Options(
        responseType: DIO.ResponseType.plain,
      /*  headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $jwtToken', // Add the JWT token here
        },*/
      ),
    ).timeout(Duration(seconds: timeoutInSecond));
  }

  Future<DIO.Response> postDatatoken(String url, Map<String, dynamic>body)async{
    DIO.FormData formData = DIO.FormData.fromMap(body);
    // Logging the request details
    log("Request URL: ${URLS.BASE_URL + url}");
    log("Request Body: $body");
    return await dioClient.post(
      URLS.BASE_URL + url,
      data: formData,
      options: DIO.Options(
        responseType: DIO.ResponseType.plain,
      ),
    ).timeout(Duration(seconds: timeoutInSecond));
  }

  Future<DIO.Response> getData(String url,) async {

    String jwtToken = await secure.readData(secure.Token)?? "";
    return await dioClient.get(
      URLS.BASE_URL + url,
      options: DIO.Options(
        responseType: DIO.ResponseType.plain,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $jwtToken', // Add the JWT token here
        },
      ),
    ).timeout(Duration(seconds: timeoutInSecond));
  }

  Future<DIO.Response> multiPartFile(String url, DIO.FormData formData,) async {
    String jwtToken = await secure.readData(secure.Token)?? "";
    return await dioClient.post(
      URLS.BASE_URL + url,
      data: formData,
      options: DIO.Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $jwtToken', // Add the JWT token here
        },
      ),
    );
  }

}