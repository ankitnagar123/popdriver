
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mpesa_flutter_plugin/initializer.dart';
import 'package:mtaanidriver/route_helper/route_helper.dart';
import 'package:mtaanidriver/service/notification_service.dart';
import 'package:mtaanidriver/utils/my_binding.dart';
import 'firebase_options.dart';
import 'language/language.dart';



final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
 FlutterLocalNotificationsPlugin();

void main()async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  MpesaFlutterPlugin.setConsumerKey("G3yWKFZC8vMigC5EnzdGFlJg2mWEGtpFX6aQ8PKs6dhJZl2d");
  MpesaFlutterPlugin.setConsumerSecret("hktiSrzpVd4QMsbpxqjADz5iumT5Ks9lIo1uGAvV06fhGYLudexJ3DRNnf89PkF8");

  await NotificationService.initialize(flutterLocalNotificationsPlugin);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  final navigatorKey = GlobalKey<NavigatorState>();

  runApp(GoyaDriver());
 /* ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );


  });*/
}


class GoyaDriver extends StatefulWidget {
  /*final GlobalKey<NavigatorState> navigatorKey;*/
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
      locale: Locale('es', 'ES'),
      fallbackLocale: Locale('en','US'),
      title: 'Mtaani Driver',
      debugShowCheckedModeBanner: false,
      initialBinding: MyBinding(),
      initialRoute: RouteHelper.getSplashScreenRoute(),
      getPages: RouteHelper.routes,
      home: null,
    );
  }


}
