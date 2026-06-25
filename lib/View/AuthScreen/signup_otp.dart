import 'package:pin_code_fields/pin_code_fields.dart';

import '../../utils/colors.dart';
import '../../controller/auth_controller.dart';
import '../../utils/custom_button.dart';
import '../../utils/snackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

class SignupOTP extends StatefulWidget {
  const SignupOTP({Key? key}) : super(key: key);

  @override
  State<SignupOTP> createState() => _SignupOTPState();
}

class _SignupOTPState extends State<SignupOTP> {
  AuthController controller = Get.find<AuthController>();
  TextEditingController otpCtr = TextEditingController();

  String id = "";

  @override
  void initState() {
    super.initState();
  }


  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s remaining';
  }

  @override
  void dispose() {
    otpCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back,
              color: MyColors.black,
            )),
        backgroundColor: MyColors.white,
        title: Image.asset(
          "assets/images/logo.png",
          height: 100,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 110,),

            Center(
              child: Text(
                "Enter verification code\n ".tr,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("A code has been sent to ".tr,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),

              ],
            ),
            Obx(() => Text(
              controller.emailID.value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            )),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 22, right: 22.0),
              child: PinCodeTextField(
                  enablePinAutofill: false,
                  controller: otpCtr,
                  enableActiveFill: true,
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.number,
                  textStyle: TextStyle(
                    color: MyColors.black,
                    fontSize: 18,
                  ),
                  cursorColor: MyColors.primary,
                  pinTheme: PinTheme(
                    inactiveColor: Colors.grey,
                    // Set border color for inactive state
                    inactiveFillColor: Colors.white,
                    // Ensure background color is white
                    selectedColor: MyColors.primary,

                    activeFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    fieldHeight: 45,
                    fieldWidth: 45,
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      otpCtr.text = value;
                    });

                  },
                  onCompleted: (value) {
                    otpCtr.text = value;
                    controller.verifyOtp( otpCtr.text, () {
                          Navigator.of(context).pop("back");
                        });
                  }),
            ),
            Obx(() {
              return controller.remainingTime.value == 0
                  ? InkWell(
                  onTap: () {
                    controller.signupOtp("resend", () {});
                  },
                  child: controller.otpLoader.value
                      ? myIndicator()
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "I didn't receive code? ".tr,
                        style:
                        TextStyle(color: MyColors.black,fontSize: 12),
                      ),   Text(
                        "Resend".tr,
                        style:
                        TextStyle(color: MyColors.buttonColor,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ))
                  : Text(_formatTimer(controller.remainingTime.value));
            }),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  Obx(() {
                    if (controller.otpVerify.value) {
                      return Center(
                        child: myIndicator(),
                      );
                    } else {
                      return InkWell(
                        onTap: () {
                          print("otp =====" + otpCtr.text);
                          if (otpCtr.text.length != 6) {
                            customSnackBar("Enter OTP".tr);
                          } else {
                            controller.verifyOtp(otpCtr.text, () {
                              Navigator.of(context).pop("back");
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: MyColors.black),
                          child: Icon(
                            Icons.arrow_forward,
                            color: MyColors.white,
                          ),
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
