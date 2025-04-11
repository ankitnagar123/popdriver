import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../controller/booking_controller.dart';
import '../controller/home_screen_controller.dart';
import '../utils/polyline_handler.dart';


class NotificationService{

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin)async{

        AndroidInitializationSettings androidInitializationSettings=AndroidInitializationSettings('@mipmap/ic_launcher');
        DarwinInitializationSettings darwinInitializationSettings =new DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestCriticalPermission:true,
          requestSoundPermission: true,
          // onDidReceiveLocalNotification:onDidReceiveLocalNotification,
        );

        InitializationSettings initializationSettings=InitializationSettings(
          iOS: darwinInitializationSettings,
          android: androidInitializationSettings
        );

        bool? init= await flutterLocalNotificationsPlugin.initialize(initializationSettings,onDidReceiveNotificationResponse:(NotificationResponse notificationResponse)async{
        },
          onDidReceiveBackgroundNotificationResponse: notificationTapBackground,


        );

        print("flutter local notification${init}");

        NotificationSettings settings =await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        if(settings.authorizationStatus ==AuthorizationStatus.authorized)
          {
            FirebaseMessaging.onBackgroundMessage(backgoundHandler);
              print("notification initialization");
            FirebaseMessaging.onMessage.listen((RemoteMessage message){
              print("firebase notification -------${message}");
              checkNotification(message);
            });
            FirebaseMessaging.onMessageOpenedApp.listen((message){
              print("on message received ==> ${message.notification!.title}");

            });
          }
  }


  static Future<void> showNotification(RemoteMessage message)async{

    final String largeIconPath = await _getImageFilePathFromAssets('assets/images/taxilogos.png');

    final largeIcon = FilePathAndroidBitmap(largeIconPath);

    var darvinDeatils=DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    var androidNotificationDetails=AndroidNotificationDetails(
        "notifications", "Mtaani Driver",
        enableLights: true,
        priority: Priority.max,
        importance: Importance.max,
        largeIcon: largeIcon,
         icon: '@mipmap/ic_launcher',
         color: Colors.transparent,

    );

    NotificationDetails notificationDetails= NotificationDetails(android:androidNotificationDetails,iOS: darvinDeatils );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();



    flutterLocalNotificationsPlugin.show(0, message.notification!.title, message.notification!.body, notificationDetails,payload: message.notification!.title);

    log("title---------------->${message.notification!.title}");
    log("body---------------->${message.notification!.body}");

    Get.find<BookingController>().rideNowBooking();
    Get.find<BookingController>().rideLaterBooking();

    if(message.notification!.title == "Booking Cancellation"){
      HomeController contoller = Get.find<HomeController>();
      contoller.markers.clear();
      Get.find<BookingController>().completeText.value = "";
      contoller.polylineVariable.value = "";
      contoller.polylineVariable2.value = "";
      contoller.driverArriveValue.value = false;
      contoller.arriveDriver.value = "";
      contoller.painButton.value = false;
      contoller.onOff.value = true;
      contoller.hide.value = false;
      polyline.clear();
      log("clear -----");
    }
  }


  static void checkNotification(RemoteMessage message){
    if(message.notification!.title == "Booking Cancel"){
      Get.find<BookingController>().rideNowBooking();
      Get.find<BookingController>().rideLaterBooking();
    }else{
      showNotification(message);
    }

  }

}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload){
  print('onDidReceiveLocalNotification==>');
}


Future<void> backgoundHandler(RemoteMessage message) async{
  print("background Remote message Handler==>${message}");
}

void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) action tapped:'
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}


Future<String> _getImageFilePathFromAssets(String asset) async {
  final byteData = await rootBundle.load(asset);
  final file = File('${(await getTemporaryDirectory()).path}/taxilogos.png');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  return file.path;
}


