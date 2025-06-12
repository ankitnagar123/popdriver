import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtaanidriver/controller/profile_controller.dart';

import '../../../utils/colors.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  ProfileController profileController = ProfileController();

  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Error states
  bool hasCurrentPassError = false;
  bool hasNewPassError = false;
  bool hasConfirmPassError = false;
  String currentPassError = '';
  String newPassError = '';
  String confirmPassError = '';

  // Controllers
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

  void _changePassword() {
    currentPassCtr.clear();
    newPassCtr.clear();
    reNewPassCtr.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully')),
    );
  }

  bool _validateForm() {
    bool isValid = true;
    final newPassword = newPassCtr.text;
    final currentPassword = currentPassCtr.text;
    final confirmPassword = reNewPassCtr.text;

    // Current Password Validation
    if (currentPassword.isEmpty) {
      setState(() {
        hasCurrentPassError = true;
        currentPassError = 'Please enter current password';
      });
      isValid = false;
    }

    // New Password Validation
    if (newPassword.isEmpty) {
      setState(() {
        hasNewPassError = true;
        newPassError = 'Please enter new password';
      });
      isValid = false;
    } else if (!_isValidPassword(newPassword)) {
      setState(() {
        hasNewPassError = true;
        newPassError =
        'Password must contain:\n- 8+ characters\n- 1 uppercase & lowercase\n- 1 number\n- 1 special character';
      });
      isValid = false;
    }

    // Confirm Password Validation
    if (confirmPassword.isEmpty) {
      setState(() {
        hasConfirmPassError = true;
        confirmPassError = 'Please confirm new password';
      });
      isValid = false;
    } else if (confirmPassword != newPassword) {
      setState(() {
        hasConfirmPassError = true;
        confirmPassError = 'Passwords do not match';
      });
      isValid = false;
    }

    return isValid;
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Change Password'.tr, style: TextStyle(fontSize: 18),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPasswordFields(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        CustomPasswordField(
          controller: currentPassCtr,
          labelText: "Current Password".tr,
          hasError: hasCurrentPassError,
          errorText: currentPassError,
          obscureText: _obscureCurrent,
          onToggleVisibility: () =>
              setState(() => _obscureCurrent = !_obscureCurrent),
          onChanged: (_) => setState(() => hasCurrentPassError = false),
        ),
        const SizedBox(height: 15),
        CustomPasswordField(
          controller: newPassCtr,
          labelText: "New Password".tr,
          hasError: hasNewPassError,
          errorText: newPassError,
          obscureText: _obscureNew,
          onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
          onChanged: (_) => setState(() => hasNewPassError = false),
        ),
        const SizedBox(height: 15),
        CustomPasswordField(
          controller: reNewPassCtr,
          labelText: "Confirm New Password".tr,
          hasError: hasConfirmPassError,
          errorText: confirmPassError,
          obscureText: _obscureConfirm,
          onToggleVisibility: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          onChanged: (_) => setState(() => hasConfirmPassError = false),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      if(profileController.changePasswordLoader.value){
        return Center(child: CupertinoActivityIndicator(radius: 15,));
      }else{
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.DarkBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (_validateForm()) {
                profileController.changePassword(currentPassCtr.text,reNewPassCtr.text,() {
                  _changePassword();

                },);

              }
            },
            child: Text(
              "Change Password".tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }

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
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: MyColors.TextField,
            border: Border.all(
              color: hasError ? Colors.red : MyColors.TextField,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
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
                        RegExp(r'[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]')),
                  ],
                  onChanged: onChanged,
                  decoration: InputDecoration(

                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    hintText: labelText,
                    hintStyle: TextStyle(
                      color: hasError ? Colors.red : MyColors.DarkBlue,
                      fontSize: 13,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        size: 20,
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: MyColors.DarkBlue,
                      ),
                      onPressed: onToggleVisibility,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError && errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}