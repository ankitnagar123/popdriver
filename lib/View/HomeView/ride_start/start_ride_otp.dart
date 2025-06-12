import 'dart:developer';

import '../../../controller/auth_controller.dart';
import '../../../controller/booking_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/shared_preferences.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../../utils/snackBar.dart';

class StartRideOtp extends StatefulWidget {
  const StartRideOtp({Key? key}) : super(key: key);

  @override
  State<StartRideOtp> createState() => _StartRideOtpState();
}

class _StartRideOtpState extends State<StartRideOtp> {


  BookingController controller = Get.find<BookingController>();
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();


  void previewField(String value, FocusNode? focusNode) {
    if (value.length == 0) {
      print("previews");
      focusNode!.requestFocus();
    }}

  void nextField(String value, FocusNode? focusNode) {
    if (value.length == 1) {
      focusNode!.requestFocus();
    }}

  String otp = "";
  String id = "";

  @override
  void initState() {
    super.initState();
   id = Get.arguments['id'];
   setState(() {

   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.white,
        title: Image.asset("assets/images/logo.png", height: 50,),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", height: 250,),
              Text("Enter The OTP To Start Ride".tr,
                style: TextStyle(color: MyColors.primary,fontWeight: FontWeight.w600),),
              SizedBox(height: 20,),
              OtpTextField(
                cursorColor: MyColors.primary,
                numberOfFields: 6,
                borderColor: Color(0xFF512DA8),
                showFieldAsBox: false,
                onCodeChanged: (String code) {
                },
                onSubmit: (String verificationCode) {
                  otp = verificationCode;
                }, // end onSubmit
              ),
          
              SizedBox(height: 50,),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Obx(() {
                    return Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          print("=============${otp}");
                          if (otp.isEmpty||otp.length !=6) {
                            customSnackBar("Enter OTP".tr);
                          }else
                          {
                            Get.find<AuthController>().verifyOtp2(otp, id,(){
                              controller.statusChange("start_ride",
                                  controller.useracceptmodel.bookingId, "", "", () {
                                  Navigator.pop(context);
                                  });
                            });
                          }
                        },
                        child: controller. statusChangeLoader.value || Get.find<AuthController>().otpVerify2.value?
                            Center(child: myIndicator(),):
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: MyColors.orange
                          ),
                          child: Icon(Icons.arrow_forward, color: MyColors
                              .white,),
                        ),
                      ),
                    );
                  })
              ),
            ],
          ),
        ),
      ),
    );
  }
}

