
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermConditionScreen extends StatefulWidget {
  const TermConditionScreen({Key? key}) : super(key: key);

  @override
  State<TermConditionScreen> createState() => _TermConditionScreenState();
}

class _TermConditionScreenState extends State<TermConditionScreen> {
  ExpansionTileController controller1 = ExpansionTileController();
  late final WebViewController webViewController;
  late final PlatformWebViewControllerCreationParams params;
  bool isLoading = true;
  bool _reloadCalled = false; // Flag to track if reload was called

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeWebViewController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: MyColors.white
        ),
        backgroundColor: MyColors.primary,
        title: Text("Term Condition".tr,
          style: TextStyle(fontSize: 20, color: MyColors.white),),
        centerTitle: true,

      ),
      body: Stack(
        children: [
          WebViewWidget(controller: webViewController),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: MyColors.primary),
            ),
        ],
      ),
    );
  }

  void _initializeWebViewController() {
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            setState(() {
              isLoading = true; // Show loader when page starts loading
            });
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() {
              isLoading = false; // Hide loader when page finishes loading
            });

            // Reload the page only once
            if (!_reloadCalled) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                debugPrint('Reloading WebView for the first time...');
                webViewController.reload();
              });
              _reloadCalled = true; // Set flag to true
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error: ${error.description}');
            setState(() {
              isLoading = false; // Hide loader even if there's an error
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          "https://cisswork.com/Android/PopRide/API/driver_term_condition.php",
        ),

      );

    webViewController = controller;
  }
}
