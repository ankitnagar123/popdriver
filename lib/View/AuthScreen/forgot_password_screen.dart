import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/snackBar.dart';
import '../../utils/text_field.dart';
import '../../utils/web_auth_layout.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailCtr = TextEditingController();
  final AuthController controller = Get.find<AuthController>();

  @override
  void dispose() {
    emailCtr.dispose();
    super.dispose();
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

  Widget _buildBackToLogin() {
    return Center(
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
    );
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
                    "Forgot Password".tr,
                    style: TextStyle(
                      fontSize: wide ? 24 : 28,
                      fontWeight: FontWeight.w700,
                      color: MyColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Please enter your registered email address to reset your password"
                        .tr,
                    style: TextStyle(
                      fontSize: 15,
                      color: MyColors.black.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  custom_textfield(
                    allowSpecialCharacters: true,
                    isEmail: true,
                    manditory: "*",
                    labletext: "Email Address".tr,
                    textInputType: TextInputType.emailAddress,
                    textEditingController: emailCtr,
                  ),
                  const SizedBox(height: 28),
                  Obx(() => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
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
                                color: MyColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            final email = emailCtr.text.trim();
                            if (email.isEmpty) {
                              customSnackBar("Please enter email address".tr);
                            } else {
                              controller.forgetPassword(email);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.forgetPasswordLoader.value
                              ? const SizedBox(
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
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                        ),
                      )),
                  const SizedBox(height: 8),
                  _buildBackToLogin(),
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
