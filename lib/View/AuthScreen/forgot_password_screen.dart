
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_number/phone_number.dart';

import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
import '../../utils/snackBar.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  TextEditingController phoneCtr = TextEditingController();
  AuthController controller = Get.find<AuthController>();

  String countryFlag = "KE";
  String countryCode = "+254";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
          onTap: (){
            Get.back();
          },
            child: Icon(Icons.arrow_back,color: MyColors.black,)),
        backgroundColor: MyColors.white,
        title:  Image.asset("assets/images/logo.png",height: 50,),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 40,horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 100,),
            Text("Forgot Password".tr,style: TextStyle(fontSize: 20),),
            SizedBox(height: 20,),
            Text("To recover your password, you need to enter your registered mobile number".tr),
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text('Enter Mobile No.'.tr)),
                  Container(
                    height: 50,
                    width: context.width,
                    margin: EdgeInsets.only(top: 5),
                    padding: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: MyColors.TextField
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: IntlPhoneField(
                        controller: phoneCtr,
                        textInputAction: TextInputAction.next,
                        showDropdownIcon: false,
                        autovalidateMode: AutovalidateMode.disabled,
                        /*disableLengthCheck: true,*/
                        initialCountryCode: countryFlag,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration:  InputDecoration(
                          counterText: "",
                            hintStyle: TextStyle(color: MyColors.DarkBlue,fontSize: 12),
                            hintText: 'Enter Mobile No.'.tr,
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none),
                        onChanged: (phone) {
                          setState(
                                () {
                              countryCode = phone.countryCode;
                              print(countryCode);
                            },
                          );
                        },
                        onCountryChanged: (country) {
                          setState(
                                () {
                              countryCode = '${country.dialCode}';
                              print(countryCode);
                            },
                          );

                          //print('Country changed to: ' + country.name);
                        },
                      ),
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap:(){
                      Get.back();
                    },
                      child: Text("Back to Login".tr,style: TextStyle(color: MyColors.buttonColor),)),
                  Obx(() => InkWell(
                    onTap: () async {
                      if(await valid()){
                        controller.forgetPassword(countryCode, phoneCtr.text);
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: MyColors.orange
                      ),
                      child: controller.forgetPasswordLoader.value?
                          Center(
                            child: SizedBox(
                              height: 20,
                                width: 20,
                                child: myIndicator()),
                          ):
                      Icon(Icons.arrow_forward,color: MyColors.white,),
                    ),
                  ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> valid() async {
    String _numberWithCountryCode = countryCode+phoneCtr.text;
    bool _isValid = GetPlatform.isWeb ? true : false;
    if(!GetPlatform.isWeb) {
      try {
        var phoneNumber = await PhoneNumberUtil().parse(_numberWithCountryCode);
        _numberWithCountryCode = '+${phoneNumber.countryCode}${phoneNumber.nationalNumber}';
        _isValid = true;
      } catch (e) {}
    }
    try{
      String springFieldUSA = countryCode+phoneCtr.text;
      // Validate
      bool isValid = await PhoneNumberUtil().validate(springFieldUSA);
      print("phone validation==>");
      print(isValid);
    }catch(e){
      print(e);
    }
    if(phoneCtr.text.isEmpty){
      customSnackBar("Please Enter Mobile Number".tr);
    }/*else if (!_isValid) {
      customSnackBar("Please Enter Valid Mobile Number".tr);
    }*/else{
      print("vishnu");
      return true;
    }
    return false;
  }
}
