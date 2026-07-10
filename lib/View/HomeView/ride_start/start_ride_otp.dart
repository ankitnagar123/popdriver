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

  static const int _otpLength = 6;
  late final List<TextEditingController> _digitCtrs;
  late final List<FocusNode> _focusNodes;
  late final String id;

  @override
  void initState() {
    super.initState();
    id = Get.arguments?['id']?.toString() ?? '';
    _digitCtrs = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _digitCtrs) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _digitCtrs.map((c) => c.text).join();

  void _submitOtp() {
    final otp = _otp.trim();
    if (otp.length != _otpLength) {
      customSnackBar("Enter OTP".tr);
      return;
    }

    authController.verifyOtp2(otp, id, () {
      controller.statusChange("start_ride", id, "", "", () {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  void _onDigitChanged(int index, String value) {
    // Paste / autofill often dumps multiple digits into one box.
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _digitCtrs[index].clear();
      setState(() {});
      return;
    }

    if (digits.length > 1) {
      _applyPastedDigits(index, digits);
      return;
    }

    _digitCtrs[index].text = digits;
    _digitCtrs[index].selection = TextSelection.collapsed(offset: 1);

    if (index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
      // Select existing digit so next keypress replaces it.
      final next = _digitCtrs[index + 1];
      if (next.text.isNotEmpty) {
        next.selection = TextSelection(baseOffset: 0, extentOffset: next.text.length);
      }
    } else {
      _focusNodes[index].unfocus();
      if (_otp.length == _otpLength) _submitOtp();
    }
    setState(() {});
  }

  void _applyPastedDigits(int startIndex, String digits) {
    var i = startIndex;
    for (final ch in digits.split('')) {
      if (i >= _otpLength) break;
      _digitCtrs[i].text = ch;
      i++;
    }
    final focusAt = i < _otpLength ? i : _otpLength - 1;
    _focusNodes[focusAt].requestFocus();
    if (_otp.length == _otpLength) {
      _focusNodes[focusAt].unfocus();
      _submitOtp();
    }
    setState(() {});
  }

  void _handleBackspace(int index) {
    if (_digitCtrs[index].text.isNotEmpty) {
      _digitCtrs[index].clear();
      setState(() {});
      return;
    }
    if (index > 0) {
      _digitCtrs[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  Widget _buildPinField(BuildContext context) {
    final wide = WebAuthLayout.isWide(context);
    final boxH = wide ? 52.0 : 46.0;
    final boxW = wide ? 46.0 : 42.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        return SizedBox(
          height: boxH,
          width: boxW,
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;
              if (event.logicalKey == LogicalKeyboardKey.backspace) {
                // Empty box: move to previous and clear.
                if (_digitCtrs[index].text.isEmpty && index > 0) {
                  _handleBackspace(index);
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: _digitCtrs[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: index == _otpLength - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              // Allow temporary multi-digit (paste); we normalize in onChanged.
              style: TextStyle(
                color: MyColors.black,
                fontSize: wide ? 20 : 18,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: MyColors.primary,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: _digitCtrs[index].text.isNotEmpty
                        ? MyColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: MyColors.primary, width: 1.6),
                ),
              ),
              onTap: () {
                // Tap any box → focus that digit & select it for replace-edit.
                _focusNodes[index].requestFocus();
                final t = _digitCtrs[index];
                if (t.text.isNotEmpty) {
                  t.selection =
                      TextSelection(baseOffset: 0, extentOffset: t.text.length);
                }
              },
              onChanged: (value) => _onDigitChanged(index, value),
              onSubmitted: (_) {
                if (_otp.length == _otpLength) _submitOtp();
              },
            ),
          ),
        );
      }),
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
