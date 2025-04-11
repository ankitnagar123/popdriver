import 'dart:developer';
import 'dart:io';
import '../../TestDev/MpesaPayment.dart';
import '../../controller/auth_controller.dart';
import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
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
  String countryFlag = "KE";
  String countryCode = "+254";

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

  bool isHide = true;

  var deviseName = "";
  String accessToken = "";

  var uuid = Uuid();

  @override
  void initState() {
    info();
    accessToken = uuid.v1();
    print("uuid ------- >:$accessToken");
    sp.setStringValue(sp.UU_ID, accessToken.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              "assets/images/loginImage.jpg",
              height: Get.height,
              width: Get.width,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: Get.height / 2.5,
              child: Container(
                width: Get.width,
                height: Get.height,
                decoration: BoxDecoration(
                  color: MyColors.background,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 20.0,
                      spreadRadius: 10.0,
                      offset: Offset(
                        5.0,
                        5.0,
                      ),
                    )
                  ],
                 ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Get Moving With Mtaani Driver".tr,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: 15,
                      ),
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
                                  Icons.visibility_off,
                                  color: MyColors.DarkBlue,
                                )
                              : Icon(
                                  Icons.visibility,
                                  color: MyColors.DarkBlue,
                                ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            Get.toNamed(
                                RouteHelper.getForgotPasswordScreenRoute());
                          },
                          child: Text(
                            "Forgot Password".tr,
                            style: TextStyle(color: MyColors.primary),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Stack(
                        children: [
                          Obx(
                            () => custom_buttons(
                                loading: controller.loginLoader.value,
                                voidCallback: () {
                                   // Get.to(()=>Mpesapayment());
                                  if (valid() == true) {
                                    controller.driverLogin(
                                       countryCode.toString(),
                                        phoneCtr.text,
                                        passwordCtr.text.toString(),
                                        deviseName.toString(),
                                        accessToken.toString(),
                                        context);
                                  }
                                },
                                text: 'Login'.tr),
                          ),
                          Positioned(
                            left: Get.width / 1.25,
                            top: 12,
                            child: Icon(
                              Icons.arrow_forward,
                              color: MyColors.white,
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Get.toNamed(RouteHelper.getSignUpScreenRoute());
                          },
                          child: Text(
                            "New Account? SignUp".tr,
                            style: TextStyle(color: MyColors.buttonColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool valid() {
     if (phoneCtr.text.isEmpty) {
    customSnackBar("Please Enter Mobile Number".tr);
    } else if (passwordCtr.text.isEmpty) {
      customSnackBar("Please Enter Your Password".tr);
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
}
