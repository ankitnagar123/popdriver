import '../../../controller/profile_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/shared_preferences.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/web_auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({Key? key}) : super(key: key);

  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  static const String _defaultPlayStoreUrl =
      'https://play.google.com/store/apps/';

  String link = '';
  String Name = '';
  bool _loading = true;

  SecureStorageService secure = SecureStorageService();

  @override
  void initState() {
    super.initState();
    getData();
  }

  String _resolveInviteUrl() {
    final fromApi = MyColors.InviteUrl.trim();
    if (fromApi.isNotEmpty &&
        fromApi != 'null' &&
        fromApi.startsWith('http')) {
      return fromApi;
    }
    return _defaultPlayStoreUrl;
  }

  @override
  Widget build(BuildContext context) {
    final wide = WebAuthLayout.isWide(context);

    return Scaffold(
      backgroundColor: wide ? const Color(0xFFF8FAFA) : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: !wide,
        leading: wide
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
        backgroundColor: MyColors.primary,
        elevation: wide ? 0 : 4,
        title: wide
            ? Text(
                'Invite Friends'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/headLogo.png', height: 28),
                  Image.asset(
                    color: Colors.white,
                    'assets/images/stearing.png',
                    height: 37,
                  ),
                ],
              ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 24 : 16,
                  vertical: wide ? 28 : 16,
                ),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: wide ? 520 : double.infinity),
                  child: WebAuthLayout.formCard(
                    context: context,
                    padding: EdgeInsets.all(wide ? 28 : 20),
                    child: Column(
                      children: [
                        if (!wide)
                          Text(
                            'Invite Friends'.tr,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                        if (!wide) const SizedBox(height: 10),
                        _buildHeroSection(wide),
                        SizedBox(height: wide ? 28 : 40),
                        _buildInviteMessage(wide),
                        SizedBox(height: wide ? 20 : 24),
                        _buildReferralLink(wide),
                        SizedBox(height: wide ? 28 : 40),
                        _buildInviteButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeroSection(bool wide) {
    final size = wide ? 130.0 : 160.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: MyColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: MyColors.primary, width: 2),
      ),
      child: Center(
        child: Icon(Icons.group_add, size: 64, color: MyColors.primary),
      ),
    );
  }

  Widget _buildInviteMessage(bool wide) {
    return Column(
      children: [
        Text(
          'Share the Love ❤️',
          style: TextStyle(
            fontSize: wide ? 22 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Invite your friends by sharing your invite link'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: wide ? 14 : 16,
            color: Colors.grey[600],
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildReferralLink(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Your referral link:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  link.isEmpty ? _defaultPlayStoreUrl : link,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _copyToClipboard,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.copy, size: 20, color: MyColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInviteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.share, color: Colors.white, size: 25),
        label: Text(
          'Invite'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
      ),
    );
  }

  void onPressed() async {
    final url = link.isNotEmpty ? link : _resolveInviteUrl();
    final name = Name.trim().isEmpty ? 'POP Driver' : Name.trim();

    final message = '$name invites you to join POP Taxi!\n\n'
        'Download app: $url';

    await Share.share(message);
  }

  void _copyToClipboard() {
    final text = link.isEmpty ? _defaultPlayStoreUrl : link;
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      customSnackBar('Link copied to clipboard!');
    });
  }

  Future<void> getData() async {
    setState(() => _loading = true);
    try {
      Name = (await secure.readData(secure.user_name)) ?? '';

      // Ensure invite_url loaded from profile API.
      if (MyColors.InviteUrl.trim().isEmpty || MyColors.InviteUrl == 'null') {
        try {
          final profile = Get.isRegistered<ProfileController>()
              ? Get.find<ProfileController>()
              : Get.put(ProfileController());
          await profile.fetchDriverDetail();
        } catch (_) {
          /* keep fallbacks */
        }
      }

      // Show invite_url from API (or Play Store fallback).
      link = _resolveInviteUrl();
      MyColors.InviteUrl = link;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
