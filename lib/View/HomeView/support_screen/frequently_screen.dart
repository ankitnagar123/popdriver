import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Network/urls.dart';
import '../../../utils/colors.dart';
import '../../../widgets/app_web_view.dart';

class FrequentlyScreen extends StatelessWidget {
  const FrequentlyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: MyColors.white),
        backgroundColor: MyColors.primary,
        title: Text(
          'Frequently Asked Questions'.tr,
          style: const TextStyle(fontSize: 20, color: MyColors.white),
        ),
        centerTitle: true,
      ),
      body: AppWebView(url: URLS.api(URLS.DRIVER_FAQ)),
    );
  }
}
