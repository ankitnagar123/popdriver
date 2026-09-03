import 'dart:async';
import 'dart:html' as html;

typedef WebNotificationClickCallback = void Function(
  String title,
  String body,
  Map<String, String> data,
);

void setupWebFcmNotificationClickHandler(
  WebNotificationClickCallback onClick,
) {
  void handleRaw(Map raw) {
    if (raw['type']?.toString() != 'FIREBASE_NOTIFICATION_CLICK') return;

    final title = raw['title']?.toString() ?? '';
    final body = raw['body']?.toString() ?? '';
    final dataRaw = raw['data'];
    final data = <String, String>{};

    if (dataRaw is Map) {
      dataRaw.forEach((key, value) {
        data[key.toString()] = value?.toString() ?? '';
      });
    }

    if (title.isNotEmpty && !data.containsKey('title')) {
      data['title'] = title;
    }
    if (body.isNotEmpty && !data.containsKey('body')) {
      data['body'] = body;
    }

    onClick(title, body, data);
  }

  html.window.onMessage.listen((event) {
    final raw = event.data;
    if (raw is! Map) return;
    handleRaw(Map<dynamic, dynamic>.from(raw));
  });

  html.window.navigator.serviceWorker?.addEventListener('message', (event) {
    final messageEvent = event as html.MessageEvent;
    final raw = messageEvent.data;
    if (raw is! Map) return;
    handleRaw(Map<dynamic, dynamic>.from(raw));
  });

  _checkWebFcmLaunchParams(onClick);
}

void _checkWebFcmLaunchParams(WebNotificationClickCallback onClick) {
  final uri = Uri.parse(html.window.location.href);
  if (uri.queryParameters['fcm_click'] != '1') return;

  final data = Map<String, String>.from(uri.queryParameters);
  data.remove('fcm_click');
  final title = data['title'] ?? '';
  final body = data['body'] ?? '';

  Future<void>.delayed(const Duration(milliseconds: 800), () {
    onClick(title, body, data);
  });

  html.window.history.replaceState(null, '', uri.path);
}
