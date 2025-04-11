import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/text_field.dart';
import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
import '../../utils/snackBar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';

class SetPassword extends StatefulWidget {
  const SetPassword({Key? key}) : super(key: key);

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {

  TextEditingController passCtr = TextEditingController();
  TextEditingController rePassCtr = TextEditingController();

  final controller = Get.find<AuthController>();

  String id = "";
  bool isHide = true;
  bool isVisible = true;
  @override
  void initState() {
   id = Get.arguments["id"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Text("Set New Password".tr,style: TextStyle(fontSize: 20),),
            SizedBox(height: 20,),
            Text("Enter new password. password must be 5 to 10 character long".tr,style: TextStyle(fontSize: 15),),
            SizedBox(height: 20,),
            custom_textfield(
              allowSpecialCharacters: false,
              labletext: "Create New Password".tr,
              textEditingController: passCtr,
              ishide: isHide,
              textInputType: TextInputType.text,
              icon: InkWell(
                onTap: (){
                  setState(() {
                    isHide = !isHide;
                  });
                },
                  child: isHide
                      ? Icon(
                    Icons.visibility_off,
                    color: MyColors.DarkBlue,
                  )
                      : Icon(
                    Icons.visibility,
                    color: MyColors.DarkBlue,
                  )),
            ),
            custom_textfield(
              allowSpecialCharacters: false,
              labletext: "Re-enter Password".tr,
              textEditingController: rePassCtr,
              ishide: isVisible,
              textInputType: TextInputType.text,
              icon: InkWell(
                onTap: (){
                 setState(() {
                   isVisible = !isVisible;
                 });
                },
                  child:isVisible
                      ? Icon(
                    Icons.visibility_off,
                    color: MyColors.DarkBlue,
                  )
                      : Icon(
                    Icons.visibility,
                    color: MyColors.DarkBlue,
                  )),
            ),

            SizedBox(height: 50,),
          Obx(() =>  custom_buttons(
            loading: controller.setPasswordLoader.value,
              voidCallback: (){
              if(valid()== true){
                controller.setPassword(passCtr.text, id.toString());
              }
          }, text: "Continue".tr))
          ],
        ),
      ),
    );
  }

 bool valid(){

   String password = passCtr.value.text.toString();

   final hasUppercase = password.contains(RegExp(r'[A-Z]'));
   final hasLowercase = password.contains(RegExp(r'[a-z]'));
   final hasDigit = password.contains(RegExp(r'[0-9]'));
   final hasSpecialCharacter = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if(passCtr.text.isEmpty){
      customSnackBar("Please enter New Password".tr);
    }else if (password.length < 6) {
      customSnackBar("Password must be at least 6 characters long".tr);
    }else
    if (!hasUppercase) {
      customSnackBar('Password must contain at least one uppercase letter'.tr);
    }
    else if (!hasLowercase) {
      customSnackBar('Password must contain at least one lowercase letter'.tr);
    }
    else if (!hasDigit) {
      customSnackBar('Password must contain at least one digit'.tr);
    }
    else if (!hasSpecialCharacter) {
      customSnackBar('Password must contain at least one special character'.tr);
    }else if(rePassCtr.text.isEmpty){
      customSnackBar("Please Re-enter Password".tr);
    }else if(passCtr.text != rePassCtr.text){
      customSnackBar("Password Does Not Match".tr);
    }else{
      return true;
    }
    return false;
 }
}
