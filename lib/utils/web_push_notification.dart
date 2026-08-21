import 'web_push_notification_stub.dart'
    if (dart.library.html) 'web_push_notification_web.dart';

Future<void> registerFcmServiceWorker() => registerFcmServiceWorkerImpl();

Future<bool> ensureBrowserNotificationPermission() =>
    ensureBrowserNotificationPermissionImpl();

bool isBrowserNotificationPermissionGranted() =>
    isBrowserNotificationPermissionGrantedImpl();

void showWebBrowserNotification({
  required String title,
  String body = '',
}) =>
    showWebBrowserNotificationImpl(title: title, body: body);
