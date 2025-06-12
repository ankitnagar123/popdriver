import 'dart:developer';
import 'package:mtaanidriver/View/HomeView/support_screen/privacy_policy.dart';
import 'package:mtaanidriver/View/HomeView/support_screen/term_condition.dart';

import '../../controller/vehicle_controller.dart';
import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/text_field.dart';
import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
import '../../utils/snackBar.dart';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_number/phone_number.dart';

import '../../utils/regex.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  AuthController controller = Get.find<AuthController>();
  VehicleController vehicleController = Get.put(VehicleController());

  TextEditingController nameCtr = TextEditingController();
  TextEditingController middleNameCtr = TextEditingController();
  TextEditingController sirNameCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();

  /*TextEditingController locationCtr = TextEditingController();*/
  TextEditingController passwordCtr = TextEditingController();
  TextEditingController referralCtr = TextEditingController();

  TextEditingController vehicleNumberCtr = TextEditingController();
  TextEditingController identityNoCtr = TextEditingController();

  String countryFlag = "AU";
  String countryCode = "+61";

  var companyValue = null;

  // var gender = null;
  bool isCheck = false;

  bool isHide = true;
  List<String> genderList = ["Male".tr, "Female".tr, "Other".tr];
  double? lat;
  double? long;
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

  @override
  void initState() {
    phoneCtr.text ="4";
    super.initState();
    vehicleController.fetchVehicle();
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
        title: Text(
          "Driver Account".tr,
          style: TextStyle(color: MyColors.black,fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Account Details".tr,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: custom_textfield(
                    manditory: "*",
                    labletext: "First Name".tr,
                    textInputType: TextInputType.text,
                    textEditingController: nameCtr,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: custom_textfield(
                    manditory: "*",
                    labletext: "Last Name".tr,
                    textInputType: TextInputType.text,
                    textEditingController: sirNameCtr,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            custom_textfield(
              allowSpecialCharacters: true,
              isEmail: true,
              manditory: "*",
              labletext: "Email Address".tr,
              textInputType: TextInputType.emailAddress,
              textEditingController: emailCtr,
            ),
            SizedBox(
              height: 15,
            ),
            Column(
              children: [
                Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      children: [
                        Text('Enter Mobile No.'.tr),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "*",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    )),
                Container(
                  height: 50,
                  width: context.width,
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: MyColors.TextField),
                  child: Center(
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
                        decoration: InputDecoration(
                            counterText: "",
                            hintStyle: TextStyle(
                                color: MyColors.DarkBlue, fontSize: 12),
                            hintText: 'Mobile Number'.tr,
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none),
                        onChanged: (phone) {
                          setState(
                            () {
                              countryCode = phone.countryCode;
                              print(countryCode);
                              countryFlag = phone.countryISOCode;
                              log("${countryFlag}");
                            },
                          );
                        },
                        onCountryChanged: (country) {
                          setState(
                            () {
                              countryCode = '${country.dialCode}';
                              print(countryCode);
                              countryFlag = country.code;
                              print(countryFlag);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            custom_textfield(
                allowSpecialCharacters: false,
                manditory: "*",
                labletext: "Password".tr,
                ishide: isHide,
                textInputType: TextInputType.text,
                textEditingController: passwordCtr,
                icon: InkWell(
                    onTap: () {
                      setState(() {
                        isHide = !isHide;
                      });
                    },
                    child: isHide
                        ? Icon(
                            size: 18,
                            Icons.visibility_off,
                            color: MyColors.DarkBlue,
                          )
                        : Icon(
                            size: 18,
                            Icons.visibility,
                            color: MyColors.DarkBlue,
                          ))),
            custom_textfield(
              manditory: "*",
              allowSpecialCharacters: false,
              labletext: "Vehicle Number".tr,
              textEditingController: vehicleNumberCtr,
              textInputType: TextInputType.text,
            ),
            custom_textfield(
              manditory: "*",
              allowSpecialCharacters: false,
              labletext: "Identity Number".tr,
              textEditingController: identityNoCtr,
              textInputType: TextInputType.text,
            ),
            SizedBox(
              height: 10,
            ),
            _buildCarListDropdown(vehicleController),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  width: 25,
                  child: Checkbox(
                      //visualDensity: VisualDensity(horizontal:-4),
                      checkColor: MyColors.white,
                      activeColor: MyColors.primary,
                      side: const BorderSide(color: MyColors.primary),
                      value: isCheck,
                      onChanged: (bool? val) {
                        setState(() {
                          isCheck = val!;
                          print(isCheck);
                        });
                      }),
                ),
                Text(
                  "I agree to the".tr,
                  style: TextStyle(color: MyColors.DarkBlue, fontSize: 10),
                ),
                SizedBox(
                  width: 3,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => TermConditionScreen());
                  },
                  child: Text(
                    "terms of service and ".tr,
                    style: TextStyle(color: MyColors.primary, fontSize: 10),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => PolicyScreen());
                  },
                  child: Text(
                    "privacy policy".tr,
                    style: TextStyle(color: MyColors.primary, fontSize: 10),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Obx(
              () => custom_buttons(
                  loading: controller.signUpLoader.value,
                  voidCallback: () {
                    validate();
                    /*Get.toNamed(RouteHelper.getAddBankDetailsScreenRoute());*/
                  },
                  text: "Sign Up".tr),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?".tr),
                TextButton(
                    onPressed: () {
                      Get.offNamed(RouteHelper.getLoginScreenRoute());
                    },
                    child: Text(
                      "Login".tr,
                      style: TextStyle(color: MyColors.primary),
                    ))
              ],
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Future<void> validate() async {
    String password = passwordCtr.value.text.toString();

    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacter =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    final RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (nameCtr.text.trim().isEmpty) {
      customSnackBar("Please Fill Name".tr);
    } else if (nameCtr.text.length < 2) {
      customSnackBar("Name must be more than 2 characters long".tr);
    }
    /* else if (sirNameCtr.text.trim().isEmpty) {
      customSnackBar("Please Fill Last Name".tr);
    } else if (sirNameCtr.text.length < 2) {
      customSnackBar("Last Name must be more than 2 characters long".tr);
    } */
    else if (emailCtr.text.trim().isEmpty) {
      customSnackBar("Please Enter Email address".tr);
    } else if (!emailRegExp.hasMatch(emailCtr.text.trim())) {
      customSnackBar("Please Enter a valid Email address".tr);
    }
    /*else if (gender == null) {
      customSnackBar("Please Choose Gender".tr);
    }*/
    else if (phoneCtr.text.isEmpty) {
      customSnackBar("Please Enter Mobile Number".tr);
    } else if (passwordCtr.text.isEmpty) {
      customSnackBar("Please Enter Your Password".tr);
    } else if (passwordCtr.text.length < 6) {
      customSnackBar(" Password length should be 6 digit".tr);
    } else if (!hasUppercase) {
      customSnackBar('Password must contain at least one uppercase letter'.tr);
    } else if (!hasLowercase) {
      customSnackBar('Password must contain at least one lowercase letter'.tr);
    } else if (!hasDigit) {
      customSnackBar('Password must contain at least one digit'.tr);
    } else if (!hasSpecialCharacter) {
      customSnackBar('Password must contain at least one special character'.tr);
    } else if (vehicleNumberCtr.text.isEmpty) {
      customSnackBar("Please Enter Vehicle Registration Number".tr);
    } else if (identityNoCtr.text.isEmpty) {
      customSnackBar("Please Enter Identity Number".tr);
    } else if (vehicleController.selectedCarId.value.isEmpty) {
      customSnackBar("Please Enter Vehicle Type".tr);
    } else if (isCheck == false) {
      customSnackBar("Please Accept Term Condition".tr);
    } else {
      controller.driverSignUpCheck(
          emailCtr.text.trim(),
          phoneCtr.text.trim(),
          nameCtr.text.trim(),
          sirNameCtr.text.trim(),
          countryCode.trim(),
          passwordCtr.text.trim(),
          // gender.trim(),
          countryFlag.trim(), () async {
        controller.signupOtp("", () async {
          var result = await Get.toNamed(RouteHelper.getSignupOTPScreen());
          if (result == "back") {
            controller.driverSignUp(
              vehicleController.selectedCarId.value,
              vehicleNumberCtr.text,
              identityNoCtr.text,
              () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (ctx) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(-5, -5),
                                ),
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(5, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 80,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Got your registration!",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "Our team will contact you shortly.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.offAll(() => LoginScreen());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MyColors.black,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 30,
                                      ),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      shadowColor: Colors.blue.withOpacity(0.3),
                                    ),
                                    child: Text(
                                      "Go Back",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ));
              },
            );
          }
        });
      });
    }
  }

  Widget _buildCarListDropdown(VehicleController vehicleController) {
    return Obx(() {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: MyColors.TextField,
          labelText: "Select Vehicle Type",
          labelStyle: TextStyle(fontSize: 13),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          // reduced height
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        value: vehicleController.selectedCarId.value.isEmpty
            ? null
            : vehicleController.selectedCarId.value,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        isExpanded: true,
        items: vehicleController.vehicleList.map((make) {
          return DropdownMenuItem<String>(
            value: make.carId,
            child: Text(
              make.carName,
              style: TextStyle(fontFamily: "Poppins"),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            vehicleController.selectedCarId.value = value;
          }
        },
      );
    });
  }
}
