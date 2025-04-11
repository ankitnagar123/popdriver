import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermCondition extends StatefulWidget {
  const TermCondition({Key? key}) : super(key: key);

  @override
  State<TermCondition> createState() => _TermConditionState();
}

class _TermConditionState extends State<TermCondition> {

  bool isLoading=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: MyColors.white
        ),
        backgroundColor: MyColors.primary,
        title: Text("Terms & Condition".tr,
          style: TextStyle(fontSize: 25, color: MyColors.white),),
        centerTitle: true,

      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: WebView(
              initialUrl: "https://ride.mtaani.com/API/driver_term_condition.php",
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
