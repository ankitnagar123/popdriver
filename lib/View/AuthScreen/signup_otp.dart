import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/text_field.dart';
import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
import '../../utils/snackBar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';


import '../../utils/colors.dart';
import '../../utils/snackBar.dart';

class SignupOTP extends StatefulWidget {
  const SignupOTP({Key? key}) : super(key: key);

  @override
  State<SignupOTP> createState() => _SignupOTPState();
}

class _SignupOTPState extends State<SignupOTP> {

  AuthController controller = Get.find<AuthController>();

  String otp = "";
  String id = "";

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(Icons.arrow_back, color: MyColors.black,)),
        backgroundColor: MyColors.white,
        title: Image.asset("assets/images/logo.png", height: 50,),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 120,),
            Text(
              "Enter the 6-digit code send to you at\n ${controller.countryCode
                  .value + " " + controller.contacts.value}".tr,
              style: TextStyle(fontSize: 15),),
            SizedBox(height: 15,),
            Text("Enter OTP".tr),
            SizedBox(height: 20,),
            OtpTextField(
              keyboardType: TextInputType.number,
              obscureText: true,
              numberOfFields: 6,
              borderColor: Color(0xFF512DA8),
              showFieldAsBox: false,
              onCodeChanged: (String code) {

              },
              onSubmit: (String verificationCode) {
                otp = verificationCode;
                print("otp---------$otp");
              },
            ),
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    return controller.remainingTime.value == 0 ?
                    InkWell(
                        onTap: () {
                          controller.signupOtp("resend", () {});
                        },
                        child: controller.otpLoader.value ?
                        myIndicator() :
                        Text("I didn't receive code".tr, style: TextStyle(
                            color: MyColors.buttonColor),)) :
                    Text("${controller.remainingTime.value} remaining time");
                  }),
                  Obx(() {
                    if(controller.otpVerify.value){
                      return Center(child: myIndicator(),);
                    }else {
                      return InkWell(
                      onTap: () {
                        print("otp =====" + otp);
                        if (otp.length != 6) {
                          customSnackBar("Enter OTP".tr);
                        } else {
                          controller.verifyOtp(controller.contacts.value,controller.countryCode.value,otp,(){
                            Get.back(result: "back");
                          });
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: MyColors.orange
                        ),
                        child: Icon(Icons.arrow_forward,
                          color: MyColors.white,),
                      ),
                    );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
