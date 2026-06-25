import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtaanidriver/controller/profile_controller.dart';

import '../../utils/colors.dart';
import '../../utils/snackBar.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final ProfileController profileController = Get.put(ProfileController());
  final _formKey = GlobalKey<FormState>();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool hasCurrentPassError = false;
  bool hasNewPassError = false;
  bool hasConfirmPassError = false;
  String currentPassError = '';
  String newPassError = '';
  String confirmPassError = '';

  final TextEditingController currentPassCtr = TextEditingController();
  final TextEditingController newPassCtr = TextEditingController();
  final TextEditingController reNewPassCtr = TextEditingController();

  @override
  void dispose() {
    currentPassCtr.dispose();
    newPassCtr.dispose();
    reNewPassCtr.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    profileController.changePassword(
      currentPassCtr.text,
      reNewPassCtr.text,
      () {
        currentPassCtr.clear();
        newPassCtr.clear();
        reNewPassCtr.clear();
        customSnackBar('Password changed successfully'.tr, context: context);
        Get.back();
      },
    );
  }

  bool _validateForm() {
    bool isValid = true;
    final newPassword = newPassCtr.text;
    final currentPassword = currentPassCtr.text;
    final confirmPassword = reNewPassCtr.text;

    setState(() {
      hasCurrentPassError = false;
      hasNewPassError = false;
      hasConfirmPassError = false;
      currentPassError = '';
      newPassError = '';
      confirmPassError = '';
    });

    if (currentPassword.isEmpty) {
      setState(() {
        hasCurrentPassError = true;
        currentPassError = 'Please enter current password'.tr;
      });
      isValid = false;
    }

    if (newPassword.isEmpty) {
      setState(() {
        hasNewPassError = true;
        newPassError = 'Please enter new password'.tr;
      });
      isValid = false;
    } else if (newPassword == currentPassword) {
      setState(() {
        hasNewPassError = true;
        newPassError = 'New password must be different from current password'.tr;
      });
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        hasConfirmPassError = true;
        confirmPassError = 'Please confirm new password'.tr;
      });
      isValid = false;
    } else if (confirmPassword != newPassword) {
      setState(() {
        hasConfirmPassError = true;
        confirmPassError = 'Passwords do not match'.tr;
      });
      isValid = false;
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: MyColors.primary),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MyColors.primary.withOpacity(0.15),
                        MyColors.primary.withOpacity(0.05),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.primary.withOpacity(0.18),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    size: 42,
                    color: MyColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Change Password'.tr,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: MyColors.primary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Update your password to keep your account secure'.tr,
                style: TextStyle(
                  fontSize: 15,
                  color: MyColors.DarkBlue.withOpacity(0.85),
                  height: 1.5,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: MyColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: MyColors.TextField),
                ),
                child: Column(
                  children: [
                    CustomPasswordField(
                      controller: currentPassCtr,
                      labelText: 'Current Password'.tr,
                      hasError: hasCurrentPassError,
                      errorText: currentPassError,
                      obscureText: _obscureCurrent,
                      onToggleVisibility: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                      onChanged: (_) =>
                          setState(() => hasCurrentPassError = false),
                    ),
                    const SizedBox(height: 16),
                    CustomPasswordField(
                      controller: newPassCtr,
                      labelText: 'New Password'.tr,
                      hasError: hasNewPassError,
                      errorText: newPassError,
                      obscureText: _obscureNew,
                      onToggleVisibility: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      onChanged: (_) => setState(() => hasNewPassError = false),
                    ),
                    const SizedBox(height: 16),
                    CustomPasswordField(
                      controller: reNewPassCtr,
                      labelText: 'Re- enter New Password'.tr,
                      hasError: hasConfirmPassError,
                      errorText: confirmPassError,
                      obscureText: _obscureConfirm,
                      onToggleVisibility: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      onChanged: (_) =>
                          setState(() => hasConfirmPassError = false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSecurityTips(),
              const SizedBox(height: 28),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MyColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MyColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 18, color: MyColors.primary),
              const SizedBox(width: 8),
              Text(
                'Password Tips'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MyColors.primary,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _tipRow('Use a strong and unique password'.tr),
          _tipRow('Do not reuse your old password'.tr),
          _tipRow('Keep your password private'.tr),
        ],
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              height: 5,
              width: 5,
              decoration: BoxDecoration(
                color: MyColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: MyColors.DarkBlue.withOpacity(0.9),
                height: 1.4,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final isLoading = profileController.changePasswordLoader.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              MyColors.primary,
              MyColors.DarkBlue,
            ],
          ),
          boxShadow: [
            if (!isLoading)
              BoxShadow(
                color: MyColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  if (_validateForm()) {
                    _onPasswordChanged();
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: Size(double.infinity, 0),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Change Password'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

class CustomPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool hasError;
  final String errorText;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String>? onChanged;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hasError = false,
    this.errorText = '',
    this.obscureText = true,
    required this.onToggleVisibility,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              labelText,
              style: TextStyle(
                color: hasError ? Colors.red : MyColors.DarkBlue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: MyColors.TextField,
            border: Border.all(
              color: hasError ? Colors.red : MyColors.TextField,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            enableInteractiveSelection: false,
            toolbarOptions: const ToolbarOptions(
              copy: true,
              cut: true,
              paste: false,
              selectAll: false,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]'),
              ),
            ],
            onChanged: onChanged,
            style: TextStyle(
              color: MyColors.DarkBlue,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              hintText: labelText,
              hintStyle: TextStyle(
                color: hasError
                    ? Colors.red.withOpacity(0.7)
                    : MyColors.DarkBlue.withOpacity(0.55),
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: hasError ? Colors.red : MyColors.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  size: 20,
                  obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: MyColors.DarkBlue,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
        if (hasError && errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      height: 1.4,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
