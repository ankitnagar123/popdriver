import 'dart:async';
import 'dart:html' as html;

Future<void> registerFcmServiceWorkerImpl() async {
  try {
    final sw = html.window.navigator.serviceWorker;
    if (sw == null) return;
    await sw.register(
      '/firebase-messaging-sw.js',
      {'scope': '/firebase-cloud-messaging-push-scope'},
    ).timeout(const Duration(seconds: 4));
  } catch (_) {
    /* FlutterFire also auto-registers this file */
  }
}

Future<bool> ensureBrowserNotificationPermissionImpl() async {
  if (!html.Notification.supported) return false;
  final current = html.Notification.permission;
  if (current == 'granted') return true;
  if (current == 'denied') return false;
  final result = await html.Notification.requestPermission();
  return result == 'granted';
}

bool isBrowserNotificationPermissionGrantedImpl() {
  if (!html.Notification.supported) return false;
  return html.Notification.permission == 'granted';
}

void showWebBrowserNotificationImpl({
  required String title,
  String body = '',
}) {
  try {
    if (html.Notification.permission != 'granted') return;
    html.Notification(
      title,
      body: body,
      icon: '/icons/Icon-192.png',
    );
  } catch (_) {
    /* ignore */
  }
}
