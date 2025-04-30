import 'dart:developer';
import 'package:mtaanidriver/View/HomeView/support_screen/privacy_policy.dart';
import 'package:mtaanidriver/View/HomeView/support_screen/term_condition.dart';

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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  AuthController controller = Get.find<AuthController>();

  TextEditingController nameCtr = TextEditingController();
  TextEditingController middleNameCtr = TextEditingController();
  TextEditingController sirNameCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();
  TextEditingController phoneCtr = TextEditingController();

  /*TextEditingController locationCtr = TextEditingController();*/
  TextEditingController passwordCtr = TextEditingController();
  TextEditingController referralCtr = TextEditingController();

  String countryFlag = "KE";
  String countryCode = "+254";

  var companyValue = null;
  var gender = null;
  bool isCheck = false;

  bool isHide = true;
  List<String> genderList = ["Male".tr, "Female".tr, "Other".tr];
  double? lat;
  double? long;
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();


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
          style: TextStyle(color: MyColors.black),
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
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 10,
            ),
            custom_textfield(
              manditory: "*",
              labletext: "First Name".tr,
              textInputType: TextInputType.text,
              textEditingController: nameCtr,
            ),
           /* custom_textfield(
              labletext: "Middle Name".tr,
              textInputType: TextInputType.text,
              textEditingController: middleNameCtr,
            ),*/
            custom_textfield(
              manditory: "*",
              labletext: "Surname".tr,
              textInputType: TextInputType.text,
              textEditingController: sirNameCtr,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  "Select Gender".tr,
                  style: TextStyle(color: MyColors.DarkBlue),
                ),
                SizedBox(width: 5,),
                Text("*",
                  style: TextStyle(
                      color: Colors.red
                  ),),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                  color: MyColors.TextField),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  // dropdownColor: MyColors.primary,
                  hint: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Gender'.tr,
                      style: TextStyle(color: MyColors.DarkBlue, fontSize: 12),
                    ),
                  ),
                  value: gender,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 25,
                  ),
                  isExpanded: true,
                  items: genderList.map(
                        (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            value,
                            style: TextStyle(color: MyColors.black),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    setState(
                          () {
                        gender = value;
                        print("gender===>$gender");
                      },
                    );
                  },
                ),
              ),
            ),
            /*custom_textfield(
              isEmail: true,
              manditory: "*",
              labletext: "Enter Email".tr,
              textEditingController: emailCtr,
              textInputType: TextInputType.emailAddress,
            ),*/
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        children: [
                          Text('Enter Mobile No.'.tr),
                          SizedBox(width: 5,),
                          Text("*",
                            style: TextStyle(
                                color: Colors.red
                            ),),
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
                          decoration:  InputDecoration(
                              counterText: "",
                              hintStyle:
                              TextStyle(color: MyColors.DarkBlue, fontSize: 12),
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
            ),
            /*   InkWell(
              onTap: () async {
                List  result = await Get.toNamed(RouteHelper.getSelectAddressScreenRoute());
                setState(() {
                  locationCtr.text =  result[0];
                  lat = result[1];
                  long = result[2];
                  print("address-------${result[0]}");
                  print("lat-------${result[1]}");
                  print("long-------${result[2]}");
                });
              },
              child: IgnorePointer(
                child: custom_textfield(
                  labletext: "Add Location",
                  textInputType: TextInputType.text,
                  textEditingController: locationCtr,
                  icon: Icon(
                    Icons.location_on_outlined,
                    color: MyColors.primary,
                  ),
                ),
              ),
            ),*/
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
                      Icons.visibility_off,
                      color: MyColors.DarkBlue,
                    )
                        : Icon(
                      Icons.visibility,
                      color: MyColors.DarkBlue,
                    ))),
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
                    Get.to(()=>TermCondition());
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
                    Get.to(()=>PrivacyPolicy());
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
                  loading: controller.signUpCheckLoader.value,
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
    final hasSpecialCharacter = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    String _numberWithCountryCode = countryCode+phoneCtr.text;
    bool _isValid = GetPlatform.isWeb ? true : false;
    if(!GetPlatform.isWeb) {
      try {
        var phoneNumber = await PhoneNumberUtil().parse(_numberWithCountryCode);
        _numberWithCountryCode = '+' + phoneNumber.countryCode + phoneNumber.nationalNumber;
        _isValid = true;
      } catch (e) {}
    }
    print("valid -----${countryCode+phoneCtr.text}");
    try{
      String springFieldUSA = countryCode+phoneCtr.text;
      // Validate
      bool isValid = await PhoneNumberUtil().validate(springFieldUSA);
      print("phone validation==>");
      print(isValid);
    }catch(e){
      print(e);
    }
    if (nameCtr.text.trim().isEmpty) {
      customSnackBar("Please Fill Name".tr);
    } else if (nameCtr.text.length < 2) {
      customSnackBar("Name must be more than 2 characters long".tr);
    } else if (!regExp.hasMatch(nameCtr.text)) {
      customSnackBar("Not valid name".tr);
    } else if (sirNameCtr.text.trim().isEmpty) {
      customSnackBar("Please Fill Surname".tr);
    } else if (sirNameCtr.text.length < 2) {
      customSnackBar("Surname must be more than 2 characters long".tr);
    } else if (!regExp.hasMatch(sirNameCtr.text)) {
      customSnackBar("Not valid SirName".tr);
    } else if (gender == null) {
      customSnackBar("Please Choose Gender".tr);
    } /*else if (emailCtr.text.isEmpty) {
      customSnackBar("Please Fill Email".tr);
    } else if (EmailValidator.validate(emailCtr.text.toString()) != true) {
      customSnackBar("Enter Valid Email Address".tr);
    }*/ else if (phoneCtr.text.isEmpty) {
      customSnackBar("Please Enter Mobile Number".tr);
    }/*else if (!_isValid) {
      customSnackBar("Please Enter valid Mobile Number".tr);
    }*/ else if (passwordCtr.text.isEmpty) {
      customSnackBar("Please Enter Your Password".tr);
    } else if (passwordCtr.text.length < 6) {
      customSnackBar(" Password length should be 6 digit".tr);
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
    } else if (isCheck == false) {
      customSnackBar("Please Accept Term Condition".tr);
    } else {
      controller.driverSignUpCheck(
        /*emailCtr.text.trim(),*/
        phoneCtr.text.trim(),
        nameCtr.text.trim(),
        sirNameCtr.text.trim(),
        countryCode.trim(),
        passwordCtr.text.trim(),
        gender.trim(),
        countryFlag.trim(),
      );
    }
  }
}
