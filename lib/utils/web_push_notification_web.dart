import 'dart:html' as html;

/// FlutterFire registers `/firebase-messaging-sw.js` on the default scope.
/// Do not register the custom FCM push scope — that breaks `getToken`.
Future<void> registerFcmServiceWorkerImpl() async {}

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
