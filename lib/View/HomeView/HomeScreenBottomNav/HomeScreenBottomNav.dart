import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:mtaanidriver/utils/colors.dart';
import 'package:mtaanidriver/utils/web_auth_layout.dart';
import 'package:mtaanidriver/utils/web_driver_layout.dart';
import 'package:mtaanidriver/widgets/web_driver_sidebar.dart';

import '../../../controller/route_controller.dart';
import '../../AuthScreen/ChangePassword.dart';
import '../Menu_bar/menu_bar_screen.dart';
import '../drawer_tab_screen/invite_friend_screen.dart';
import '../drawer_tab_screen/notification_screen.dart';
import '../drawer_tab_screen/rating_screen.dart';
import '../drawer_tab_screen/ride_history/ride_history.dart';
import '../home_screen.dart';
import '../profile_screens/profile.dart';
import '../support_screen/support_sceen.dart';
import '../wallet_screen/wallet_screen.dart';


class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {


  RouteController routeController = Get.put(RouteController());

  final List<Widget> _mobilePages = [
    const HomeScreen(),
    const RideHistory(),
    const NotificationScreen(),
    MtaaniSidebar(),
  ];

  final List<Widget> _webPages = [
    const HomeScreen(),
    const RideHistory(),
    const WalletScreen(),
    const NotificationScreen(),
    const RatingScreen(),
    const Support(),
    const ProfileScreen(),
    const InviteFriendScreen(),
    const ChangePassword(),
  ];

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => WebAuthLayout.dialog(
        context: context,
        maxWidth: 400,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  Icon(Icons.exit_to_app_sharp, color: MyColors.primary, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Exit App',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Do you want to exit the app?',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 15),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primary,
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop(); // Exit the app
    }

    return Future.value(false); // Prevent default pop behavior unless 'Yes' was pressed
  }
  @override
  Widget build(BuildContext context) {
    if (WebDriverLayout.isWidePanel(context)) {
      return _buildWebShell(context);
    }
    return _buildMobileShell(context);
  }

  Widget _buildWebShell(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (routeController.pageIndex.value != 0) {
            routeController.pageIndex.value = 0;
          } else {
            await _onWillPop();
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7F7),
          body: Row(
            children: [
              WebDriverSidebar(
                selectedIndex: routeController.pageIndex.value,
                onSelected: (i) => routeController.pageIndex.value = i,
              ),
              Expanded(
                child: ClipRect(
                  child: _webPages[routeController.pageIndex.value.clamp(
                    0,
                    _webPages.length - 1,
                  )],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMobileShell(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
        if (routeController.pageIndex.value != 0) {
          routeController.pageIndex.value = 0;
        } else {
          await _onWillPop(); // Only show dialog if already at pageIndex 0
        }

        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          floatingActionButton: GestureDetector(

            onTap: () {
              HapticFeedback.heavyImpact(); // <-- VIBRATE HERE

              routeController.pageIndex.value = 0;
            },
            child: Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.5), // Shadow color with some transparency
                    spreadRadius: 2,                    // How much the shadow spreads
                    blurRadius: 6,                      // How soft the shadow is
                    offset: Offset(2, 3),               // X and Y offset
                  ),                ],
                border: Border.all(color: Colors.cyan.shade50,width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(30)),
                gradient: RadialGradient(
                    colors: [
                      MyColors.primary.withOpacity(0.9),
                  MyColors.primary,
                    ]),
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/trip.png",
                  fit: BoxFit.contain,
                  color: Colors.white,
                  height: 28,
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: Obx(() {
            return BottomAppBar(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              height: 60,
              color: Colors.transparent,
              shape: CircularNotchedRectangle(),
              notchMargin: 5,
              child: Container(
                decoration:  BoxDecoration(
                  color: MyColors.primary,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.white70,
                        blurRadius: 5
                    )
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        style: ButtonStyle(
                            shape: WidgetStatePropertyAll(CircleBorder(side: BorderSide(color:routeController.pageIndex.value == 0? Colors.white70:Colors.transparent)))
                        ),
                        icon: Icon(
                          Icons.home,
                          size: 25,
                          color: routeController.pageIndex.value == 0
                              ? Colors.white
                              : Colors.white70,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact(); // <-- VIBRATE HERE
                          routeController.pageIndex.value = 0;
                        },
                      ),
                      IconButton(
                        style: ButtonStyle(
                            shape: WidgetStatePropertyAll(CircleBorder(side: BorderSide(color:routeController.pageIndex.value == 1? Colors.white70:Colors.transparent)))
                        ),
                        icon: Icon(Icons.work_history_outlined,
                          size: 25,
                          color: routeController.pageIndex.value == 1
                              ? Colors.white
                              : Colors.white70,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact(); // <-- VIBRATE HERE

                          routeController.pageIndex.value = 1;
                        },
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      IconButton(
                        style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              
                                CircleBorder(side: BorderSide(color:routeController.pageIndex.value == 2? Colors.white70:Colors.transparent)))
                        ),
                        icon: Icon(
                          Icons.notifications_outlined,
                          size: 25,
                          color: routeController.pageIndex.value == 2
                              ? Colors.white
                              : Colors.white70,
                        ),

                        onPressed: () {
                          HapticFeedback.lightImpact(); // <-- VIBRATE HERE

                          routeController.pageIndex.value = 2;
                        },
                      ),
                      IconButton(
                        style: ButtonStyle(
                            shape: WidgetStatePropertyAll(CircleBorder(side: BorderSide(color:routeController.pageIndex.value == 3? Colors.white70:Colors.transparent)))
                        ),
                        icon: Icon(Icons.list_alt,
                          size: 25,
                          color: routeController.pageIndex.value == 3
                              ? Colors.white
                              : Colors.white70,),
                        onPressed: () {
                          HapticFeedback.lightImpact(); // <-- VIBRATE HERE

                          routeController.pageIndex.value = 3;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          body: _mobilePages[routeController.pageIndex.value.clamp(
            0,
            _mobilePages.length - 1,
          )],
        ),
      );
    });
  }
}