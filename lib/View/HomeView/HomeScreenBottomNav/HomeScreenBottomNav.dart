import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:mtaanidriver/utils/colors.dart';

import '../../../controller/route_controller.dart';
import '../drawer_tab_screen/my_ride_screen.dart';
import '../drawer_tab_screen/ride_history/ride_history.dart';
import '../home_screen.dart';
import '../profile_screens/profile.dart';
import '../wallet_screen/wallet_screen.dart';


class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {


  RouteController routeController = Get.put(RouteController());
  final List<Widget> _pages = [
    const HomeScreen(),
    const MyRideScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade800),
        ),
        title: Row(
          children: const [
            Icon(Icons.exit_to_app_sharp, color: Colors.white, size: 30),
            SizedBox(width: 10),
            Text("Exit App", style: TextStyle(fontFamily: "Poppins", color: Colors.white,fontSize: 20)),
          ],
        ),
        content: const Text(
          "Do you want to exit the app?",
          style: TextStyle(fontFamily: "Poppins", fontSize: 15,color: MyColors.white),
        ),
        actions: [
          ElevatedButton(

            onPressed: () => Navigator.of(context).pop(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "No",
              style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true to proceed with exit
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop(); // Exit the app
    }

    return Future.value(false); // Prevent default pop behavior unless 'Yes' was pressed
  }
  @override
  Widget build(BuildContext context) {
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
                        icon: Icon(Icons.library_books_rounded,
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
                          Icons.wallet,
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
                        icon: Icon(Icons.person,
                          size: 25,
                          color: routeController.pageIndex.value == 3
                              ? Colors.white
                              : Colors.white70,
                        ),
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
          body: _pages[routeController.pageIndex.value],
        ),
      );
    });
  }
}