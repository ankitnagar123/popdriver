import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/colors.dart';

/// Embedded web content — mobile uses full WebView; web uses iframe (limited API).
class AppWebView extends StatefulWidget {
  const AppWebView({super.key, required this.url});

  final String url;

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initWeb();
    } else {
      _initMobile();
    }
  }

  void _initWeb() {
    final controller = WebViewController()
      ..loadRequest(Uri.parse(widget.url));
    _controller = controller;
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _initMobile() {
    bool reloadCalled = false;
    final controller = WebViewController();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            if (!mounted) return;
            setState(() => _isLoading = false);
            if (!reloadCalled) {
              reloadCalled = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.reload();
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error: ${error.description}');
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: MyColors.primary),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: MyColors.primary),
          ),
      ],
    );
  }
}
