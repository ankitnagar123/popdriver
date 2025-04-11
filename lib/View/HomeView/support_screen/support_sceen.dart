
import '../../../controller/auth_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/colors.dart';

class Support extends StatefulWidget {
  const Support({Key? key}) : super(key: key);

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: MyColors.white
        ),
        backgroundColor: MyColors.primary,
        title: Text("Support".tr,
          style: TextStyle(fontSize: 25, color: MyColors.white),),
        centerTitle: true,

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                Get.toNamed(RouteHelper.getWriteSupportScreenRoute());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Write Support".tr,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                  Icon(Icons.arrow_forward_ios_outlined,size: 20,)
                ],
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: (){
                Get.toNamed(RouteHelper.getFrequentlyScreenScreenRoute());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Frequently Asked Questions".tr,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                  Icon(Icons.arrow_forward_ios_outlined,size: 20,)
                ],
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: (){
                Get.toNamed(RouteHelper.getPrivacyPolicyScreenRoute());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Privacy Policy".tr,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                  Icon(Icons.arrow_forward_ios_outlined,size: 20,)
                ],
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: (){
                Get.toNamed(RouteHelper.getTermConditionScreenRoute());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Terms & Condition".tr,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                  Icon(Icons.arrow_forward_ios_outlined,size: 20,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
