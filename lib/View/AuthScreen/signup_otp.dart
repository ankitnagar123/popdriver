import 'package:pin_code_fields/pin_code_fields.dart';

import '../../utils/colors.dart';
import '../../controller/auth_controller.dart';
import '../../utils/custom_button.dart';
import '../../utils/snackBar.dart';
import '../../utils/web_auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupOTP extends StatefulWidget {
  const SignupOTP({Key? key}) : super(key: key);

  @override
  State<SignupOTP> createState() => _SignupOTPState();
}

class _SignupOTPState extends State<SignupOTP> {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController otpCtr = TextEditingController();

  @override
  void dispose() {
    otpCtr.dispose();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s remaining';
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

  void _verify() {
    if (otpCtr.text.length != 6) {
      customSnackBar("Enter OTP".tr);
      return;
    }
    controller.verifyOtp(otpCtr.text, () {
      Navigator.of(context).pop("back");
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = WebAuthLayout.isWide(context);

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
                    "Enter verification code".tr,
                    style: TextStyle(
                      fontSize: wide ? 24 : 28,
                      fontWeight: FontWeight.w700,
                      color: MyColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "A code has been sent to".tr,
                    style: TextStyle(
                      fontSize: 15,
                      color: MyColors.black.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.emailID.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                  const SizedBox(height: 28),
                  PinCodeTextField(
                    enablePinAutofill: false,
                    controller: otpCtr,
                    enableActiveFill: true,
                    appContext: context,
                    length: 6,
                    keyboardType: TextInputType.number,
                    textStyle: TextStyle(
                      color: MyColors.black,
                      fontSize: 18,
                    ),
                    cursorColor: MyColors.primary,
                    pinTheme: PinTheme(
                      inactiveColor: Colors.grey,
                      inactiveFillColor: Colors.white,
                      selectedColor: MyColors.primary,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      activeColor: MyColors.primary,
                      fieldHeight: wide ? 50 : 45,
                      fieldWidth: wide ? 48 : 42,
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onChanged: (_) {},
                    onCompleted: (value) {
                      otpCtr.text = value;
                      _verify();
                    },
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final canResend = controller.remainingTime.value == 0;
                    return Center(
                      child: canResend
                          ? InkWell(
                              onTap: controller.otpLoader.value
                                  ? null
                                  : () => controller.signupOtp("resend", () {}),
                              child: controller.otpLoader.value
                                  ? myIndicator()
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "I didn't receive code? ".tr,
                                          style: const TextStyle(
                                            color: MyColors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          "Resend".tr,
                                          style: TextStyle(
                                            color: MyColors.buttonColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            )
                          : Text(
                              _formatTimer(controller.remainingTime.value),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (controller.otpVerify.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _verify,
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
                    );
                  }),
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
