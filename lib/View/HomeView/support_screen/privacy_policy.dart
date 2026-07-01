import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Network/urls.dart';
import '../../../utils/colors.dart';
import '../../../widgets/app_web_view.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: MyColors.white),
        backgroundColor: MyColors.primary,
        title: Text(
          'Privacy Policy'.tr,
          style: const TextStyle(fontSize: 20, color: MyColors.white),
        ),
        centerTitle: true,
      ),
      body: AppWebView(url: URLS.api(URLS.DRIVER_PRIVACY_POLICY)),
    );
  }
}
