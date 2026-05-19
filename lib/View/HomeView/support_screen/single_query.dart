import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Model/fetch_single_query.dart';
import '../../../controller/support_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/snackBar.dart';

class FetchSingleQuery extends StatefulWidget {
  const FetchSingleQuery({super.key});

  @override
  State<FetchSingleQuery> createState() => _FetchSingleQueryState();
}

class _FetchSingleQueryState extends State<FetchSingleQuery> {
  final SupportController controller = Get.put(SupportController());
  final TextEditingController messageCtr = TextEditingController();

  late String status;
  late String complainNumber;
  Timer? _pollTimer;
  bool _initialLoadDone = false;

  bool get _isOpen => status.toLowerCase() == 'opened';

  @override
  void initState() {
    super.initState();
    complainNumber = Get.arguments['number']?.toString() ?? '';
    status = Get.arguments['status']?.toString() ?? '';
    _loadThread();

    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      controller.fetchSingleQuery(complainNumber, 'poll');
    });
  }

  Future<void> _loadThread() async {
    await controller.fetchSingleQuery(complainNumber, '');
    if (mounted) setState(() => _initialLoadDone = true);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
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
          title: Column(
            children: [
              Text(
                'Ticket #$complainNumber',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          final loading =
              controller.fetchSingleQueryLoader.value && !_initialLoadDone;
          final messages = controller.fetchSingleQueryList;

          if (loading) {
            return const Center(
              child: CircularProgressIndicator(color: MyColors.primary),
            );
          }

          if (messages.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(child: _buildMessageList(messages)),
              if (_isOpen) _buildActionBar(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No messages yet'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Support will reply here soon.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<FetchSingleQueryModel> messages) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return _messageBubble(msg);
      },
    );
  }

  Widget _messageBubble(FetchSingleQueryModel msg) {
    final isDriver = msg.role.toLowerCase() == 'customer';
    final bubbleColor = isDriver ? MyColors.primary : Colors.grey.shade200;
    final textColor = isDriver ? Colors.white : MyColors.black;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isDriver ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isDriver) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: MyColors.primary.withValues(alpha: 0.15),
              child: const Icon(Icons.support_agent,
                  size: 16, color: MyColors.primary),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isDriver ? 14 : 4),
                  bottomRight: Radius.circular(isDriver ? 4 : 14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.message,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  if (msg.time.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      msg.time,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDriver
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isDriver) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 14,
              backgroundColor: MyColors.primary.withValues(alpha: 0.15),
              child: const Icon(Icons.person, size: 16, color: MyColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.closeQueryLoader.value
                  ? null
                  : () => _confirmCloseTicket(),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text('Close Ticket'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showReplySheet(),
              icon: const Icon(Icons.reply_rounded, size: 18),
              label: Text('Reply'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReplySheet() {
    _dismissKeyboard();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Reply to support'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageCtr,
                maxLines: 4,
                autofocus: true,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Type your message...'.tr,
                  filled: true,
                  fillColor: MyColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: MyColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final loading = controller.replyLoader.value;
                return SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: loading ? null : () => _sendReply(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
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
                            'Send'.tr,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendReply(BuildContext sheetContext) async {
    if (messageCtr.text.trim().isEmpty) {
      customSnackBar('please write your message'.tr);
      return;
    }
    _dismissKeyboard();
    final ok =
        await controller.replyThread(complainNumber, messageCtr.text.trim());
    if (!sheetContext.mounted) return;
    if (ok) {
      messageCtr.clear();
      Navigator.pop(sheetContext);
    }
  }

  void _confirmCloseTicket() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Close ticket?'.tr,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 16)),
        content: Text(
          'This ticket will be marked as closed. You can open a new one if needed.'
              .tr,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'.tr),
          ),
          Obx(() {
            if (controller.closeQueryLoader.value) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                controller.closeTicket(complainNumber);
              },
              child: Text('Close'.tr,
                  style: TextStyle(color: Colors.red.shade600)),
            );
          }),
        ],
      ),
    );
  }
}
