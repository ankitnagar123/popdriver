import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/booking_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/web_auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class StartRideOtp extends StatefulWidget {
  const StartRideOtp({Key? key}) : super(key: key);

  @override
  State<StartRideOtp> createState() => _StartRideOtpState();
}

class _StartRideOtpState extends State<StartRideOtp> {
  final BookingController controller = Get.find<BookingController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController otpCtr = TextEditingController();

  late final String id;

  @override
  void initState() {
    super.initState();
    id = Get.arguments?['id']?.toString() ?? '';
  }

  @override
  void dispose() {
    otpCtr.dispose();
    super.dispose();
  }

  void _submitOtp() {
    final otp = otpCtr.text.trim();
    if (otp.length != 6) {
      customSnackBar("Enter OTP".tr);
      return;
    }

    authController.verifyOtp2(otp, id, () {
      controller.statusChange("start_ride", id, "", "", () {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  Widget _buildPinField(BuildContext context) {
    final wide = WebAuthLayout.isWide(context);
    return PinCodeTextField(
      controller: otpCtr,
      appContext: context,
      length: 6,
      autoFocus: true,
      enableActiveFill: true,
      enablePinAutofill: false,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textStyle: TextStyle(
        color: MyColors.black,
        fontSize: wide ? 20 : 18,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: MyColors.primary,
      pinTheme: PinTheme(
        inactiveColor: Colors.grey.shade300,
        inactiveFillColor: Colors.white,
        selectedColor: MyColors.primary,
        activeColor: MyColors.primary,
        activeFillColor: Colors.white,
        selectedFillColor: Colors.white,
        fieldHeight: wide ? 52 : 46,
        fieldWidth: wide ? 46 : 42,
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(10),
      ),
      onChanged: (_) => setState(() {}),
      onCompleted: (_) => _submitOtp(),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final loading =
          controller.statusChangeLoader.value || authController.otpVerify2.value;
      if (loading) {
        return Center(child: myIndicator());
      }

      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: MyColors.orange,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            onTap: _submitOtp,
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 52,
              width: 52,
              child: Icon(Icons.arrow_forward, color: MyColors.white),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBody(BuildContext context) {
    final wide = WebAuthLayout.isWide(context);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Image.asset(
            "assets/images/logo.png",
            height: WebAuthLayout.logoHeight(context),
          ),
        ),
        SizedBox(height: wide ? 28 : 36),
        Text(
          "Enter The OTP To Start Ride".tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MyColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: wide ? 18 : 16,
          ),
        ),
        const SizedBox(height: 28),
        _buildPinField(context),
        SizedBox(height: wide ? 36 : 44),
        _buildSubmitButton(),
      ],
    );

    if (wide) {
      return WebAuthLayout.formCard(
        context: context,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebAuthLayout.page(
      context: context,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.white,
        leading: InkWell(
          onTap: Get.back,
          child: Icon(Icons.arrow_back, color: MyColors.black),
        ),
        title: Image.asset("assets/images/logo.png", height: 50),
        centerTitle: true,
      ),
      child: _buildBody(context),
    );
  }
}
