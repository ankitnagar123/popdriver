import '../../utils/colors.dart';
import '../../utils/text_field.dart';
import '../../controller/auth_controller.dart';
import '../../utils/snackBar.dart';
import '../../utils/web_auth_layout.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetPassword extends StatefulWidget {
  const SetPassword({Key? key}) : super(key: key);

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  final TextEditingController passCtr = TextEditingController();
  final TextEditingController rePassCtr = TextEditingController();
  final AuthController controller = Get.find<AuthController>();

  String id = "";
  bool isHide = true;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    id = Get.arguments?["id"]?.toString() ?? '';
  }

  @override
  void dispose() {
    passCtr.dispose();
    rePassCtr.dispose();
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

  Widget _eyeIcon(bool hidden, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        hidden ? Icons.visibility_off : Icons.visibility,
        color: MyColors.DarkBlue,
      ),
    );
  }

  bool valid() {
    if (passCtr.text.isEmpty) {
      customSnackBar("Please enter New Password".tr);
    } else if (rePassCtr.text.isEmpty) {
      customSnackBar("Please Re-enter Password".tr);
    } else if (passCtr.text != rePassCtr.text) {
      customSnackBar("Password Does Not Match".tr);
    } else {
      return true;
    }
    return false;
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
                    "Set New Password".tr,
                    style: TextStyle(
                      fontSize: wide ? 24 : 28,
                      fontWeight: FontWeight.w700,
                      color: MyColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Enter new password. Password must be 5 to 10 characters long"
                        .tr,
                    style: TextStyle(
                      fontSize: 15,
                      color: MyColors.black.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  custom_textfield(
                    allowSpecialCharacters: false,
                    labletext: "Create New Password".tr,
                    textEditingController: passCtr,
                    ishide: isHide,
                    textInputType: TextInputType.text,
                    icon: _eyeIcon(isHide, () {
                      setState(() => isHide = !isHide);
                    }),
                  ),
                  custom_textfield(
                    allowSpecialCharacters: false,
                    labletext: "Re-enter Password".tr,
                    textEditingController: rePassCtr,
                    ishide: isVisible,
                    textInputType: TextInputType.text,
                    icon: _eyeIcon(isVisible, () {
                      setState(() => isVisible = !isVisible);
                    }),
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
                            if (!controller.setPasswordLoader.value)
                              BoxShadow(
                                color: MyColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (valid()) {
                              controller.setPassword(
                                passCtr.text,
                                id.toString(),
                              );
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
                          child: controller.setPasswordLoader.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Continue".tr,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      )),
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
