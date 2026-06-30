// import '../../../utils/colors.dart';
// import '../../../utils/custom_button.dart';
// import '../../../utils/shared_preferences.dart';
// import '../../../utils/snackBar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:share_plus/share_plus.dart';
//
// class InviteFriendScreen extends StatefulWidget {
//   const InviteFriendScreen({Key? key}) : super(key: key);
//
//   @override
//   State<InviteFriendScreen> createState() => _InviteFriendScreenState();
// }
//
// class _InviteFriendScreenState extends State<InviteFriendScreen> {
//   String link = "";
//   String Name = "";
//   String InviteCode = "";
//
//   @override
//   void initState() {
//     super.initState();
//     getData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: GestureDetector(
//
//             onTap: () {
//               Get.back();
//             },
//             child: Icon(Icons.arrow_back_outlined,color: Colors.white,)),
//         backgroundColor: MyColors.primary,
//         title: Text("Invite Friends".tr,style: TextStyle(color: Colors.white,fontSize: 20),),
//         centerTitle: true,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: Container(
//               height: Get.height / 6,
//               width: Get.width / 2.6,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(80),
//                   color: MyColors.primary),
//               child: Center(
//                 child: Icon(
//                   Icons.group_add,
//                   color: MyColors.white,
//                   size: 50,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Text(
//             "Invite Friends".tr,
//             style: TextStyle(fontSize: 20),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Text("Invite your friends by sharing your invite link".tr),
//           SizedBox(
//             height: 10,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                   width: Get.width / 1.4,
//                   child: Text("$link",
//                       softWrap: false,
//                       maxLines: 1,
//                       overflow: TextOverflow.clip)),
//               InkWell(
//                   onTap: () {
//                     Clipboard.setData(ClipboardData(text: link)).then((value) {
//                       customSnackBar("Link Copied".tr);
//                     });
//                   },
//                   child: Icon(
//                     Icons.copy_rounded,
//                     color: MyColors.black,
//                   ))
//             ],
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: custom_buttons(voidCallback: onPressed, text: "Invite".tr),
//           )
//         ],
//       ),
//     );
//   }
//
//   void onPressed() async {
//     String message = "$Name" +
//         " " +
//         "invite You to join Mtaani  taxi".tr +
//         "\n\n${MyColors.InviteCode}\n\n\n ";
//
//
//     await Share.share("$message");
//   }
//
//   SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
//   SecureStorageService secure = SecureStorageService();
//
//   void getData() async {
//     Name = (await secure.readData(secure.user_name))??"";
//
//     link = "${MyColors.InviteCode}";
//     setState(() {
//
//     });
//   }
// }
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
  String link = "";
  String Name = "";
  String InviteCode = "";

  @override
  void initState() {
    super.initState();
    getData();
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
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 24 : 16,
            vertical: wide ? 28 : 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 520 : double.infinity),
            child: WebAuthLayout.formCard(
              context: context,
              padding: EdgeInsets.all(wide ? 28 : 20),
              child: Column(
                children: [
                  if (!wide)
                    Text(
                      'Invite Friends'.tr,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  if (!wide) const SizedBox(height: 10),
                  _buildHeroSection(wide),
                  SizedBox(height: wide ? 28 : 40),
                  _buildInviteMessage(wide),
                  SizedBox(height: wide ? 28 : 32),
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
        child: Icon(Icons.group_add,
            size: 64,
            color: MyColors.primary),
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
          'Invite your friends to join POP Taxi and earn rewards together!',
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
          padding: EdgeInsets.only(bottom: 8),
          child: Text("Your referral link:",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700])),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(link,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14)),
              ),
              SizedBox(width: 8),
              InkWell(
                onTap: _copyToClipboard,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.copy,
                      size: 20,
                      color: MyColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncentiveCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.stars, color: MyColors.primary, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Text("Earn \$10 for each friend who joins and completes their first ride!",
                style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.share, color: Colors.white,size: 25,),
        label: Text("Invite Friends".tr,
            style: TextStyle(
              color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.primary,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        onPressed: onPressed,
      ),
    );
  }

  void onPressed() async {
    String message = "$Name invites you to join Mtaani Taxi!\n\n"
        "Use my referral code: ${MyColors.InviteCode}\n\n"
        "Download app: ${MyColors.InviteUrl}";

    await Share.share(message);
    customSnackBar("Invite shared successfully!");
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: link)).then((_) {
      customSnackBar("Link copied to clipboard!");
    });
  }

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  SecureStorageService secure = SecureStorageService();

  void getData() async {
    Name = (await secure.readData(secure.user_name)) ?? "";
    link = MyColors.InviteCode;
    setState(() {});
  }
}