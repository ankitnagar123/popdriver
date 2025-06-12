// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// import '../../../utils/colors.dart';
// import '../../../utils/custom_button.dart';
//
// class FrequentlyScreen extends StatefulWidget {
//   const FrequentlyScreen({Key? key}) : super(key: key);
//
//   @override
//   State<FrequentlyScreen> createState() => _FrequentlyScreenState();
// }
//
// class _FrequentlyScreenState extends State<FrequentlyScreen> {
//
//   bool isLoading=true;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.white,
//
//         appBar: AppBar(
//         iconTheme: IconThemeData(
//             color: MyColors.white
//         ),
//         backgroundColor: MyColors.primary,
//         title: Row(
//           children: [
//             Image.asset(
//               'assets/images/headLogo.png',
//               height: 28,
//             ),  Image.asset(
//               color: Colors.white,
//               'assets/images/stearing.png',
//               height: 35,
//             ),
//
//           ],
//         ),
//         centerTitle: true,
//
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//
//               SizedBox(height: 20,),
//               Text("Frequently Asked Questions".tr,style: TextStyle(fontSize: 18),),
//               SizedBox(height: 20,),
//               Expanded(
//                 child: WebView(
//                   initialUrl: "https://cisswork.com/Android/PopRide/API/driver_faq.php",
//                   javascriptMode: JavascriptMode.unrestricted,
//                   onPageFinished: (finish) {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   },
//                 ),
//               )
//             ],
//           ),
//           isLoading ? Center( child: myIndicator(),)
//               : Stack(),
//         ],
//       )
//     );
//   }
// }

import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FrequentlyScreen extends StatefulWidget {
  const FrequentlyScreen({Key? key}) : super(key: key);

  @override
  State<FrequentlyScreen> createState() => _FrequentlyScreenState();
}

class _FrequentlyScreenState extends State<FrequentlyScreen> {
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
            "https://cisswork.com/Android/PopRide/API/driver_faq.php"
        ),

      );

    webViewController = controller;
  }
}
