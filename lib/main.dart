
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mtaanidriver/route_helper/route_helper.dart';
import 'package:mtaanidriver/service/notification_service.dart';
import 'package:mtaanidriver/utils/my_binding.dart';
import 'firebase_options.dart';
import 'language/language.dart';



final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
 FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print("Message data: ${message.data}");
}
void main()async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  await NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);

  runApp(GoyaDriver());
}


class GoyaDriver extends StatefulWidget {
  const GoyaDriver({super.key,});

  @override
  State<GoyaDriver> createState() => _GoyaDriverState();
}

class _GoyaDriverState extends State<GoyaDriver> {

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
          fontFamily: 'Poppins'
      ),
     /* navigatorKey: widget.navigatorKey,*/
      translations: Locales(),
      locale: Locale('en', 'US'),
      fallbackLocale: Locale('en','US'),
      title: 'POP Driver',
      debugShowCheckedModeBanner: false,
      initialBinding: MyBinding(),
      initialRoute: RouteHelper.getSplashScreenRoute(),
      getPages: RouteHelper.routes,
      home: null,
    );
  }


}
