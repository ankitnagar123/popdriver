import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mtaanidriver/route_helper/route_helper.dart';
import 'package:mtaanidriver/service/notification_service.dart';
import 'package:mtaanidriver/utils/my_binding.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'firebase_options.dart';
import 'language/language.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.handleBackgroundTray(message);
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (kIsWeb) {
      WebViewPlatform.instance = WebWebViewPlatform();
    }
    // Web: no Web app in firebase_options yet; FCM + local notification paths are
    // mobile-oriented. Skip Firebase here so Chrome runs for UI/debug.
    // To enable Firebase on web: add a Web app in Firebase Console, then run:
    //   dart pub global activate flutterfire_cli
    //   flutterfire configure -p <projectId> --platforms=web
    if (!kIsWeb) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await NotificationService.initialize();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } else {
      debugPrint(
          'Web: Firebase not initialized (configure Web in Firebase + flutterfire configure). '
          'Push/token APIs are skipped.');
    }

    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }

    runApp(GoyaDriver());
  } catch (e) {
    print("Error initializing app: $e");
    // You can add error reporting here
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('App initialization failed: $e'),
        ),
      ),
    ));
  }
}

class GoyaDriver extends StatefulWidget {
  const GoyaDriver({
    super.key,
  });

  @override
  State<GoyaDriver> createState() => _GoyaDriverState();
}

class _GoyaDriverState extends State<GoyaDriver> {
  @override
  Widget build(BuildContext context) {  
    return GetMaterialApp(
      theme: ThemeData(fontFamily: 'Poppins'),
      /* navigatorKey: widget.navigatorKey,*/
      translations: Locales(),
      locale: Locale('en', 'US'),
      fallbackLocale: Locale('en', 'US'),
      title: 'POP Driver',
      debugShowCheckedModeBanner: false,
      initialBinding: MyBinding(),
      initialRoute: RouteHelper.getSplashScreenRoute(),
      getPages: RouteHelper.routes,
      home: null,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
