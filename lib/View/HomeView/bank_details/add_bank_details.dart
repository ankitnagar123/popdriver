
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';

class AddBankDetails extends StatefulWidget {
  const AddBankDetails({Key? key}) : super(key: key);

  @override
  State<AddBankDetails> createState() => _AddBankDetailsState();
}

class _AddBankDetailsState extends State<AddBankDetails> {
  AuthController controller = Get.find<AuthController>();

  TextEditingController accountNumberCtr = TextEditingController();
  TextEditingController nameCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(Icons.arrow_back_outlined)),
        title: Text("Add Bank Details".tr,style: TextStyle(color: Colors.white,fontFamily: "Poppins",fontSize: 20),),
        backgroundColor: MyColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              custom_textfield(
                manditory: "*",
                labletext: "Account Holder Name".tr,
                textInputType: TextInputType.text,
                textEditingController: nameCtr,
              ),
              custom_textfield(
                isEmail: true,
                manditory: "*",
                maxlenth: 9,
                labletext: "Account Number".tr,
                textInputType: TextInputType.number,
                textEditingController: accountNumberCtr,
              ),
              custom_textfield(
                isEmail: true,
                manditory: "*",
                labletext: "Email Address".tr,
                textInputType: TextInputType.text,
                textEditingController: emailCtr,
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(80),
                        color: MyColors.primary),
                    child: Center(
                      child: Text(
                        "i",
                        style: TextStyle(color: MyColors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Disclaimer Only For NCB Account".tr,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Obx(
                () => custom_buttons(
                    loading: controller.bankLoader.value,
                    voidCallback: () {
                      /* Get.offNamed(RouteHelper.getSelectVehicleScreenRoute());*/
                      if (isValid() == true) {
                        controller.accountHolderName.value =  nameCtr.text;
                        controller.accountNumber.value = accountNumberCtr.text;
                        controller.email.value = emailCtr.text;
                        Get.toNamed(RouteHelper.getSelectVehicleScreenRoute());
                      }
                    },
                    text: "Submit".tr),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool isValid() {
    if (nameCtr.text.isEmpty) {
      customSnackBar("Please Fill Account Holder Name".tr);
    } else if (accountNumberCtr.text.isEmpty) {
      customSnackBar("Please Fill Account Number".tr);
    } else if (accountNumberCtr.text.length < 9) {
      customSnackBar("Account Number must be more than 9 characters long".tr);
    } else if (emailCtr.text.isEmpty) {
      customSnackBar("Please Fill Email Address".tr);
    } else if (EmailValidator.validate(emailCtr.text.trim().toString()) !=
        true) {
      customSnackBar("Please Fill Valid Email Address".tr);
    } else {
      return true;
    }
    return false;
  }
}
