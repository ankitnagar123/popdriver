import 'dart:async';
import 'dart:developer';

import '../../controller/permision_controller.dart';
import '../../controller/splace_controller.dart';
import '../../route_helper/route_helper.dart';
import '../../service/notification_service.dart';
import '../../utils/colors.dart';
import '../../utils/platform_helper.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/snackBar.dart';
import '../../utils/web_geolocation.dart';
import '../../utils/web_push_notification.dart';
import '../../utils/web_splash_bootstrap.dart';
import '../../controller/auth_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:root_checker_plus/root_checker_plus.dart';

// Root directory checks use `File` — mobile only (never called on web).
import 'root_check_io.dart' if (dart.library.html) 'root_check_stub.dart'
    as root_check;

class SplashScreen extends StatefulWidget {
  SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  SecureStorageService secure = SecureStorageService();
  PermissionController? controller;
  AuthController? controllers;
  SplashController splashController = Get.put(SplashController());
  bool _webPermissionBusy = false;
  bool _showWebPermissionCard = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    try {
      print("Attempting to find controllers...");
      controller = Get.find<PermissionController>();
      controllers = Get.find<AuthController>();
      print("Controllers found successfully");

      _startSplashFlow();
    } catch (e) {
      print("Error initializing controllers: $e");
      print("Stack trace: ${StackTrace.current}");
      // Fallback: try to get controllers with put if find fails
      try {
        controller = Get.put(PermissionController());
        controllers = Get.put(AuthController());
        print("Controllers created successfully as fallback");

        _startSplashFlow();
      } catch (fallbackError) {
        print("Error in fallback controller creation: $fallbackError");
        _startSplashFlow();
      }
    }
  }

  /// No longer calls the unimplemented `developer_mode` platform channel (would throw
  /// [MissingPluginException] in release and block the splash). Optional root check on Android release only.
  void _startSplashFlow() {
    if (isWeb) {
      _startWebSplashFlow();
      return;
    }
    if (!isAndroid) {
      requestLocationPermission();
      return;
    }
    if (kReleaseMode) {
      _checkRootThenProceed();
    } else {
      requestLocationPermission();
    }
  }

  void _startWebSplashFlow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_prepareWebSplash());
    });
  }

  Future<void> _prepareWebSplash() async {
    final notifOk = isBrowserNotificationPermissionGranted();
    final locOk = await isBrowserLocationPermissionGranted();
    if (!mounted) return;
    if (notifOk && locOk) {
      unawaited(NotificationService.ensureWebPushReady());
      getData();
      return;
    }
    setState(() => _showWebPermissionCard = true);
  }

  Future<void> _onWebAllowPermissions() async {
    if (_webPermissionBusy) return;
    setState(() => _webPermissionBusy = true);
    try {
      await WebSplashBootstrap.requestPermissionsOnUserGesture();
    } finally {
      if (mounted) {
        setState(() {
          _webPermissionBusy = false;
          _showWebPermissionCard = false;
        });
        getData();
      }
    }
  }

  void _onWebSkipPermissions() {
    setState(() => _showWebPermissionCard = false);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/POP DRIVER.gif',
            ),
          ),
          if (kIsWeb && _showWebPermissionCard)
            Positioned(
              left: 20,
              right: 20,
              bottom: 32,
              child: _WebPermissionCard(
                busy: _webPermissionBusy,
                onAllow: _onWebAllowPermissions,
                onSkip: _onWebSkipPermissions,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _checkRootThenProceed() async {
    try {
      final bool? isRooted = await RootCheckerPlus.isRootChecker();
      final bool hasRootDirectories = await root_check.checkRootPathsExist();
      if (!mounted) return;
      if (isRooted == true || hasRootDirectories) {
        handleRootDetection();
      } else {
        requestLocationPermission();
      }
    } catch (e, st) {
      log('Root check failed (proceeding to app): $e', stackTrace: st);
      if (!mounted) return;
      requestLocationPermission();
    }
  }

  void handleRootDetection() {
    // Show an alert or prevent app functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rooted Device Detected'),
          content: Text(
              'Your device is rooted. This app cannot run on rooted devices for security reasons.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Handle app exit or restricted functionality
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> requestLocationPermission() async {
    if (isWeb) {
      // Do not call requestPermission() here — Safari blocks / silent-denies
      // prompts that are not from a user gesture. Continue app flow only.
      getData();
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Turn on Location Services'),
          content: const Text(
            'Location services are turned off. Please enable them to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await requestLocationPermission();
              },
              child: const Text('Check again'),
            ),
          ],
        ),
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      getData();
      if (!isWeb) {
        controller?.getCurrentPosition();
        controller?.permissionHandle();
      }
      return;
    }

    if (permission == LocationPermission.denied) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Location permission required'),
          content: const Text(
            'To show your live location on the map, please allow location access.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await requestLocationPermission();
              },
              child: const Text('Allow'),
            ),
          ],
        ),
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Enable location access'),
          content: const Text(
            'Location permission is permanently denied. Please open app settings and set Location to "While Using".',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openAppSettings();
              },
              child: const Text('Open App Settings'),
            ),
            TextButton(
              onPressed: () async {
                final latest = await Geolocator.checkPermission();
                if (latest == LocationPermission.whileInUse ||
                    latest == LocationPermission.always) {
                  Navigator.of(context).pop();
                  getData();
                  if (!isWeb) {
                    controller?.getCurrentPosition();
                    controller?.permissionHandle();
                  }
                } else {
                  customSnackBar('Location permission is still not granted.');
                }
              },
              child: const Text('I have enabled it'),
            ),
          ],
        ),
      );
    }
  }

  void getData() async {
    final onboardingDone =
        await sp.getBoolValue(sp.ON_BOARDING_KEY) == true;
    final loginKeyTrue = await sp.getBoolValue(sp.LOGIN_KEY) == true;
    final uid = await secure.readData(secure.user_id);
    final token = await secure.readData(secure.Token);

    log("OnBoarding key ------>:$onboardingDone");
    log("Language key ------>:${await sp.getStringValue(sp.LANGUAGE)}");
    log("secure key ------>:$uid");

    /// Treat as logged in if secure storage has a session, even when
    /// [ON_BOARDING_KEY] was lost (fixes returning to onboarding after restart).
    final hasSecureSession = uid != null &&
        uid.isNotEmpty &&
        token != null &&
        token.isNotEmpty;
    final isLoggedIn = hasSecureSession ||
        (loginKeyTrue && uid != null && uid.isNotEmpty);

    if (await sp.getStringValue(sp.LANGUAGE) == "en_US") {
      Get.updateLocale(Locale('en', 'US'));
    } else {
      final local = Locale('es', 'ES');
      await sp.setStringValue(sp.LANGUAGE, local.toString());
    }

    if (isLoggedIn) {
      if (!onboardingDone) {
        await sp.setBoolValue(sp.ON_BOARDING_KEY, true);
      }
      if (!loginKeyTrue && hasSecureSession) {
        await sp.setBoolValue(sp.LOGIN_KEY, true);
      }
      Timer(const Duration(seconds: 3), () {
        Get.offNamed(RouteHelper.getHomeScreenScreenRoute(),
            arguments: {"ArriveDriver": ""});
      });
    } else if (!onboardingDone) {
      Timer(const Duration(seconds: 3), () {
        Get.offNamed(RouteHelper.getOnBoardingScreenRoute());
      });
    } else {
      Timer(const Duration(seconds: 3), () {
        Get.offNamed(RouteHelper.getLoginScreenRoute());
      });
    }
  }
}
class _WebPermissionCard extends StatelessWidget {
  const _WebPermissionCard({
    required this.busy,
    required this.onAllow,
    required this.onSkip,
  });

  final bool busy;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enable location & notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MyColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Allow access so we can show your map location and send new booking alerts.',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.35),
            ),
            const SizedBox(height: 16),
            if (busy)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: onAllow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Allow'),
              ),
            TextButton(
              onPressed: busy ? null : onSkip,
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}

