import 'webview_platform_init_stub.dart'
    if (dart.library.html) 'webview_platform_init_web.dart';

void ensureWebViewPlatform() => initWebViewPlatform();
