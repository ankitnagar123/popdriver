import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../controller/auth_controller.dart';
import '../../utils/custom_button.dart';
import '../../utils/snackBar.dart';
import '../../utils/web_auth_layout.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final AuthController controller = Get.find<AuthController>();

  String otp = "";
  String id = "";

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s remaining';
  }

  @override
  void initState() {
    super.initState();
    id = Get.arguments["id"]?.toString() ?? '';
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: MyColors.primary),
        onPressed: () => Get.back(),
      ),
      backgroundColor: Colors.transparent,
      centerTitle: true,
    );
  }

  void _submitOtp() {
    if (otp.length != 6) {
      customSnackBar("Enter OTP".tr);
      return;
    }
    controller.verifyOtp(otp, () {
      Get.offNamed(
        RouteHelper.getSetPasswordScreenRoute(),
        arguments: {"id": id},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = WebAuthLayout.isWide(context);
    final email = Get.arguments?['email']?.toString() ?? '';

    return WebAuthLayout.page(
      context: context,
      appBar: _appBar(),
      child: Column(
        children: [
          SizedBox(height: wide ? 8 : 12),
          Image.asset(
            "assets/images/logo.png",
            height: WebAuthLayout.logoHeight(context),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(height: wide ? 16 : 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 0 : 20),
            child: WebAuthLayout.formCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter OTP".tr,
                    style: TextStyle(
                      fontSize: wide ? 24 : 28,
                      fontWeight: FontWeight.w700,
                      color: MyColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Enter the 6-digit code sent to you at\n$email".tr,
                    style: TextStyle(
                      fontSize: 15,
                      color: MyColors.black.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: OtpTextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      numberOfFields: 6,
                      borderColor: MyColors.primary,
                      focusedBorderColor: MyColors.primary,
                      showFieldAsBox: true,
                      fieldWidth: wide ? 48 : 42,
                      borderRadius: BorderRadius.circular(10),
                      onCodeChanged: (String code) {
                        otp = code;
                      },
                      onSubmit: (String verificationCode) {
                        otp = verificationCode;
                        _submitOtp();
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  Obx(() {
                    final canResend = controller.remainingTime.value == 0;
                    return Row(
                      children: [
                        Expanded(
                          child: canResend
                              ? TextButton(
                                  onPressed: controller.forgetPasswordLoader.value
                                      ? null
                                      : () => controller.forgetPassword(email),
                                  child: controller.forgetPasswordLoader.value
                                      ? myIndicator()
                                      : Text(
                                          "I didn't receive code".tr,
                                          style: TextStyle(
                                            color: MyColors.buttonColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                )
                              : Text(
                                  _formatTimer(controller.remainingTime.value),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: MyColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Verify OTP'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: wide ? 24 : 16),
        ],
      ),
    );
  }
}
