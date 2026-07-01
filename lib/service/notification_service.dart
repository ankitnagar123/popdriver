import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' show File;

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../controller/booking_controller.dart';
import '../controller/home_screen_controller.dart';
import '../utils/booking_cancellation_dialog.dart';
import '../utils/platform_helper.dart';
import '../utils/polyline_handler.dart';

/// Android `res/raw/booking_ring.mp3` → use name without extension.
const String _kBookingAndroidRawSound = 'booking_ring';
const String _kBookingCancelAndroidRawSound = 'bookingcancel';

/// New channel ID so OEMs pick up custom sound instead of caching old defaults.
/// Ringing tray channel (background / killswitch path).
const String _kBookingChannelId = 'pop_driver_booking_ring_v5';
const String _kBookingCancelChannelId = 'pop_driver_booking_cancel_v1';
/// Foreground bookings: tray must be silent — Android ignores per-notification
/// mute when the notification channel declares a sound; use a silent channel.
const String _kBookingFgSilentChannelId = 'pop_driver_booking_fg_silent_v6';
const String _kDefaultChannelId = 'notifications';

/// Plays in-app booking ring (~5 seconds) — works foreground (and resumed app).
/// System tray uses `booking_ring` on Android (`res/raw/`).
class BookingRingPlayer {
  static AudioPlayer? _player;
  static Timer? _stopTimer;

  static Future<void> playFiveSeconds() async {
    if (kIsWeb) return;

    await BookingCancelPlayer.stopImmediate();
    await stopImmediate();
    try {
      final p = AudioPlayer();
      await p.setReleaseMode(ReleaseMode.stop);
      /// audioplayers prefixes `assets/` — do not pass `assets/...` or path doubles.
      await p.play(AssetSource('sound/booking_ring.mp3'));
      _player = p;
      _stopTimer = Timer(const Duration(seconds: 5), stopImmediate);
    } catch (e, st) {
      log('booking ring playback error', error: e, stackTrace: st);
      await stopImmediate();
    }
  }

  static Future<void> stopImmediate() async {
    _stopTimer?.cancel();
    _stopTimer = null;
    try {
      await _player?.stop();
      await _player?.dispose();
    } catch (_) {
      /* ignore */
    }
    _player = null;
  }
}

/// Plays [assets/sound/bookingcancel.mp3] for ~5 seconds (booking cancelled).
class BookingCancelPlayer {
  static AudioPlayer? _player;
  static Timer? _stopTimer;

  static Future<void> playFiveSeconds() async {
    if (kIsWeb) return;

    await BookingRingPlayer.stopImmediate();
    await stopImmediate();
    try {
      final p = AudioPlayer();
      await p.setReleaseMode(ReleaseMode.stop);
      await p.play(AssetSource('sound/bookingcancel.mp3'));
      _player = p;
      _stopTimer = Timer(const Duration(seconds: 5), stopImmediate);
    } catch (e, st) {
      log('booking cancel sound playback error', error: e, stackTrace: st);
      await stopImmediate();
    }
  }

  static Future<void> stopImmediate() async {
    _stopTimer?.cancel();
    _stopTimer = null;
    try {
      await _player?.stop();
      await _player?.dispose();
    } catch (_) {
      /* ignore */
    }
    _player = null;
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static String notificationTitleLc(RemoteMessage message) {
    final n = message.notification?.title;
    if (n != null && n.trim().isNotEmpty) {
      return n.trim().toLowerCase();
    }
    final d =
        message.data['title'] ?? message.data['gcm.notification.title'] ?? '';
    return d.toString().trim().toLowerCase();
  }

  /// Matches FCM titles like `New booking request` (also if extra words/tags).
  static bool isNewBookingRequest(RemoteMessage message) =>
      notificationTitleLc(message).contains('new booking request');

  /// Matches titles like `Booking Cancellation`, `Booking cancel`.
  static bool isBookingCancellation(RemoteMessage message) =>
      notificationTitleLc(message).contains('booking cancel');

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: darwinInitializationSettings,
      android: androidInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        log('Notification clicked: ${notificationResponse.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _ensureAndroidBookingChannel();
    await _ensureAndroidBookingCancelChannel();
    await _ensureAndroidForegroundSilentBookingChannel();

    final NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      /// Background handler MUST be registered in `main.dart` only once
      /// (`FirebaseMessaging.onBackgroundMessage`). Do not register here.

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Foreground FCM message: ${message.notification}');
        showNotificationForeground(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('Opened from tray: ${message.notification?.title}');
        if (isBookingCancellation(message)) {
          _handleBookingCancellationNotification(message);
        }
      });
    }
  }

  static Future<void> _ensureAndroidBookingCancelChannel() async {
    if (!isAndroid) return;
    try {
      final android = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kBookingCancelChannelId,
          'Booking cancelled',
          description: 'User cancelled ride — tray sound',
          importance: Importance.max,
          playSound: true,
          sound:
              RawResourceAndroidNotificationSound(_kBookingCancelAndroidRawSound),
        ),
      );
    } catch (e, st) {
      log('createBookingCancelChannel failed', error: e, stackTrace: st);
    }
  }

  static Future<void> _ensureAndroidForegroundSilentBookingChannel() async {
    if (!isAndroid) return;
    try {
      final android = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kBookingFgSilentChannelId,
          'Booking (in app)',
          description:
              'Shown while app is open — no tray sound (ring handled in app)',
          importance: Importance.max,
          playSound: false,
        ),
      );
    } catch (e, st) {
      log('createSilentBookingChannel failed', error: e, stackTrace: st);
    }
  }

  static Future<void> _ensureAndroidBookingChannel() async {
    if (!isAndroid) return;
    try {
      final android = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kBookingChannelId,
          'Booking alerts',
          description: 'New ride requests — custom ringtone',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(_kBookingAndroidRawSound),
        ),
      );
    } catch (e, st) {
      log('createNotificationChannel failed', error: e, stackTrace: st);
    }
  }

  /// Called from Firebase background isolate (`main.dart` entrypoint).
  @pragma('vm:entry-point')
  static Future<void> handleBackgroundTray(RemoteMessage message) async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      await plugin.initialize(
        const InitializationSettings(
          android: androidInit,
          iOS: iosInit,
        ),
      );

      if (isAndroid) {
        final androidPlugin = plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.createNotificationChannel(
          const AndroidNotificationChannel(
            _kBookingChannelId,
            'Booking alerts',
            description: 'New ride requests — custom ringtone',
            importance: Importance.max,
            playSound: true,
            sound:
                RawResourceAndroidNotificationSound(_kBookingAndroidRawSound),
          ),
        );
        await androidPlugin?.createNotificationChannel(
          const AndroidNotificationChannel(
            _kBookingCancelChannelId,
            'Booking cancelled',
            description: 'User cancelled ride — tray sound',
            importance: Importance.max,
            playSound: true,
            sound:
                RawResourceAndroidNotificationSound(_kBookingCancelAndroidRawSound),
          ),
        );
      }

      await _presentLocalNotification(
        plugin: plugin,
        message: message,
        allowHeavyAssets: false,
        /// Background isolate: tray must play ring (no in-app AudioPlayer).
        suppressBookingTraySound: false,
      );
      log('Background tray notification: ${message.notification?.title}');
    } catch (e, st) {
      log('handleBackgroundTray failed', error: e, stackTrace: st);
    }
  }

  static Future<void> showNotificationForeground(RemoteMessage message) async {
    await _presentLocalNotification(
      plugin: _flutterLocalNotificationsPlugin,
      message: message,
      allowHeavyAssets: true,
      /// Avoid double audio: tray `booking_ring` + [BookingRingPlayer] both played.
      suppressBookingTraySound: true,
    );

    if (isNewBookingRequest(message)) {
      BookingRingPlayer.playFiveSeconds();
    }

    log('Notification Shown: ${message.notification?.title}');

    try {
      if (isBookingCancellation(message)) {
        _handleBookingCancellationNotification(message);
        return;
      }

      Get.find<BookingController>().rideNowBooking();
    } catch (e, st) {
      log('post-notification GetX handlers failed',
          error: e, stackTrace: st);
    }
  }

  static void _handleBookingCancellationNotification(RemoteMessage message) {
    BookingCancelPlayer.playFiveSeconds();

    final bookingId = BookingCancellationDialog.extractBookingId(message);
    try {
      final homeController = Get.find<HomeController>();
      homeController.markers.clear();
      Get.find<BookingController>().completeText.value = '';
      homeController.polylineVariable.value = '';
      homeController.polylineVariable2.value = '';
      homeController.driverArriveValue.value = false;
      homeController.arriveDriver.value = '';
      homeController.painButton.value = false;
      homeController.onOff.value = true;
      homeController.hide.value = false;
      polyline.clear();
      Get.find<BookingController>()
          .handleUserSideCancellationShowDialog(bookingId);
      log('booking cancellation handled — id: $bookingId');
    } catch (e, st) {
      log('booking cancellation handler failed', error: e, stackTrace: st);
      if (bookingId.isNotEmpty) {
        BookingCancellationDialog.show(bookingId);
      }
    }
  }

  /// When true and notifications that use in-app playback (new booking /
  /// cancellation) post to the silent Android channel instead of ringing twice.
  static Future<void> _presentLocalNotification({
    required FlutterLocalNotificationsPlugin plugin,
    required RemoteMessage message,
    required bool allowHeavyAssets,
    required bool suppressBookingTraySound,
  }) async {
    final title = message.notification?.title ?? 'POP Driver';
    final body =
        message.notification?.body ?? message.data.toString();

    FilePathAndroidBitmap? largeIcon;
    if (allowHeavyAssets) {
      try {
        final path =
            await _getImageFilePathFromAssets('assets/images/backgoundLogo.png');
        largeIcon = FilePathAndroidBitmap(path);
      } catch (e, st) {
        log('large icon skip', error: e, stackTrace: st);
      }
    }

    final isBookingReq = isNewBookingRequest(message);
    final isBookingCancelled = isBookingCancellation(message);
    final muteFgTray = suppressBookingTraySound &&
        (isBookingReq || isBookingCancelled);

    /// Android Oreo+: sound comes from the **channel**; foreground uses silent
    /// channels + [BookingRingPlayer] / [BookingCancelPlayer].
    late final AndroidNotificationDetails androidDetails;
    if (!isBookingReq && !isBookingCancelled) {
      androidDetails = AndroidNotificationDetails(
        _kDefaultChannelId,
        'POP Driver',
        enableLights: true,
        priority: Priority.high,
        importance: Importance.max,
        largeIcon: largeIcon,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        color: Colors.transparent,
      );
    } else if (muteFgTray) {
      androidDetails = AndroidNotificationDetails(
        _kBookingFgSilentChannelId,
        'Booking (in app)',
        channelDescription:
            'Heads-up while app open — sound plays inside app (~5 seconds)',
        enableLights: true,
        priority: Priority.high,
        importance: Importance.max,
        largeIcon: largeIcon,
        icon: '@mipmap/ic_launcher',
        playSound: false,
        enableVibration: false,
        color: Colors.transparent,
      );
    } else if (isBookingReq) {
      androidDetails = AndroidNotificationDetails(
        _kBookingChannelId,
        'Booking alerts',
        channelDescription:
            'New ride requests — custom ringtone ($_kBookingAndroidRawSound.mp3 in res/raw)',
        enableLights: true,
        priority: Priority.high,
        importance: Importance.max,
        largeIcon: largeIcon,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        sound: const RawResourceAndroidNotificationSound(
            _kBookingAndroidRawSound),
        color: Colors.transparent,
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        _kBookingCancelChannelId,
        'Booking cancelled',
        channelDescription:
            'User cancelled — tray sound ($_kBookingCancelAndroidRawSound.mp3 in res/raw)',
        enableLights: true,
        priority: Priority.high,
        importance: Importance.max,
        largeIcon: largeIcon,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        sound: const RawResourceAndroidNotificationSound(
            _kBookingCancelAndroidRawSound),
        color: Colors.transparent,
      );
    }

    final darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: !muteFgTray,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final int notificationId =
        (message.hashCode ^ DateTime.now().millisecondsSinceEpoch) &
            0x7fffffff;

    await plugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  /// Kept if something still calls `showNotification`; forwards to foreground.
  static Future<void> showNotification(RemoteMessage message) =>
      showNotificationForeground(message);

  static void checkNotification(RemoteMessage message) {
    if (notificationTitleLc(message) == 'booking cancel') {
      Get.find<BookingController>().rideNowBooking();
    } else {
      showNotificationForeground(message);
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  log('notification(${notificationResponse.id}) action:'
      '${notificationResponse.actionId} payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    log('notification tapped with typed input');
  }
}

Future<String> _getImageFilePathFromAssets(String asset) async {
  final byteData = await rootBundle.load(asset);
  final file =
      File('${(await getTemporaryDirectory()).path}/backgoundLogo.png');
  await file.writeAsBytes(byteData.buffer.asUint8List(
      byteData.offsetInBytes, byteData.lengthInBytes));
  return file.path;
}
