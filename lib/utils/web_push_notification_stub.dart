Future<void> registerFcmServiceWorkerImpl() async {}

Future<bool> ensureBrowserNotificationPermissionImpl() async => false;

bool isBrowserNotificationPermissionGrantedImpl() => false;

void showWebBrowserNotificationImpl({
  required String title,
  String body = '',
}) {}
