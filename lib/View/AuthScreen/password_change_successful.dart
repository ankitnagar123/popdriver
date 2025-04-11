import '../../route_helper/route_helper.dart';
import '../../utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordChangeSuccess extends StatefulWidget {
  const PasswordChangeSuccess({Key? key}) : super(key: key);

  @override
  State<PasswordChangeSuccess> createState() => _PasswordChangeSuccessState();
}

class _PasswordChangeSuccessState extends State<PasswordChangeSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset("assets/images/changePass.png",
      height: Get.height,
        width: Get.width,
        fit: BoxFit.fill,
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
      child: custom_buttons(voidCallback: (){
        Get.offNamed(RouteHelper.getLoginScreenRoute());
      }, text: 'Go to Login',  ),
      ),
    );
  }
}
