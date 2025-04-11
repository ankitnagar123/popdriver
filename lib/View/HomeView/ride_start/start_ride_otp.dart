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

  FocusNode? pin1FocusNode = FocusNode();
  FocusNode? pin2FocusNode = FocusNode();
  FocusNode? pin3FocusNode = FocusNode();
  FocusNode? pin4FocusNode = FocusNode();
  FocusNode? pin5FocusNode = FocusNode();
  FocusNode? pin6FocusNode = FocusNode();


  TextEditingController _pin1Controller=TextEditingController();
  TextEditingController _pin2Controller=TextEditingController();
  TextEditingController _pin3Controller=TextEditingController();
  TextEditingController _pin4Controller=TextEditingController();
  TextEditingController _pin5Controller=TextEditingController();
  TextEditingController _pin6Controller=TextEditingController();


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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.white,
        title: Image.asset("assets/images/logo.png", height: 50,),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter The OTP To Start Ride".tr,
              style: TextStyle(color: MyColors.primary),),
            SizedBox(height: 20,),
           /* OtpTextField(
              numberOfFields: 6,
              borderColor: Color(0xFF512DA8),
              showFieldAsBox: false,
              onCodeChanged: (String code) {
              },
              onSubmit: (String verificationCode) {
                otp = verificationCode;
              }, // end onSubmit
            ),*/
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: TextFormField(
                    obscureText: true,
                    controller:_pin1Controller ,
                    autofocus: true,
                    focusNode: pin1FocusNode,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(fontSize: 24,color: Colors.black),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF512DA8),),
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1)
                    ],
                    onChanged: (value) {
                      nextField(value, pin2FocusNode);
                    },
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: TextFormField(
                    obscureText: true,
                    controller:_pin2Controller ,
                    autofocus: true,
                    focusNode: pin2FocusNode,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(fontSize: 24,color: Colors.black),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF512DA8),),
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1)
                    ],
                    onChanged: (value) {
                      if(value.isEmpty)
                      {
                        previewField(value,pin1FocusNode);
                      }else {
                        nextField(value, pin3FocusNode);
                      }
                    },
                  ),
                ), SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: TextFormField(
                    obscureText: true,
                    controller:_pin3Controller ,
                    autofocus: true,
                    focusNode: pin3FocusNode,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(fontSize: 24,color: Colors.black),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF512DA8),),
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1)
                    ],
                    onChanged: (value) {
                      if(value.isEmpty)
                      {
                        previewField(value,pin2FocusNode);
                      }else {
                        nextField(value, pin4FocusNode);
                      }
                    },
                  ),
                ), SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: TextFormField(
                    obscureText: true,
                    controller:_pin4Controller ,
                    autofocus: true,
                    focusNode: pin4FocusNode,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(fontSize: 24,color: Colors.black),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF512DA8),),
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1)
                    ],
                    onChanged: (value) {
                      if(value.isEmpty)
                      {
                        previewField(value,pin3FocusNode);
                      }else
                      {
                        nextField(value, pin5FocusNode);
                      }

                    },
                  ),
                ), SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: TextFormField(
                    obscureText: true,
                    controller:_pin5Controller ,
                    autofocus: true,
                    focusNode: pin5FocusNode,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(fontSize: 24,color: Colors.black),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF512DA8),),
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1)
                    ],
                    onChanged: (value) {
                      if(value.isEmpty)
                      {
                        previewField(value,pin4FocusNode);
                      }else
                      {
                        nextField(value, pin6FocusNode);
                      }

                    },
                  ),
                ), SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: TextFormField(
                    obscureText: true,
                    controller:_pin6Controller ,
                    autofocus: true,
                    focusNode: pin6FocusNode,
                    style: TextStyle(fontSize: 24,color: Colors.black),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF512DA8),),
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1)
                    ],
                    onChanged: (value) {
                      if(value.isEmpty)
                      {
                        previewField(value,pin5FocusNode);
                      }
                      // nextField(value, pin2FocusNode);
                    },
                  ),
                )
              ],
            ),
            SizedBox(height: 50,),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(() {
                  return Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        String pin1=_pin1Controller.text.toString();
                        String pin2=_pin2Controller.text.toString();
                        String pin3=_pin3Controller.text.toString();
                        String pin4=_pin4Controller.text.toString();
                        String pin5=_pin5Controller.text.toString();
                        String pin6=_pin6Controller.text.toString();

                        otp=pin1+pin2+pin3+pin4+pin5+pin6;

                        print("=============${otp}");
                        if (otp.isEmpty||otp.length !=6) {
                          customSnackBar("Enter OTP".tr);
                        }else
                        {
                          Get.find<AuthController>().verifyOtp2(otp, id,(){
                            controller.statusChange("start_ride",
                                controller.useracceptmodel.bookingId, "", "", () {
                                  Get.back();
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
    );
  }
}

