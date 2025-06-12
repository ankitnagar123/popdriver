//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:phone_number/phone_number.dart';
//
// import '../../controller/auth_controller.dart';
// import '../../utils/colors.dart';
// import '../../utils/custom_button.dart';
// import '../../utils/snackBar.dart';
//
// class ForgotPassword extends StatefulWidget {
//   const ForgotPassword({Key? key}) : super(key: key);
//
//   @override
//   State<ForgotPassword> createState() => _ForgotPasswordState();
// }
//
// class _ForgotPasswordState extends State<ForgotPassword> {
//
//   TextEditingController phoneCtr = TextEditingController();
//   AuthController controller = Get.find<AuthController>();
//
//   String countryFlag = "AU";
//   String countryCode = "+61";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         leading: InkWell(
//           onTap: (){
//             Get.back();
//           },
//             child: Icon(Icons.arrow_back,color: MyColors.black,)),
//         backgroundColor: MyColors.white,
//         title:  Image.asset("assets/images/logo.png",height: 50,),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(vertical: 40,horizontal: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(height: 100,),
//             Text("Forgot Password".tr,style: TextStyle(fontSize: 20),),
//             SizedBox(height: 20,),
//             Text("To recover your password, you need to enter your registered mobile number".tr),
//             SizedBox(height: 10,),
//             Padding(
//               padding: EdgeInsets.only(top: 10),
//               child: Column(
//                 children: [
//                   Align(
//                       alignment: AlignmentDirectional.centerStart,
//                       child: Text('Enter Mobile No.'.tr)),
//                   Container(
//                     height: 50,
//                     width: context.width,
//                     margin: EdgeInsets.only(top: 5),
//                     padding: EdgeInsets.only(left: 10),
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: MyColors.TextField
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 5),
//                       child: IntlPhoneField(
//                         controller: phoneCtr,
//                         textInputAction: TextInputAction.next,
//                         showDropdownIcon: false,
//                         autovalidateMode: AutovalidateMode.disabled,
//                         /*disableLengthCheck: true,*/
//                         initialCountryCode: countryFlag,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly
//                         ],
//                         decoration:  InputDecoration(
//                           counterText: "",
//                             hintStyle: TextStyle(color: MyColors.DarkBlue,fontSize: 12),
//                             hintText: 'Enter Mobile No.'.tr,
//                             focusedBorder: InputBorder.none,
//                             border: InputBorder.none,
//                             enabledBorder: InputBorder.none),
//                         onChanged: (phone) {
//                           setState(
//                                 () {
//                               countryCode = phone.countryCode;
//                               print(countryCode);
//                             },
//                           );
//                         },
//                         onCountryChanged: (country) {
//                           setState(
//                                 () {
//                               countryCode = '${country.dialCode}';
//                               print(countryCode);
//                             },
//                           );
//
//                           //print('Country changed to: ' + country.name);
//                         },
//                       ),
//                     ),
//                   ),
//
//                 ],
//               ),
//             ),
//             SizedBox(height: 50,),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     onTap:(){
//                       Get.back();
//                     },
//                       child: Text("Back to Login".tr,style: TextStyle(color: MyColors.buttonColor),)),
//                   Obx(() => InkWell(
//                     onTap: () async {
//                       if(await valid()){
//                         controller.forgetPassword(countryCode, phoneCtr.text);
//                       }
//                     },
//                     child: Container(
//                       height: 50,
//                       width: 50,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(100),
//                           color: MyColors.orange
//                       ),
//                       child: controller.forgetPasswordLoader.value?
//                           Center(
//                             child: SizedBox(
//                               height: 20,
//                                 width: 20,
//                                 child: myIndicator()),
//                           ):
//                       Icon(Icons.arrow_forward,color: MyColors.white,),
//                     ),
//                   ))
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<bool> valid() async {
//     String _numberWithCountryCode = countryCode+phoneCtr.text;
//     bool _isValid = GetPlatform.isWeb ? true : false;
//     if(!GetPlatform.isWeb) {
//       try {
//         var phoneNumber = await PhoneNumberUtil().parse(_numberWithCountryCode);
//         _numberWithCountryCode = '+${phoneNumber.countryCode}${phoneNumber.nationalNumber}';
//         _isValid = true;
//       } catch (e) {}
//     }
//     try{
//       String springFieldUSA = countryCode+phoneCtr.text;
//       // Validate
//       bool isValid = await PhoneNumberUtil().validate(springFieldUSA);
//       print("phone validation==>");
//       print(isValid);
//     }catch(e){
//       print(e);
//     }
//     if(phoneCtr.text.isEmpty){
//       customSnackBar("Please Enter Mobile Number".tr);
//     }/*else if (!_isValid) {
//       customSnackBar("Please Enter Valid Mobile Number".tr);
//     }*/else{
//       print("vishnu");
//       return true;
//     }
//     return false;
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_number/phone_number.dart';

import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/snackBar.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController phoneCtr = TextEditingController();
  AuthController controller = Get.find<AuthController>();
  String countryFlag = "AU";
  String countryCode = "+61";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: MyColors.primary),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset("assets/images/logo.png",
                height: 170,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 25),
            Text("Forgot Password".tr,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: MyColors.primary,
                )),
            SizedBox(height: 16),
            Text("Please enter your registered mobile number to reset your password".tr,
                style: TextStyle(
                  fontSize: 16,
                  color: MyColors.black,
                  height: 1.4,
                )),
            SizedBox(height: 30),

            // Phone Input Field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mobile Number'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: MyColors.black,
                        )),
                    SizedBox(height: 8),
                    IntlPhoneField(
                      controller: phoneCtr,
                      style: TextStyle(fontSize: 16),
                      dropdownIconPosition: IconPosition.trailing,
                      dropdownIcon: Icon(Icons.arrow_drop_down_rounded,
                          color: MyColors.primary),
                      flagsButtonPadding: EdgeInsets.only(left: 12),
                      showCountryFlag: true,
                      initialCountryCode: countryFlag,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: MyColors.TextField,
                        hintText: 'Enter Mobile Number'.tr,
                        hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14),
                      ),
                      onChanged: (phone) {
                        setState(() {
                          countryCode = phone.countryCode;
                          countryFlag = phone.countryISOCode;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),

            // Submit Button
            Obx(() => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    MyColors.primary,
                    MyColors.black,
                  ],
                ),
                boxShadow: [
                  if (!controller.forgetPasswordLoader.value)
                    BoxShadow(
                      color: MyColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    )
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if(phoneCtr.text.isEmpty) {
                      customSnackBar("Please enter mobile number".tr);
                  }else{
                    controller.forgetPassword(countryCode, phoneCtr.text);

                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  minimumSize: Size(double.infinity, 0),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.forgetPasswordLoader.value
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Reset Password'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward_rounded,
                        size: 20, color: Colors.white)
                  ],
                ),
              ),
            )),
            SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Back to Login".tr,
                  style: TextStyle(
                    color: MyColors.primary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}