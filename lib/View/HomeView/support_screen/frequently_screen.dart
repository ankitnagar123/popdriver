import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';

class FrequentlyScreen extends StatefulWidget {
  const FrequentlyScreen({Key? key}) : super(key: key);

  @override
  State<FrequentlyScreen> createState() => _FrequentlyScreenState();
}

class _FrequentlyScreenState extends State<FrequentlyScreen> {

  bool isLoading=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: MyColors.white
        ),
        backgroundColor: MyColors.primary,
        title: Text("FAQ".tr,
          style: TextStyle(fontSize: 25, color: MyColors.white),),
        centerTitle: true,

      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 20,),
              Text("Frequently Asked Questions".tr,style: TextStyle(fontSize: 20),),
              SizedBox(height: 20,),
              Expanded(
                child: WebView(
                  initialUrl: "https://ride.mtaani.com/API/driver_faq.php",
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageFinished: (finish) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
              )
            ],
          ),
          isLoading ? Center( child: myIndicator(),)
              : Stack(),
        ],
      )
    );
  }
}
