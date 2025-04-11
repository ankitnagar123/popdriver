import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/shared_preferences.dart';
import '../../../utils/snackBar.dart';
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
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(

            onTap: () {
              Get.back();
            },
            child: Icon(Icons.arrow_back_outlined,color: Colors.white,)),
        backgroundColor: MyColors.primary,
        title: Text("Invite Friends".tr,style: TextStyle(color: Colors.white,fontSize: 20),),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: Get.height / 6,
              width: Get.width / 2.6,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: MyColors.primary),
              child: Center(
                child: Icon(
                  Icons.group_add,
                  color: MyColors.white,
                  size: 50,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Invite Friends".tr,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 10,
          ),
          Text("Invite your friends by sharing your invite link".tr),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: Get.width / 1.4,
                  child: Text("$link",
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.clip)),
              InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: link)).then((value) {
                      customSnackBar("Link Copied".tr);
                    });
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    color: MyColors.black,
                  ))
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: custom_buttons(voidCallback: onPressed, text: "Invite".tr),
          )
        ],
      ),
    );
  }

  void onPressed() async {
    String message = "$Name" +
        " " +
        "invite You to join Mtaani  taxi".tr +
        "\n\n${MyColors.InviteCode}\n\n\n ";


    await Share.share("$message");
  }

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  SecureStorageService secure = SecureStorageService();

  void getData() async {
    Name = (await secure.readData(secure.user_name))??"";

    link = "${MyColors.InviteCode}";
    setState(() {

    });
  }
}
