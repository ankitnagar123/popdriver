import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/web_auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordChangeSuccess extends StatefulWidget {
  const PasswordChangeSuccess({Key? key}) : super(key: key);

  @override
  State<PasswordChangeSuccess> createState() => _PasswordChangeSuccessState();
}

class _PasswordChangeSuccessState extends State<PasswordChangeSuccess> {
  @override
  Widget build(BuildContext context) {
    final wide = WebAuthLayout.isWide(context);

    return WebAuthLayout.page(
      context: context,
      child: Column(
        children: [
          SizedBox(height: wide ? 24 : 40),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: wide ? 420 : double.infinity,
              maxHeight: wide ? 360 : MediaQuery.sizeOf(context).height * 0.55,
            ),
            child: Image.asset(
              "assets/images/changePass.png",
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
          SizedBox(height: wide ? 28 : 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 0 : 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  Text(
                    "Password changed successfully".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: wide ? 22 : 20,
                      fontWeight: FontWeight.w700,
                      color: MyColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "You can now log in with your new password.".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: MyColors.black.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offNamed(RouteHelper.getLoginScreenRoute());
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: MyColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Go to Login'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
