import 'dart:developer';
import 'dart:io';
import '../../controller/auth_controller.dart';
import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/snackBar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:uuid/uuid.dart';

import '../../utils/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthController controller = Get.find<AuthController>();
  TextEditingController phoneCtr = TextEditingController();
  TextEditingController passwordCtr = TextEditingController();
  String countryFlag = "AU";
  String countryCode = "+61";
  bool? _checked = false;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

  bool isHide = true;

  var deviseName = "";
  String accessToken = "";

  var uuid = Uuid();

  @override
  void initState() {
    info();
    setValue();
    accessToken = uuid.v1();
    print("uuid ------- >:$accessToken");
    sp.setStringValue(sp.UU_ID, accessToken.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet:    Container(color: MyColors.background,
        child: TextButton(
          onPressed: () {
            Get.toNamed(RouteHelper.getSignUpScreenRoute());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don’t have an account?".tr,
                style: TextStyle(color:Colors.grey,fontSize: 13),
              ), Text(
                " SignUp".tr,
                style: TextStyle(color: MyColors.buttonColor,fontSize: 15,fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child:
        Column(
          children: [
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: MyColors.primary.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Image.asset(
                "assets/images/logo.png",
                height: 200,
                // width: 180,
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: MyColors.background,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                          offset: Offset(0, 10),
                        )
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          MyColors.background.withOpacity(0.9),
                          MyColors.background,
                        ],
                      )),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Center(
                    child: Text(
                    "Get Moving With POP Driver 👨‍✈️".tr,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: MyColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 25),

                  // Phone Number Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    disableLengthCheck: false,
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
                      SizedBox(
                        height: 10,
                      ),
                      custom_textfield(
                        allowSpecialCharacters: false,
                        labletext: "Enter Password".tr,
                        textEditingController: passwordCtr,
                        textInputType: TextInputType.text,
                        ishide: isHide,
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
                          ),
                        ),
                      ),

                    ],
                  ),
                        Row(
                          children: [
                            Checkbox(
                              value: _checked,
                              onChanged: (value) =>
                                  setState(() => _checked = value),
                              activeColor: MyColors.primary,
                            ),
                            Text(
                              "Remember me".tr,
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Get.toNamed(RouteHelper.getForgotPasswordScreenRoute()),
                      child: Text(
                        "Forgot Password?".tr,
                        style: TextStyle(
                          color: MyColors.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 25),
                  Obx(() => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              MyColors.primary,
                              MyColors.DarkBlue,
                            ],
                          ),
                          boxShadow: [
                          if (!controller.loginLoader.value)
                      BoxShadow(
                  color: MyColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {


                      if (valid()) {
                        controller.driverLogin(
                            countryCode.toString(),
                            countryFlag.toString(),
                            phoneCtr.text,
                            passwordCtr.text.toString(),
                            deviseName.toString(),
                            accessToken.toString(),
                            _checked!,
                            context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(double.infinity, 0),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: controller.loginLoader.value
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white)
                      ],
                    ),
                  ),
                )),

          ],
        ),
      ),
    ),
    ),
            SizedBox(height: 50,),
    ],
    ),
      ),
    );
  }

  bool valid() {
    if (phoneCtr.text.isEmpty) {
      customSnackBar("Please Enter Mobile Number".tr, context: context);
    } else if (passwordCtr.text.isEmpty) {
      customSnackBar("Please Enter Your Password".tr, context: context);
    } else {
      return true;
    }
    return false;
  }

  void info() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviseName = androidInfo.model;
      print('Android devise info $deviseName');
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviseName = iosInfo.utsname.machine;
      print('IOS devise info $deviseName');
    }
  }


  Future<void> setValue() async {
    // Get mobile number using sp.getString()
    String mobileNumber = (await sp.getStringValue(sp.MOBILE_NO)) ?? "";
    String password = (await sp.getStringValue(sp.PASSWORD)) ?? "";
    String code = (await sp.getStringValue(sp.COUNTRY_CODE)) ?? "";
    String flag = (await sp.getStringValue(sp.FLAG)) ?? "";

    print("Mobile number:-- $mobileNumber");
    print("Country Code:-- $code");
    print("Country Flag:-- $flag");
    print("Controllers updated: ${phoneCtr.text}, ${passwordCtr.text}");

    setState(() {
      if (mobileNumber.isNotEmpty) {
        phoneCtr.text = mobileNumber;
        _checked =true;
      }
      if (password.isNotEmpty) {
        passwordCtr.text = password;
      }
      if (code.isNotEmpty) {
        countryCode = code;
      }
      if (flag.isNotEmpty) {
        countryFlag = flag;
      }

    });
  }

}
