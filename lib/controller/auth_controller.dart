import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart' as DIO;
import 'package:mtaanidriver/controller/profile_controller.dart';

import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import '../../utils/platform_helper.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/snackBar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Model/TaxiFetchCompanyModel.dart';
import '../Model/membership_model.dart';
import '../Network/urls.dart';
import '../View/HomeView/membership_view/membership_screen.dart';
import '../route_helper/route_helper.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;

import '../utils/colors.dart';
import 'booking_controller.dart';
import 'home_screen_controller.dart';

class AuthController extends GetxController {
  DIO.Dio dioClient = DIO.Dio();
  RxString language = "English".obs;
  var destLocation = LatLng(22.719568, 75.857727).obs;
  RxString location = "".obs;
  var otp = "".obs;
  var companyLoader = false.obs;
  var signUpLoader = false.obs;
  var bankLoader = false.obs;
  var loginLoader = false.obs;
  var forgetPasswordLoader = false.obs;
  var setPasswordLoader = false.obs;
  var logoutLoader = false.obs;
  var reCheckLoader = false.obs;

  //bank perameter ====

  var accountHolderName = "".obs;
  var accountNumber = "".obs;
  var email = "".obs;

  var name = "".obs;
  var lastname = "".obs;
  var middleName = "".obs;
  var countryCode = "".obs;
  var contacts = "".obs;
  var emailID = "".obs;
  var passwords = "".obs;
  var genders = "".obs;
  var companyId = "".obs;
  var flags = "".obs;
  var referral = "".obs;

  ApiService apiService = ApiService();

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  SecureStorageService secure = SecureStorageService();
  ProfileController profileController = ProfileController();

  var companyList = <TaxiCompanyFetchModel>[].obs;

  var isOtpExpired = false.obs;
  var remainingTime = 300.obs;
  Timer? _timer;
  var deleteLoader = false.obs;
  var memberShipList = <MemberShipModel>[].obs;
  var memberShipLoader = false.obs;
  var memberShipLoader1 = false.obs;
  var otpLoader = false.obs;
  var otps = "".obs;

  void startOtpTimer() {
    _timer?.cancel(); // kill any existing timer before starting a new one
    remainingTime.value = 300;
    isOtpExpired.value = false;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        remainingTime.value--;
      } else {
        isOtpExpired.value = true;
        timer.cancel();
      }
    });
  }

  void saveLoginDetails(
      String contact, String code, String flag, String password) {
    sp.setStringValue(sp.MOBILE_NO, contact);
    sp.setStringValue(sp.COUNTRY_CODE, code);
    sp.setStringValue(sp.FLAG, flag);
    sp.setStringValue(sp.PASSWORD, password);
  }

  void driverSignUp(String vehicleId, String vehicleNo, String identityNo,
      VoidCallback callback) async {
    signUpLoader.value = true;

    Map<String, dynamic> map = {
      "vehicle_id": vehicleId,
      "vehicle_number": vehicleNo,
      "identity_no": identityNo,
      "first_name": name.value,
      "sur_name": lastname.value,
      "country_code": countryCode.value,
      "contact": contacts.value,
      "email": emailID.value,
      "password": passwords.value,
      "flag": flags.value,
    };
    log("signup parameter ------>:$map");

    try {
      final response = await apiService.postData(URLS.DRIVER_SIGNUP, map);

      var jsonString = jsonDecode(response.body);
      log("signUp response----->:$jsonString");
      if (jsonString['result'] == "successfully") {
        var id = jsonString["id"];

        secure.writeData(secure.user_id, id.toString());
        signUpLoader.value = false;
        updateDeviceId();
        // addBankDetail();
        callback();
      } else {
        signUpLoader.value = false;
        customSnackBar(jsonString['result'].toString());
      }
    } catch (e) {
      signUpLoader.value = false;
      log("Exception--------", error: e.toString());
    }
  }

  void driverSignUpCheck(
      String emails,
      String contact,
      String first_name,
      String sur_name,
      String country_code,
      String password,
      String flag,
      VoidCallback call) async {
    signUpLoader.value = true;

    Map<String, dynamic> map = {
      'contact_no': contact,
      'country_code': country_code,
    };

    log("signup check parameter ------>:$map");

    try {
      final response =
          await apiService.postDatatoken(URLS.DRIVER_SIGNUP_CHECK, map);

      var jsonString = jsonDecode(response.data);
      log("signUp check response----->:$jsonString");
      if (jsonString['result'] == "Success") {
        name.value = first_name.toString();
        lastname.value = sur_name.toString();
        emailID.value = emails.toString();
        contacts.value = contact.toString();
        // genders.value = gender.toString();
        flags.value = flag.toString();
        passwords.value = password.toString();
        countryCode.value = country_code.toString();
        signUpLoader.value = false;
        call();
        // Get.toNamed(RouteHelper.getSelectVehicleScreenRoute());
      } else {
        signUpLoader.value = false;
        customSnackBar(jsonString['result'].toString());
      }
    } catch (e) {
      signUpLoader.value = false;
      log("Exception--------", error: e.toString());
    }
  }

  void addBankDetail() async {
    bankLoader.value = true;
    Map<String, dynamic> bankParameter = {
      "driver_id": await secure.readData(secure.user_id),
      "account_holder_name": accountHolderName.value,
      "account_number": accountNumber.value,
      "email": email.value
    };
    log("parameter-------$bankParameter");

    try {
      final response =
          await apiService.postData(URLS.DRIVER_ADD_BANK_DETAIL, bankParameter);
      var jsonString = jsonDecode(response.body);
      log("response -------$jsonString");
      var result = jsonString["result"];
      if (result == "success") {
        bankLoader.value = false;
      } else {
        bankLoader.value = false;
      }
    } catch (e) {
      bankLoader.value = false;
      log("Exception-----", error: e.toString());
    }
  }

  Future<String> fetchBankDetail() async {
    Map<String, dynamic> bankParameter = {
      "driver_id": await secure.readData(secure.user_id),
    };
    log("parameter-------$bankParameter");

    try {
      final response = await apiService.postData(
          URLS.fetch_driver_bank_details, bankParameter);
      var jsonString = jsonDecode(response.body);
      log("response -------$jsonString");
      if (jsonString['account_number'] != "") {
        accountHolderName.value = jsonString['account_holder_name'];
        accountNumber.value = jsonString['account_number'];
        email.value = jsonString['email'];
      } else {}
      return jsonString['account_number'];
    } catch (e) {
      log("Exception-----", error: e.toString());
      return "";
    }
  }

  void driverLogin(
      String country_code,
      flag,
      contact,
      String password,
      String login_device_key,
      String access_token,
      bool isChecked,
      context) async {
    loginLoader.value = true;
    Map<String, dynamic> loginParameter = {
      "country_code": country_code,
      "contact": contact,
      "password": password,
      "status": "1",
      "login_device_key": login_device_key,
      "access_token": access_token,
    };
    log("parameter-------$loginParameter");
    log("parameter-------${URLS.DRIVER_LOGIN}");

    try {
      final response =
          await http.post(Uri.parse(URLS.api(URLS.DRIVER_LOGIN)), body: loginParameter);

      var jsonString = jsonDecode(response.body);

      log("login response--------$jsonString");
      var result = jsonString["result"];
      var driverId = jsonString["driver_id"];
      var inviteCode = jsonString["invite_code"];
      var driverName = jsonString["name"];
      if (result == 'Success') {
        if (isChecked) {
          log("-----isChecked");
          log("contact-----$contact");
          log("country_code-----$country_code");
          log("flag-----$flag");
          saveLoginDetails(contact, country_code, flag, password);
        } else {
          log("is not -----isChecked");

          saveLoginDetails("", "", "", "");
        }
        print("user id -------${jsonString["driver_id"]}");
        updateDeviceId();
        await sp.setBoolValue(sp.LOGIN_KEY, true);
        await sp.setBoolValue(sp.ON_BOARDING_KEY, true);
        await secure.writeData(secure.Token, jsonString['token']);
        await sp.setStringValue(sp.INVITE_CODE, inviteCode.toString());
        await sp.setStringValue(
            sp.LOGIN_DEVICE_KEY, login_device_key.toString());
        await sp.setStringValue(sp.ACCESS_TOKEN, access_token.toString());
        await secure.writeData(secure.user_name, driverName.toString());
        await secure.writeData(secure.user_id, driverId.toString());
        loginLoader.value = false;
        Get.offNamed(RouteHelper.getHomeScreenScreenRoute(),
            arguments: {"ArriveDriver": ""});
        customSnackBar("Login successful".tr);
      } else if (result == "You Are Already Logged-in In Other Device") {
        secure.writeData(secure.user_id, driverId.toString());
        loginLoader.value = false;
        customSnackBar(result.toString(), context: context);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      "Session Alert".tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Divider
                    Divider(
                      height: 1,
                      color: Colors.grey[300],
                    ),

                    const SizedBox(height: 20),

                    // Message
                    Text(
                      "You are already logged in on another device. Do you want to logout from that device?"
                          .tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.red.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel".tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.green.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              await driverLogout("1", () {
                                Navigator.pop(context);
                              });
                            },
                            child: Text(
                              "Logout".tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else if (result == "You Don't have any active membership") {
        loginLoader.value = false;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MemberShipScreen(type: "signup")));
      } else {
        loginLoader.value = false;
        customSnackBar(result.toString(), context: context);
      }
    } catch (e) {
      customSnackBar("something went wrong", context: context);
      loginLoader.value = false;
      log("Exception-----", error: e.toString());
    }
  }

  void forgetPassword(String email) async {
    forgetPasswordLoader.value = true;
    Map<String, dynamic> forgetParameter = {
      "email": email,
    };

    log("forget password parameter ------>:$forgetParameter");
    try {
      var response = await apiService.postDatatoken(
          URLS.DRIVER_FORGET_PASSWORD, forgetParameter);
      var jsonString = jsonDecode(response.data);
      log("forget Password response ------>:$jsonString");
      var result = jsonString["result"];
      var driverId = jsonString["driver_id"];
      if (result == "success") {
        emailID.value = email;
        startOtpTimer();
        otp.value = jsonString["OTP"].toString();
        customSnackBar("OTP ${jsonString["OTP"].toString()}");

        forgetPasswordLoader.value = false;
        Get.offNamed(RouteHelper.getOtpScreenRoute(), arguments: {
          "id": driverId,
          "email": email,
        });
      } else {
        forgetPasswordLoader.value = false;
        customSnackBar(result.toString());
      }
    } catch (e) {
      forgetPasswordLoader.value = false;
      log("Exception -----", error: e.toString());
    }
  }

  void setPassword(String password, String id) async {
    setPasswordLoader.value = true;
    Map<String, dynamic> setParameter = {"driver_id": id, "password": password};

    log("set password parameter------>:$setParameter");
    try {
      var response = await apiService.postDatatoken(
          URLS.DRIVER_SET_PASSWORD, setParameter);
      var jsonString = jsonDecode(response.data);
      log("set Password response ------>:$jsonString");
      var result = jsonString["result"];
      if (result == "Password changed successfully") {
        setPasswordLoader.value = false;
        Get.offNamed(RouteHelper.getPasswordChangeSuccessScreenRoute());
      } else {
        setPasswordLoader.value = false;
        customSnackBar("Something went wrong".tr);
      }
    } catch (e) {
      setPasswordLoader.value = false;
      log("Exception -----", error: e.toString());
    }
  }

  /// Clears JWT, driver id, prefs (except saved login fields), booking timers, etc.
  /// Runs after logout API attempt; local data is always wiped so no ghost session.
  Future<void> _clearLocalDriverSession(String text) async {
    if (text != "1") {
      try {
        Get.find<BookingController>().cancel();
      } catch (e) {
        log('BookingController.cancel on logout: $e');
      }
    }

    final language = await sp.getStringValue(sp.LANGUAGE);
    await sp.clearDataExceptLoginFields();
    await secure.deleteAllData();
    await sp.setBoolValue(sp.ON_BOARDING_KEY, true);

    if (language != null && language.isNotEmpty) {
      await sp.setStringValue(sp.LANGUAGE, language);
    }
  }

  Future<void> driverLogout(String text, VoidCallback callback) async {
    logoutLoader.value = true;

    final driverId = await secure.readData(secure.user_id);
    final logout = {"driver_id": driverId};
    log("logout id :------>:$logout");

    var serverAck = false;
    try {
      final response =
          await apiService.postDatatoken(URLS.DRIVER_LOGOUT, logout);
      final jsonString = jsonDecode(response.data);
      log("logout response :--------$jsonString");
      final result = jsonString['result'];
      serverAck =
          result != null && result.toString().trim().toLowerCase() == 'success';
      if (!serverAck) {
        log("logout API result not success: $result");
      }
    } catch (e) {
      log("logout API exception", error: e.toString());
    }

    try {
      await _clearLocalDriverSession(text);
    } catch (e) {
      log("local session clear failed", error: e.toString());
    } finally {
      logoutLoader.value = false;
    }

    callback();
    customSnackBar(
      serverAck ? "Logout Successfully".tr : "You have been logged out".tr,
    );
  }

  void updateDeviceId() async {
    if (kIsWeb) return;
    String deviceStatus = "";
    String? device_id = "";
    if (isAndroid) {
      deviceStatus = "Android";
      await FirebaseMessaging.instance.getToken().then((value) {
        device_id = value;
      });
    } else if (isIOS) {
      await FirebaseMessaging.instance
          .getToken(
              vapidKey:
                  "BMnb7_ZxdnVb55eNi0sJRzxoI2QdFGUZrMBgIiL2tlPLcB4NYT4OAnhcJW3BY2F7g0gs-AKFQ-omjP0x5sk7UMc")
          .then((value) {
        device_id = value;
      });
      deviceStatus = "IOS";
      log('device id------$device_id');
    }

    Map<String, dynamic> deviceId = {
      "driver_id": await secure.readData(secure.user_id),
      "device_id": device_id,
      "device_status": deviceStatus,
    };

    log("Parameter update device id--------$deviceId");

    try {
      final response =
          await apiService.postData(URLS.DEVICE_ID_UPDATE, deviceId);

      var jsonString = jsonDecode(response.body);

      log("device id update response------>:$jsonString");

      var result = jsonString['result'];
      if (result == "Update successfully") {
        log("updated device id");
      } else {
        log('Something went wrong'.tr);
      }
    } catch (e) {
      print("exception device id==>${e}");
    }
  }

  void loginCheck(String loginDeviceKey, accessToken, context) async {
    reCheckLoader.value = true;
    String Tokan = await secure.readData(secure.Token) ?? "";
    Map<String, dynamic> check = {
      "driver_id": await secure.readData(secure.user_id),
      "login_device_key": loginDeviceKey,
      "access_token": accessToken
    };

    log("login Check parameter----->:$check");

    try {
      final response = await http.post(
          Uri.parse(URLS.api(URLS.DRIVER_LOGIN_CHECK)),
          headers: {
            'Authorization': 'Bearer $Tokan',
            // Pass the JWT token in the headers
          },
          body: check);

      var jsonString = jsonDecode(response.body);

      log('login Check response--------->:${response.body}');
      var result = jsonString['result'];
      log('response login--------->:$result');
      if (jsonString['result'] == "You Are Already Logged-in In Other Device") {
        await driverLogout("", () {});
        Future.delayed(Duration.zero, () {
          Get.find<HomeController>().streamSubscription.cancel();
        });
        /* customSnackBar(result.toString());*/
        Get.offAllNamed(RouteHelper.getLoginScreenRoute());
        reCheckLoader.value = false;
      } else if (jsonString['result'] == "Success") {
        reCheckLoader.value = false;
      } else if (jsonString['result'] == "Token has expired") {
        await driverLogout("", () {});
        Future.delayed(Duration.zero, () {
          Get.find<HomeController>().streamSubscription.cancel();
        });
        customSnackBar(result.toString());
        Get.offAllNamed(RouteHelper.getLoginScreenRoute());
        reCheckLoader.value = false;
      } else {}
    } catch (e) {
      reCheckLoader.value = false;
      log("Exception------->:loginCheck", error: e.toString());
    }
  }

  void deleteAccount() async {
    deleteLoader.value = true;
    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id)
    };
    try {
      final response =
          await apiService.postData(URLS.DRIVER_DELETE_ACCOUNT, map);

      var jsonString = jsonDecode(response.body);

      if (jsonString['result'] != null &&
          jsonString['result'].toString().trim().toLowerCase() == "success") {
        deleteLoader.value = false;
        await sp.clearData();
        await secure.deleteAllData();
        Future.delayed(Duration.zero, () {
          Get.find<HomeController>().streamSubscription.cancel();
        });
        customSnackBar("Account Deleted");
        Get.offAllNamed(RouteHelper.getLoginScreenRoute());
      } else {
        deleteLoader.value = false;
        customSnackBar("Something Went Wrong".tr);
      }
    } catch (e) {
      deleteLoader.value = false;
      customSnackBar("Something went wrong".tr);
    }
  }

  void memberShip() async {
    memberShipLoader.value = true;

    try {
      final response = await dioClient.get(URLS.api(URLS.fetch_membership_list));

      log("response ----", error: response.data);

      memberShipList.value = memberShipModelFromJson(response.data);

      memberShipLoader.value = false;
    } catch (e) {
      memberShipLoader.value = false;
      log("Exception ------", error: e.toString());
    }
  }

  void buyMemberShip(String membershipId, amount, contactNumber, String type,
      paymentType) async {
    memberShipLoader1.value = true;

    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id),
      "membership_id": membershipId,
      "amount": amount,
      "contact_number": contactNumber,
    };
    log("Payment Request Params: $map");

    try {
      final response =
          await apiService.postDatatoken(URLS.driver_add_membership, map);
      var jsonString = jsonDecode(response.data);
      log("Payment Request Response: ${jsonString['result']}");

      if (jsonString['result'] ==
          "Payment request sent successfully. Enter M-PESA PIN to complete.") {
        customSnackBar(jsonString['result'].toString());
        showPaymentProcessingDialog(Get.context!, () {
          checkPaymentStatus(membershipId, type, paymentType);
        });
        // 🔁 Wait 30 seconds before checking payment
        /* await Future.delayed(Duration(seconds: 30));
        await checkPaymentStatus(membership_id, type);*/
      } else {
        customSnackBar(jsonString['result'].toString());
      }
    } catch (e) {
      log("Exception during payment request", error: e.toString());
      customSnackBar("❌ Error initiating payment.");
    } finally {
      memberShipLoader1.value = false;
    }
  }

  Future<void> checkPaymentStatus(
    String membership_id,
    String type,
    String paymentType,
  ) async {
    memberShipLoader1.value = true;

    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id),
      "payment_type": paymentType
    };
    log("Check Payment Params: $map");

    try {
      final response =
          await apiService.postDatatoken(URLS.check_payment_status, map);
      var jsonString = jsonDecode(response.data);
      log("Payment Status Response: ${jsonString['result']}");

      if (jsonString['result'] == "paid") {
        customSnackBar("✅ Payment successful!");
        await buyMemberShipComplete(membership_id, type);
      } else {
        customSnackBar("⏳ Payment still pending. Try again later.");
      }
    } catch (e) {
      log("Exception during payment status check", error: e.toString());
      customSnackBar("❌ Error checking payment status.");
    } finally {
      memberShipLoader1.value = false;
    }
  }

  Future<void> buyMemberShipComplete(String membership_id, String type) async {
    memberShipLoader1.value = true;

    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id),
      "membership_id": membership_id,
    };
    log("Membership Complete Params: $map");

    try {
      final response = await apiService.postDatatoken(
          URLS.driver_add_membership_complete, map);
      var jsonString = jsonDecode(response.data);
      log("Membership Complete Response: ${jsonString['result']}");

      if (jsonString['result'] == "success") {
        if (type == "signup") {
          _showSuccessDialog();
        } else {
          Get.back();
          Get.find().fetchDriverDetail();
          customSnackBar("🚀 Plan upgraded successfully.");
          profileController.fetchDriverDetail();
        }
      } else {
        customSnackBar("⚠️ ${jsonString['result']}");
      }
    } catch (e) {
      log("Exception during membership complete", error: e.toString());
      customSnackBar("❌ Error updating membership.");
    } finally {
      memberShipLoader1.value = false;
    }
  }

  void showPaymentProcessingDialog(
      BuildContext context, VoidCallback onComplete) {
    int secondsLeft = 30;
    Timer? timer;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
          if (secondsLeft == 0) {
            t.cancel();
            Navigator.of(context).pop(); // Close the dialog
            onComplete(); // Trigger payment check
          } else {
            secondsLeft--;
          }
        });

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Processing Payment"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Please enter your M-PESA PIN on your phone."),
                SizedBox(height: 8),
                Text("Checking payment in $secondsLeft seconds..."),
              ],
            ),
          );
        });
      },
    ).then((_) {
      timer?.cancel(); // Cancel if dialog closed early
    });
  }

  void signupOtp(String type, VoidCallback callback) async {
    otpLoader.value = true;
    Map<String, dynamic> otpParameter = {
      "email": emailID.value,
      "appType": "Driver"
    };

    log("otp parameter------>:$otpParameter");
    try {
      var response =
          await apiService.postDatatoken(URLS.send_otp, otpParameter);
      var jsonString = jsonDecode(response.data);
      log("otp response ------>:$jsonString");
      var result = jsonString["result"];
      if (result == "successfully") {
        startOtpTimer();
        otps.value = jsonString["otp"].toString();
        Get.showSnackbar(GetSnackBar(
          backgroundColor: MyColors.black,
          borderRadius: 10,
          duration: Duration(seconds: 6),
          maxWidth: Get.width / 1.1,
          message: "OTP ${jsonString["OTP"].toString()}",
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.only(bottom: 20),
        ));
        otpLoader.value = false;
        if (type == "") {
          callback();
        }
      } else {
        otpLoader.value = false;
        customSnackBar(result.toString());
      }
    } catch (e) {
      otpLoader.value = false;
      log("Exception -----", error: e.toString());
    }
  }

  var otpVerify = false.obs;
  var otpVerify2 = false.obs;

  void verifyOtp(String otp, VoidCallback callback) async {
    otpVerify.value = true;
    Map<String, dynamic> otpParameter = {"email": emailID, "otp": otp};
    log("otp verify parameter------>:$otpParameter");
    try {
      var response =
          await apiService.postDatatoken(URLS.verify_driver_otp, otpParameter);
      var jsonString = jsonDecode(response.data);
      log("otp response ------>:$jsonString");
      var result = jsonString["result"];
      if (result == "OTP verified successfully") {
        callback();
      } else {
        customSnackBar(result.toString());
      }
      otpVerify.value = false;
    } catch (e) {
      otpVerify.value = false;
      log("Exception -----", error: e.toString());
    }
  }

  void verifyOtp2(String otp, id, VoidCallback callback) async {
    otpVerify2.value = true;
    Map<String, dynamic> otpParameter = {"booking_id": id, "otp": otp};
    log("otp verify parameter------>:$otpParameter");
    try {
      var response = await apiService.postData(
          URLS.varify_booking_start_otp, otpParameter);
      if (response.body.trim().isEmpty) {
        otpVerify2.value = false;
        customSnackBar("Server returned an empty response. Please try again.");
        return;
      }
      var jsonString = jsonDecode(response.body);
      log("otp response ------>:$jsonString");
      var result = jsonString["result"].toString();
      if (result == "OTP verified successfully") {
        callback();
      } else {
        customSnackBar(result.toString());
      }
      otpVerify2.value = false;
    } catch (e) {
      otpVerify2.value = false;
      log("Exception -----", error: e.toString());
    }
  }

  // Encryption function
  String encryptData(String plainText, String key, String iv) {
    final keyBytes = encrypt.Key.fromUtf8(key);
    final ivBytes = encrypt.IV.fromUtf8(iv);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: ivBytes);
    return encrypted.base64;
  }

  // Decryption function for testing
  String decryptData(String encryptedText, String key, String iv) {
    final keyBytes = encrypt.Key.fromUtf8(key);
    final ivBytes = encrypt.IV.fromUtf8(iv);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    final decrypted = encrypter.decrypt(encrypted, iv: ivBytes);
    return decrypted;
  }

  // Function to send encrypted data to API
  Future<void> sendEncryptedData(
      String userId, String name, String email) async {
    final String key = 'qweasdrfzgxvcbnj'; // Replace with your 16-character key
    final String iv = '15234863kiuyhjng'; // Replace with your 16-character IV

    // Combine the parameters into a JSON object
    final Map<String, String> data = {
      'userId': userId,
      'name': name,
      'email': email,
    };

    // Convert the JSON object to a string and encrypt it
    final encryptedData = encryptData(jsonEncode(data), key, iv);

    // Testing decryption (optional)
    final decryptedData = decryptData(encryptedData, key, iv);
    print("Encrypted Data ------: $encryptedData");
    print("Decrypted Data ------: $decryptedData");

    // Send the encrypted data to your PHP API
    final response = await http.post(
      Uri.parse('https://yourapi.com/endpoint'),
      // Replace with your API endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': encryptedData
      }), // Send the encrypted data in the request body
    );

    // Check the response status
    if (response.statusCode == 200) {
      print('Data sent successfully');
    } else {
      print('Failed to send data');
    }
  }
}

void _showSuccessDialog() {
  showDialog(
    context: Get.context!,
    builder: (context) => AlertDialog(
      title: Text('Account Created'),
      content: Text(
          'Your account has been successfully created. You will receive approval from the admin within the next 24 hours.\n\nThank you for your patience.'),
      actions: [
        TextButton(
          onPressed: () => Get.offAllNamed(RouteHelper.getLoginScreenRoute()),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
