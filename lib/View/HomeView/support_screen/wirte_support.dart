import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/support_controller.dart';
import '../../../Model/fetchQueryModel.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/snackBar.dart';

class WriteSupport extends StatefulWidget {
  const WriteSupport({super.key});

  @override
  State<WriteSupport> createState() => _WriteSupportState();
}

class _WriteSupportState extends State<WriteSupport> {
  final SupportController controller = Get.put(SupportController());

  final TextEditingController emailCtr = TextEditingController();
  final TextEditingController subCtr = TextEditingController();
  final TextEditingController messageCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load past tickets without blocking the compose form.
    controller.fetchQuery('');
  }

  @override
  void dispose() {
    emailCtr.dispose();
    subCtr.dispose();
    messageCtr.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: MyColors.white),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF02B3BE),
                Color(0xFF019BA5),
                Color(0xFF017A82),
              ],
            ),
          ),
        ),
        title: Text(
          'Write Support'.tr,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildComposeCard(),
            const SizedBox(height: 20),
            _buildTicketsSection(),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildComposeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MyColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: MyColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Send us a message'.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _labeledField(
            label: 'Email Address'.tr,
            child: TextFormField(
              controller: emailCtr,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              decoration: _inputDecoration('your@email.com'),
            ),
          ),
          const SizedBox(height: 12),
          _labeledField(
            label: 'Subject Line*'.tr,
            child: TextFormField(
              controller: subCtr,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              decoration: _inputDecoration('Brief subject'),
            ),
          ),
          const SizedBox(height: 12),
          _labeledField(
            label: 'Message*'.tr,
            child: TextFormField(
              controller: messageCtr,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              decoration: _inputDecoration(
                'Write your message, feedback or enquiry'.tr,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Obx(() {
            final loading = controller.writeSupportLoader.value;
            return SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit'.tr,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTicketsSection() {
    return Obx(() {
      final loading = controller.fetchQueryLoader.value;
      final tickets = controller.fetchQueryList;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'My support tickets'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (loading)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MyColors.primary,
                  ),
                )
              else
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => controller.fetchQuery('refresh'),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  color: MyColors.primary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (!loading && tickets.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'No tickets yet. Submit a message above.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else
            ...tickets.reversed.map(_ticketCard),
        ],
      );
    });
  }

  Widget _ticketCard(FetchQueryModel data) {
    final isOpen = data.status.toLowerCase() == 'opened';
    final statusColor = isOpen ? Colors.green.shade700 : Colors.red.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(
            RouteHelper.getSingleQueryScreen(),
            arguments: {
              'status': data.status,
              'number': data.complainNumber,
            },
          ),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${data.complainNumber}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: MyColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  data.subject,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      data.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'View'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: MyColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 18, color: MyColors.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: MyColors.background,
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyColors.primary, width: 1.5),
      ),
    );
  }

  Future<void> _submit() async {
    _dismissKeyboard();

    if (emailCtr.text.trim().isEmpty) {
      customSnackBar('Please Enter Email Address'.tr);
      return;
    }
    if (!EmailValidator.validate(emailCtr.text.trim())) {
      customSnackBar('Enter Valid Email Address'.tr);
      return;
    }
    if (subCtr.text.trim().isEmpty) {
      customSnackBar('Please Write Subject'.tr);
      return;
    }
    if (messageCtr.text.trim().isEmpty) {
      customSnackBar('Please Write Your Message'.tr);
      return;
    }

    final ok = await controller.writeSupport(
      context,
      emailCtr.text.trim(),
      subCtr.text.trim(),
      messageCtr.text.trim(),
    );

    if (ok && mounted) {
      _dismissKeyboard();
      emailCtr.clear();
      subCtr.clear();
      messageCtr.clear();
    }
  }
}
