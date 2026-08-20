import 'dart:async';
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

import 'package:shared_preferences/shared_preferences.dart';

import '../controller/booking_controller.dart';
import '../controller/home_screen_controller.dart';
import '../utils/booking_cancellation_dialog.dart';
import '../utils/firebase_messaging_config.dart';
import '../utils/platform_helper.dart';
import '../utils/polyline_handler.dart';
import '../utils/shared_preferences.dart';
import '../utils/web_push_notification.dart';
import 'booking_incoming_service.dart';
import 'device_token_sync.dart';

/// Android `res/raw/booking_ring.mp3` → name without extension.
const String _kBookingAndroidRawSound = 'booking_ring';
const String _kBookingCancelAndroidRawSound = 'bookingcancel';

/// New channel IDs so OEMs pick up custom sound (Android caches old channels).
const String _kBookingChannelId = 'pop_driver_booking_ring_v8';
const String _kBookingCancelChannelId = 'pop_driver_booking_cancel_v2';

/// Foreground: silent tray — in-app [BookingRingManager] plays custom MP3.
const String _kBookingFgSilentChannelId = 'pop_driver_booking_fg_silent_v8';
const String _kDefaultChannelId = 'notifications';

/// Fixed tray id so we can cancel the booking alert when driver accepts.
const int _kBookingAlertNotificationId = 9001;

/// Central booking ring — fixed ~8s play, online-only, once per booking id.
class BookingRingManager {
  BookingRingManager._();

  static const Duration _ringDuration = Duration(seconds: 8);

  static AudioPlayer? _player;
  static Timer? _stopTimer;
  static String? _ringingForBookingId;
  static final Set<String> _announcedBookingIds = <String>{};

  static bool canRingFromControllers() {
    try {
      final home = Get.find<HomeController>();
      if (!home.onOff.value) return false;
      if (home.hide.value || home.driverArriveValue.value) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canRingFromStorage() async {
    try {
      final sp = SharedPreferencesCrDriver();
      final online = await sp.getBoolValue(sp.DRIVER_ONLINE_STATUS);
      return online == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _canRing() async {
    if (canRingFromControllers()) return true;
    return canRingFromStorage();
  }

  static void markBookingAnnounced(String bookingId) {
    final id = bookingId.trim();
    if (id.isEmpty || id == 'pending') return;
    _announcedBookingIds.add(id);
    _trimAnnouncedSet();
  }

  /// Poll fallback — ring only once per new booking id (never re-ring on resume).
  static Future<void> syncWithPendingBookings(List<String> bookingIds) async {
    final ids = bookingIds.where((id) => id.trim().isNotEmpty).toList();
    if (!canRingFromControllers()) {
      await stopImmediate();
      return;
    }
    if (ids.isEmpty) {
      // Incoming booking vanished while ringing → passenger cancelled (poll path).
      final wasRinging = _ringingForBookingId != null;
      if (wasRinging) {
        await stopImmediate();
        unawaited(BookingCancelPlayer.playFiveSeconds());
      }
      return;
    }

    final targetId = ids.first;
    if (_announcedBookingIds.contains(targetId)) {
      return;
    }

    // Mobile background: notification plays sound — skip in-app audio to avoid double ring.
    // Web has no reliable background tray sound — always play in-app.
    if (!kIsWeb && BookingIncomingService.instance.isAppInBackground) {
      markBookingAnnounced(targetId);
      return;
    }

    await _startRingForBooking(targetId, showTrayInForeground: false);
  }

  /// FCM or explicit new-booking signal.
  static Future<void> onNewBookingDetected({
    String? bookingId,
    bool showTraySound = false,
  }) async {
    if (!await _canRing()) return;

    final id = (bookingId ?? '').trim();
    if (id.isNotEmpty && _announcedBookingIds.contains(id)) {
      return;
    }
    if (id.isNotEmpty &&
        _ringingForBookingId == id &&
        _player?.state == PlayerState.playing) {
      return;
    }

    await _startRingForBooking(
      id.isNotEmpty ? id : 'pending',
      showTrayInForeground: showTraySound,
    );
  }

  static Future<void> _startRingForBooking(
    String bookingId, {
    required bool showTrayInForeground,
  }) async {
    if (!await _canRing()) return;

    _ringingForBookingId = bookingId;
    if (bookingId != 'pending') {
      _announcedBookingIds.add(bookingId);
      _trimAnnouncedSet();
    }

    await BookingCancelPlayer.stopImmediate();
    await _stopPlayerOnly();

    try {
      final p = AudioPlayer();
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setVolume(1.0);
      await p.play(AssetSource('sound/booking_ring.mp3'));
      _player = p;
      _stopTimer?.cancel();
      _stopTimer = Timer(_ringDuration, stopImmediate);
      log('booking ring started for #$bookingId (${_ringDuration.inSeconds}s)'
          '${kIsWeb ? ' [web]' : ''}');
    } catch (e, st) {
      log('booking ring playback error', error: e, stackTrace: st);
      await stopImmediate();
      return;
    }

    // Foreground: silent tray + in-app audio only (Android).
    if (!kIsWeb && canRingFromControllers() && !showTrayInForeground) {
      await _showBookingAlertTray(playSound: false);
    }
  }

  static void _trimAnnouncedSet() {
    if (_announcedBookingIds.length <= 40) return;
    _announcedBookingIds.clear();
    try {
      for (final b in Get.find<BookingController>().rideNowList) {
        if (b.bookingId.isNotEmpty) {
          _announcedBookingIds.add(b.bookingId);
        }
      }
    } catch (_) {
      /* ignore */
    }
  }

  static Future<void> _showBookingAlertTray({required bool playSound}) async {
    if (!isAndroid) return;
    try {
      final androidDetails = AndroidNotificationDetails(
        playSound ? _kBookingChannelId : _kBookingFgSilentChannelId,
        playSound ? 'Booking alerts' : 'Booking (in app)',
        channelDescription: playSound
            ? 'New ride requests — custom ringtone'
            : 'Heads-up while app open — sound plays inside app',
        enableLights: true,
        priority: Priority.max,
        importance: Importance.max,
        icon: '@mipmap/ic_launcher',
        playSound: playSound,
        sound: playSound
            ? const RawResourceAndroidNotificationSound(
                _kBookingAndroidRawSound)
            : null,
        ongoing: true,
        autoCancel: false,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: playSound,
        visibility: NotificationVisibility.public,
      );
      await NotificationService._flutterLocalNotificationsPlugin.show(
        _kBookingAlertNotificationId,
        'New ride request',
        'Tap to open and accept the ride',
        NotificationDetails(android: androidDetails),
      );
    } catch (e, st) {
      log('booking alert tray failed', error: e, stackTrace: st);
    }
  }

  static Future<void> _stopPlayerOnly() async {
    try {
      await _player?.stop();
      await _player?.dispose();
    } catch (_) {
      /* ignore */
    }
    _player = null;
  }

  static Future<void> stopImmediate() async {
    _stopTimer?.cancel();
    _stopTimer = null;
    _ringingForBookingId = null;
    await _stopPlayerOnly();
    try {
      await NotificationService._flutterLocalNotificationsPlugin
          .cancel(_kBookingAlertNotificationId);
    } catch (_) {
      /* ignore */
    }
  }

  static Future<void> unlockAudioForWeb() async {
    if (!kIsWeb) return;
    try {
      final p = AudioPlayer();
      await p.setVolume(0.0);
      await p.play(AssetSource('sound/booking_ring.mp3'));
      await p.stop();
      await p.dispose();
      log('web audio unlocked');
    } catch (e) {
      log('web audio unlock failed: $e');
    }
  }

  static void clearSession() {
    _announcedBookingIds.clear();
    stopImmediate();
  }
}

/// Back-compat alias — delegates to [BookingRingManager].
class BookingRingPlayer {
  static Future<void> playFiveSeconds() =>
      BookingRingManager.onNewBookingDetected();

  static Future<void> stopImmediate() => BookingRingManager.stopImmediate();
}

/// Plays [assets/sound/bookingcancel.mp3] for ~5 seconds (booking cancelled).
class BookingCancelPlayer {
  static AudioPlayer? _player;
  static Timer? _stopTimer;

  static Future<void> playFiveSeconds() async {
    await BookingRingManager.stopImmediate();
    await stopImmediate();
    try {
      final p = AudioPlayer();
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setVolume(1.0);
      await p.play(AssetSource('sound/bookingcancel.mp3'));
      _player = p;
      _stopTimer = Timer(const Duration(seconds: 5), stopImmediate);
      log('booking cancel sound started${kIsWeb ? ' [web]' : ''}');
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
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _mobileListenersBound = false;
  static bool _webListenersBound = false;
  static bool _initialMessageChecked = false;
  static bool _serviceInitialized = false;

  /// pop_user-style push logging — copy FCM token from console for Firebase test sends.
  static void logRemoteMessage(String source, RemoteMessage message) {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title']?.toString() ?? '';
    final body = notification?.body ?? message.data['body']?.toString() ?? '';
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔔 PUSH [$source]');
    debugPrint('  messageId : ${message.messageId ?? '-'}');
    debugPrint('  from      : ${message.from ?? '-'}');
    debugPrint('  sentTime  : ${message.sentTime ?? '-'}');
    debugPrint('  title     : $title');
    debugPrint('  body      : $body');
    debugPrint('  data      : ${message.data}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static void _logNotificationTap(String source,
      {String? title, String? payload}) {
    debugPrint('👆 NOTIFICATION TAP [$source] title=$title payload=$payload');
  }

  static String notificationTitleLc(RemoteMessage message) {
    final n = message.notification?.title;
    if (n != null && n.trim().isNotEmpty) {
      return n.trim().toLowerCase();
    }
    final d =
        message.data['title'] ?? message.data['gcm.notification.title'] ?? '';
    return d.toString().trim().toLowerCase();
  }

  static String notificationBodyLc(RemoteMessage message) {
    final n = message.notification?.body;
    if (n != null && n.trim().isNotEmpty) {
      return n.trim().toLowerCase();
    }
    final d = message.data['body'] ??
        message.data['message'] ??
        message.data['gcm.notification.body'] ??
        '';
    return d.toString().trim().toLowerCase();
  }

  /// Matches FCM titles / payloads for new booking (flexible).
  static bool isNewBookingRequest(RemoteMessage message) {
    final t = notificationTitleLc(message);
    final b = notificationBodyLc(message);
    final type = (message.data['type'] ??
            message.data['push_type'] ??
            message.data['notification_type'] ??
            '')
        .toString()
        .toLowerCase();
    return t.contains('new booking') ||
        t.contains('booking request') ||
        t.contains('ride request') ||
        t.contains('new ride') ||
        b.contains('new booking') ||
        type.contains('booking') ||
        type.contains('ride_request') ||
        type.contains('meta-request');
  }

  /// Matches titles like `Booking Cancellation`, `Booking cancel`.
  static bool isBookingCancellation(RemoteMessage message) {
    final t = notificationTitleLc(message);
    final b = notificationBodyLc(message);
    return t.contains('booking cancel') ||
        t.contains('cancelled') ||
        t.contains('canceled') ||
        b.contains('booking cancel') ||
        b.contains('cancelled');
  }

  static Future<void> initialize() async {
    if (kIsWeb) {
      await _initializeWebMessaging();
      return;
    }
    if (_serviceInitialized) return;
    _serviceInitialized = true;

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
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
        _logNotificationTap(
          'LOCAL',
          title: notificationResponse.payload,
          payload: notificationResponse.payload,
        );
        BookingIncomingService.instance.handleNotificationResponse(
          actionId: notificationResponse.actionId,
          payload: notificationResponse.payload,
        );
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _ensureAndroidBookingChannel();
    await _ensureAndroidBookingCancelChannel();
    await _ensureAndroidForegroundSilentBookingChannel();

    // Cold start from Accept/Pass notification while app was killed.
    try {
      final launchDetails = await _flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final response = launchDetails!.notificationResponse;
        if (response != null) {
          await BookingIncomingService.persistNotificationResponse(
            actionId: response.actionId,
            payload: response.payload,
          );
        }
      }
    } catch (e, st) {
      log('getNotificationAppLaunchDetails failed', error: e, stackTrace: st);
    }

    // Android 13+ notification permission for local notifications.
    if (isAndroid) {
      try {
        final android = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await android?.requestNotificationsPermission();
      } catch (e) {
        log('requestNotificationsPermission: $e');
      }
    }

    if (isIOS) {
      try {
        final ios = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS local notification permission granted: $granted');
      } catch (e) {
        debugPrint('iOS local notification permission error: $e');
      }
    }

    final NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (isIOS) {
      // pop_user pattern: never auto-show FCM banner in foreground (prevents double alert).
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    }

    final notificationsAllowed =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    if (notificationsAllowed) {
      debugPrint(
          'Firebase Messaging permission: ${settings.authorizationStatus}');
    } else {
      debugPrint(
        'Notification permission denied: ${settings.authorizationStatus}',
      );
    }

    // Bind on all mobile platforms — some OEMs deliver before status is "authorized".
    _bindFirebaseListeners();

    log('FCM auth status: ${settings.authorizationStatus}');
  }

  static void _bindFirebaseListeners() {
    if (_mobileListenersBound) return;
    _mobileListenersBound = true;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logRemoteMessage('FOREGROUND (onMessage)', message);
      unawaited(showNotificationForeground(message));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logRemoteMessage('OPENED_APP (tap)', message);
      if (isBookingCancellation(message)) {
        _handleBookingCancellationNotification(message);
      }
    });

    if (!_initialMessageChecked) {
      _initialMessageChecked = true;
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message == null) return;
        logRemoteMessage('INITIAL (cold start)', message);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isBookingCancellation(message)) {
            _handleBookingCancellationNotification(message);
          }
        });
      });
    }
    
    debugPrint('NotificationService: FCM listeners bound');
  }

  /// Retry permission + token from a user tap (Online). Safe to call many times.
  static Future<void> ensureWebPushReady() async {
    if (!kIsWeb) return;
    await _initializeWebMessaging();
  }

  static Future<void> _resolveAndPersistWebToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: FirebaseMessagingConfig.webVapidKey,
      );
      if (token != null && token.isNotEmpty) {
        log('Web FCM token ready (len=${token.length})');
        debugPrint('Web FCM token for Firebase Console test: $token');
        await DeviceTokenSync.persistFirebaseToken(token);
        unawaited(DeviceTokenSync.syncAfterLogin());
      } else {
        log('Web FCM token missing — push may fail; poll fallback active');
      }
    } catch (e, st) {
      log('Web FCM getToken failed', error: e, stackTrace: st);
    }
  }

  static Future<void> _initializeWebMessaging() async {
    try {
      await registerFcmServiceWorker();

      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      log('Web FCM auth status: ${settings.authorizationStatus}');

      await _resolveAndPersistWebToken();

      if (_webListenersBound) return;
      _webListenersBound = true;

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        if (token.isEmpty) return;
        log('Web FCM onTokenRefresh (len=${token.length})');
        unawaited(DeviceTokenSync.persistFirebaseToken(token));
        unawaited(DeviceTokenSync.syncAfterLogin());
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        logRemoteMessage('WEB FOREGROUND (onMessage)', message);
        unawaited(showNotificationForeground(message));
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        logRemoteMessage('WEB OPENED_APP (tap)', message);
        if (isBookingCancellation(message)) {
          _handleBookingCancellationNotification(message);
        } else if (isNewBookingRequest(message)) {
          unawaited(showNotificationForeground(message));
        }
      });

      if (!_initialMessageChecked) {
        _initialMessageChecked = true;
        final initial = await FirebaseMessaging.instance.getInitialMessage();
        if (initial != null) {
          logRemoteMessage('WEB INITIAL (cold start)', initial);
          if (isBookingCancellation(initial)) {
            _handleBookingCancellationNotification(initial);
          }
        }
      }
    } catch (e, st) {
      log('Web FCM init failed', error: e, stackTrace: st);
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
          description: 'User cancelled ride — custom sound',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(
              _kBookingCancelAndroidRawSound),
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
              'Shown while app open — no tray sound (ring handled in app)',
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

  static Future<bool> _isDriverOnlineFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('DRIVER_ONLINE_STATUS') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Called from Firebase background isolate (`main.dart` entrypoint).
  @pragma('vm:entry-point')
  static Future<void> handleBackgroundTray(RemoteMessage message) async {
    try {
      logRemoteMessage('BACKGROUND (handleBackgroundTray)', message);

      final isBooking = isNewBookingRequest(message);
      final isCancel = isBookingCancellation(message);

      if (!isBooking && !isCancel) {
        // iOS data-only pushes need a local tray. Notification-payload pushes are
        // already shown by APNs — do not post a second local banner.
        if (isIOS && message.notification == null) {
          final plugin = FlutterLocalNotificationsPlugin();
          const iosInit = DarwinInitializationSettings();
          await plugin.initialize(
            const InitializationSettings(iOS: iosInit),
            onDidReceiveBackgroundNotificationResponse:
                notificationTapBackground,
          );
          await _presentLocalNotification(
            plugin: plugin,
            message: message,
            allowHeavyAssets: false,
            suppressBookingTraySound: false,
          );
          debugPrint('🔔 iOS background data-only notification shown');
        } else {
          debugPrint(
            '🔔 BACKGROUND: non-booking message '
            '(system tray handles notification payload on iOS)',
          );
        }
        return;
      }

      if (isBooking) {
        final online = await _isDriverOnlineFromPrefs();
        if (!online) {
          log('Background booking FCM skipped — driver offline');
          return;
        }
      }

      final plugin = FlutterLocalNotificationsPlugin();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      await plugin.initialize(
        const InitializationSettings(
          android: androidInit,
          iOS: iosInit,
        ),
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
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
            description: 'User cancelled ride — custom sound',
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(
                _kBookingCancelAndroidRawSound),
          ),
        );
      }

      if (isBooking) {
        final bookingId = BookingCancellationDialog.extractBookingId(message);
        final title = message.notification?.title ?? 'New ride request';
        final body = message.notification?.body ??
            message.data['body']?.toString() ??
            'Tap Accept or Pass';
        await showIncomingBookingAlert(
          bookingId: bookingId.isNotEmpty ? bookingId : 'pending',
          userName: title,
          pickup: body,
          plugin: plugin,
        );
        log('Background incoming booking alert: $title');
        return;
      }

      await _presentLocalNotification(
        plugin: plugin,
        message: message,
        allowHeavyAssets: false,
        suppressBookingTraySound: false,
      );
      log('Background cancel notification: ${message.notification?.title}');
    } catch (e, st) {
      log('handleBackgroundTray failed', error: e, stackTrace: st);
    }
  }

  static Future<void> showNotificationForeground(RemoteMessage message) async {
    try {
      if (kIsWeb) {
        await _handleWebForegroundMessage(message);
        return;
      }

      final isBooking = isNewBookingRequest(message);
      final isCancel = isBookingCancellation(message);

      if (isBooking && !BookingRingManager.canRingFromControllers()) {
        debugPrint(
          '🔔 FOREGROUND: booking skipped — driver offline or on trip '
          'title=${message.notification?.title ?? message.data['title']}',
        );
        try {
          Get.find<BookingController>().rideNowBooking();
        } catch (_) {
          /* ignore */
        }
        return;
      }

      // Android booking: [BookingRingManager] posts the tray — skip duplicate local banner.
      final skipForegroundLocalTray = isAndroid && isBooking;

      if (!skipForegroundLocalTray) {
        await _presentLocalNotification(
          plugin: _flutterLocalNotificationsPlugin,
          message: message,
          allowHeavyAssets: true,
          suppressBookingTraySound: true,
        );
      }

      if (isBooking) {
        final bookingId = BookingCancellationDialog.extractBookingId(message);
        if (BookingIncomingService.instance.isAppInBackground) {
          await BookingIncomingService.instance.presentIncomingBooking(
            bookingId: bookingId,
          );
        } else {
          await BookingRingManager.onNewBookingDetected(bookingId: bookingId);
        }
      } else if (isCancel) {
        // Cancel sound handled in _handleBookingCancellationNotification.
      }

      log('Notification Shown: ${message.notification?.title}');
      debugPrint(
        '🔔 FOREGROUND handled title="${message.notification?.title ?? message.data['title']}"',
      );

      try {
        if (isCancel) {
          _handleBookingCancellationNotification(message);
          return;
        }

        Get.find<BookingController>().rideNowBooking();
      } catch (e, st) {
        log('post-notification GetX handlers failed', error: e, stackTrace: st);
      }
    } catch (e, st) {
      debugPrint('🔔 FOREGROUND handler error: $e');
      log('showNotificationForeground failed', error: e, stackTrace: st);
    }
  }

  /// Background / lock-screen Rapido-style alert with Accept & Pass actions.
  static Future<void> _handleWebForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'POP Driver';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';
    showWebBrowserNotification(title: title, body: body);

    if (isNewBookingRequest(message)) {
      if (!BookingRingManager.canRingFromControllers()) {
        try {
          Get.find<BookingController>().rideNowBooking();
        } catch (_) {
          /* ignore */
        }
        return;
      }
      final bookingId = BookingCancellationDialog.extractBookingId(message);
      await BookingRingManager.onNewBookingDetected(
        bookingId: bookingId.isNotEmpty ? bookingId : null,
      );
      try {
        await Get.find<BookingController>().rideNowBooking();
      } catch (_) {
        /* ignore */
      }
      return;
    }

    if (isBookingCancellation(message)) {
      _handleBookingCancellationNotification(message);
    }
  }

  static Future<void> showIncomingBookingAlert({
    required String bookingId,
    required String userName,
    required String pickup,
    String destination = '',
    String offer = '',
    String distance = '',
    FlutterLocalNotificationsPlugin? plugin,
  }) async {
    if (!isAndroid) return;

    final payload = BookingIncomingService.buildPayload(
      bookingId: bookingId,
      userName: userName,
      pickup: pickup,
      destination: destination,
      offer: offer,
      distance: distance,
    );

    final bodyLines = <String>[];
    if (offer.isNotEmpty) bodyLines.add('Offer \$$offer');
    if (distance.isNotEmpty) bodyLines.add('$distance km');
    if (pickup.isNotEmpty) bodyLines.add(pickup);
    final body =
        bodyLines.isEmpty ? 'Tap Accept or Pass' : bodyLines.join(' • ');

    final androidDetails = AndroidNotificationDetails(
      _kBookingChannelId,
      'Booking alerts',
      channelDescription: 'New ride requests — full screen + Accept/Pass',
      enableLights: true,
      priority: Priority.max,
      importance: Importance.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      sound:
          const RawResourceAndroidNotificationSound(_kBookingAndroidRawSound),
      ongoing: true,
      autoCancel: false,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(
        destination.isNotEmpty ? '$body\nDrop: $destination' : body,
        contentTitle: 'New ride request',
        summaryText: offer.isNotEmpty ? 'Offer \$$offer' : null,
      ),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          BookingIncomingService.actionAccept,
          'Accept',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          BookingIncomingService.actionPass,
          'Pass',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    final notifyPlugin = plugin ?? _flutterLocalNotificationsPlugin;
    await notifyPlugin.show(
      _kBookingAlertNotificationId,
      'New ride — $userName',
      body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
    await BookingIncomingService.rememberIncomingBookingId(bookingId);
    BookingRingManager.markBookingAnnounced(bookingId);
  }

  static void _handleBookingCancellationNotification(RemoteMessage message) {
    BookingRingManager.stopImmediate();
    // Cancel sound + UI reset happen in handleUserSideCancellationShowDialog
    // (also used by API poll fallback when web FCM misses).

    final bookingId = BookingCancellationDialog.extractBookingId(message);
    try {
      final homeController = Get.find<HomeController>();
      homeController.clearMarkersExceptDriver();
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
      unawaited(BookingCancelPlayer.playFiveSeconds());
      if (bookingId.isNotEmpty) {
        BookingCancellationDialog.show(bookingId);
      }
    }
  }

  /// pop_user-style iOS details — no custom sound file (booking_ring.mp3 is Android-only).
  static DarwinNotificationDetails _iosDarwinDetails({
    required bool muteFgTray,
  }) {
    return DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: !muteFgTray,
      interruptionLevel: InterruptionLevel.active,
    );
  }

  /// When true and notifications that use in-app playback (new booking /
  /// cancellation) post to the silent Android channel instead of ringing twice.
  static Future<void> _presentLocalNotification({
    required FlutterLocalNotificationsPlugin plugin,
    required RemoteMessage message,
    required bool allowHeavyAssets,
    required bool suppressBookingTraySound,
  }) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'POP Driver';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        message.data.toString();

    if (title.trim().isEmpty && body.trim().isEmpty) {
      debugPrint('🔔 LOCAL BANNER skip — empty title and body');
      return;
    }

    FilePathAndroidBitmap? largeIcon;
    if (allowHeavyAssets) {
      try {
        final path = await _getImageFilePathFromAssets(
            'assets/images/backgoundLogo.png');
        largeIcon = FilePathAndroidBitmap(path);
      } catch (e, st) {
        log('large icon skip', error: e, stackTrace: st);
      }
    }

    final isBookingReq = isNewBookingRequest(message);
    final isBookingCancelled = isBookingCancellation(message);
    final muteFgTray =
        suppressBookingTraySound && (isBookingReq || isBookingCancelled);

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
        channelDescription: 'Heads-up while app open — sound plays inside app',
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
            'New ride requests — custom ringtone ($_kBookingAndroidRawSound.mp3)',
        enableLights: true,
        priority: Priority.high,
        importance: Importance.max,
        largeIcon: largeIcon,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        sound:
            const RawResourceAndroidNotificationSound(_kBookingAndroidRawSound),
        color: Colors.transparent,
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        _kBookingCancelChannelId,
        'Booking cancelled',
        channelDescription:
            'User cancelled — tray sound ($_kBookingCancelAndroidRawSound.mp3)',
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

    final darwinDetails = _iosDarwinDetails(muteFgTray: muteFgTray);

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final int notificationId =
        (message.hashCode ^ DateTime.now().millisecondsSinceEpoch) & 0x7fffffff;

    debugPrint(
      '🔔 LOCAL BANNER show id=$notificationId title="$title" body="$body"',
    );

    try {
      await plugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: message.data.toString(),
      );
      debugPrint('🔔 LOCAL BANNER shown OK id=$notificationId');
    } catch (e, st) {
      debugPrint('🔔 LOCAL BANNER failed: $e');
      log('local notification show failed', error: e, stackTrace: st);
    }
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
Future<void> notificationTapBackground(
    NotificationResponse notificationResponse) async {
  debugPrint(
    '👆 NOTIFICATION TAP [BACKGROUND] id=${notificationResponse.id} '
    'action=${notificationResponse.actionId} payload=${notificationResponse.payload}',
  );
  await BookingIncomingService.persistNotificationResponse(
    actionId: notificationResponse.actionId,
    payload: notificationResponse.payload,
  );
}

Future<String> _getImageFilePathFromAssets(String asset) async {
  final byteData = await rootBundle.load(asset);
  final file =
      File('${(await getTemporaryDirectory()).path}/backgoundLogo.png');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  return file.path;
}
