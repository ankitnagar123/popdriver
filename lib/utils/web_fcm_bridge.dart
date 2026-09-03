import 'web_fcm_bridge_stub.dart'
    if (dart.library.html) 'web_fcm_bridge_web.dart' as impl;

typedef WebNotificationClickCallback = void Function(
  String title,
  String body,
  Map<String, String> data,
);

void setupWebFcmNotificationClickHandler(
  WebNotificationClickCallback onClick,
) =>
    impl.setupWebFcmNotificationClickHandler(onClick);
