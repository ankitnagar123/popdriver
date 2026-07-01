import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mtaanidriver/View/HomeView/drawer_tab_screen/invite_friend_screen.dart';
import 'package:mtaanidriver/View/HomeView/drawer_tab_screen/notification_screen.dart';
import 'package:mtaanidriver/View/HomeView/drawer_tab_screen/rating_screen.dart';
import 'package:mtaanidriver/View/HomeView/drawer_tab_screen/ride_history/ride_history.dart';
import 'package:mtaanidriver/View/HomeView/membership_view/membership_screen.dart';
import 'package:mtaanidriver/View/HomeView/profile_screens/edit_profile_screen.dart';
import 'package:mtaanidriver/View/HomeView/support_screen/support_sceen.dart';
import 'package:mtaanidriver/View/HomeView/wallet_screen/wallet_screen.dart';
import 'package:mtaanidriver/utils/colors.dart';

import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/driver_menu_actions.dart';
import '../../../utils/shared_preferences.dart';
import '../../AuthScreen/ChangePassword.dart';
import '../drawer_tab_screen/my_ride_screen.dart';
import '../profile_screens/profile.dart';

class MtaaniSidebar extends StatefulWidget {
  @override
  State<MtaaniSidebar> createState() => _MtaaniSidebarState();
}

class _MtaaniSidebarState extends State<MtaaniSidebar> {
  final List<_MenuItem> menuItems = [
    _MenuItem('PROFILE', Icons.person_outline, const ProfileScreen()),
    _MenuItem('RIDE HISTORY', Icons.history, RideHistory()),
    _MenuItem('NOTIFICATION', Icons.notifications, NotificationScreen()),
    _MenuItem('RATE & REVIEW', Icons.rate_review, RatingScreen()),
    _MenuItem('INVITE FRIENDS', Icons.share, InviteFriendScreen()),
    _MenuItem('SUPPORT', Icons.support_agent, Support()),
    _MenuItem('CHANGE PASSWORD', Icons.lock, ChangePassword()),
    _MenuItem('DELETE ACCOUNT', Icons.delete_forever_outlined, SizedBox()),
    _MenuItem('SIGN OUT', Icons.logout, SizedBox()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 25),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return GestureDetector(
                    onTap: () {
                      if (item.title == 'SIGN OUT') {
                        DriverMenuActions.showLogoutDialog(context);
                      } else if (item.title == 'DELETE ACCOUNT') {
                        DriverMenuActions.showDeleteAccountDialog(context);
                      } else {
                        Get.to(() => item.screen,
                            transition: Transition.rightToLeft,
                            duration: Duration(milliseconds: 500));
                        // existing logic
                      }
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: MyColors.primary),
                              borderRadius: BorderRadius.circular(30)),
                          child: ListTile(
                            visualDensity: VisualDensity.comfortable,
                            contentPadding: EdgeInsets.all(0),
                            leading: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor:
                                      MyColors.primary.withOpacity(0.1),
                                  child: Icon(
                                    item.icon,
                                    color: MyColors.primary,
                                    size: 25,
                                  )),
                            ),
                            title: Text(item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                          ),
                        )),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

AppBar customAppBar() {
  return AppBar(
    backgroundColor: MyColors.black,
    centerTitle: true,
    automaticallyImplyLeading: false,
    leading: Get.arguments == "Home"
        ? GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.close,
              color: Colors.white,
            ))
        : null,
    title: Row(
      children: [
        Get.arguments == "Home"
            ? SizedBox()
            : SizedBox(
                width: 40,
              ),
        Image.asset(
          'assets/images/headLogo.png',
          height: Get.arguments == "Home" ? 25 : 30,
        ),
        Image.asset(
          'assets/images/stearing.png',
          height: 29,
          color: Colors.white,
        ),
      ],
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(30),
      ),
    ),
/*    leading: InkWell(
      onTap: () {},
      child: const Icon(
        Icons.subject,
        color: Colors.white,
      ),
    ),*/
    actions: [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/loader.gif',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              image: MyColors.image,
              imageErrorBuilder: (c, o, s) => Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ],
    bottom: PreferredSize(
        preferredSize: const Size.fromHeight(110.0),
        child: Container(
          padding: const EdgeInsets.only(left: 30, bottom: 20),
          child: Row(
            children: [
              Container(
                height: Get.height / 10,
                width: Get.width / 4,
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(100),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/loader.gif',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    image: MyColors.image,
                    imageErrorBuilder: (c, o, s) => Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => EditProfile());
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MyColors.name,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      MyColors.phone == ""
                          ? SizedBox()
                          : Text(
                              MyColors.phone,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                      // Text(
                      //   'Invite Code :${MyColors.InviteCode}',
                      //   style: TextStyle(
                      //     fontSize: 13,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      /*  Text(
                        'Wallet : AUD ${MyColors.walletAmount}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),*/
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                    onTap: () {
                      Get.to(() => EditProfile());
                    },
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    )),
              )
            ],
          ),
        )),
  );
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Widget screen;

  _MenuItem(this.title, this.icon, this.screen);
}
