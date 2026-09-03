typedef WebNotificationClickCallback = void Function(
  String title,
  String body,
  Map<String, String> data,
);

void setupWebFcmNotificationClickHandler(
  WebNotificationClickCallback onClick,
) {}
