import 'dart:html' as html;

Future<void> registerFcmServiceWorkerImpl() async {
  try {
    final sw = html.window.navigator.serviceWorker;
    if (sw == null) return;
    await sw.register(
      'firebase-messaging-sw.js',
      {'scope': '/firebase-cloud-messaging-push-scope'},
    );
  } catch (_) {
    /* FlutterFire also auto-registers this file */
  }
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
      icon: 'icons/Icon-192.png',
    );
  } catch (_) {
    /* ignore */
  }
}
