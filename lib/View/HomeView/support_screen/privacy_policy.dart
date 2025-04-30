import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {

  bool isLoading=true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
        iconTheme: IconThemeData(
            color: MyColors.white
        ),
        backgroundColor: MyColors.primary,
        title: Row(
          children: [
            Image.asset(
              'assets/images/headLogo.png',
              height: 28,
            ),  Image.asset(
              color: Colors.white,
              'assets/images/stearing.png',
              height: 35,
            ),

          ],
        ),
        centerTitle: true,

      ),
      body: Stack(
        children: [

          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: WebView(
              initialUrl: "https://ride.mtaani.com/API/driver_privacy_policy.php",
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (finish) {
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ),
          isLoading ? Center( child: myIndicator(),)
              : Stack(),
        ],
      )
    );
  }
}
