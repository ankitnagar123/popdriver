// import '../../route_helper/route_helper.dart';
// import '../../utils/colors.dart';
// import '../../utils/shared_preferences.dart';
// import '../../utils/text_field.dart';
// import '../../controller/auth_controller.dart';
// import '../../utils/colors.dart';
// import '../../utils/custom_button.dart';
// import '../../utils/snackBar.dart';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controller/auth_controller.dart';
// import '../../controller/home_screen_controller.dart';
// import '../../utils/custom_button.dart';
// import 'onboarding_model.dart';
//
// class OnBoardingScreen extends StatefulWidget {
//   const OnBoardingScreen({Key? key}) : super(key: key);
//
//   @override
//   State<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }
//
// class _OnBoardingScreenState extends State<OnBoardingScreen>
//      with SingleTickerProviderStateMixin  {
//
//
//   int currentIndex = 0;
//   PageController controller = PageController();
//   SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
//
//   @override
//   void initState() {
//     controller = PageController(initialPage: 0);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColors.background,
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(
//             child: PageView.builder(
//                 controller: controller,
//                 onPageChanged: (int index) {
//                   setState(() {
//                     currentIndex = index;
//                   });
//                 },
//                 scrollDirection: Axis.horizontal,
//                 itemCount: items.length,
//                 itemBuilder: (context, index) => Column(
//                   children: [
//                    Stack(
//                      children: [
//                        Image.asset(
//                          items[index].middleImage.toString(),
//                          height: Get.height/2.5,
//                          width: Get.width,
//                          fit: BoxFit.cover,
//                        ),
//                        Positioned(
//                          left: Get.width/1.3,
//                            top: 40,
//                            child: TextButton(
//                                onPressed: (){
//                                  sp.setBoolValue(sp.ON_BOARDING_KEY, true);
//                                  Get.offNamed(RouteHelper.getLoginScreenRoute());
//                                },
//                                child: Text("Skip".tr,style: TextStyle(
//                                  fontSize: 18,
//                                  color: Colors.white
//                                ),),),),
//                     /*   Positioned(
//                          left: 20,
//                          top: 40,
//                          child: IconButton(
//                            onPressed: (){
//                              show(context);
//                            },
//                            icon: Icon(Icons.language,color: Colors.white,))),*/
//
//                      ],
//                    ),
//
//                     SizedBox(
//                       height: context.height / 20,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: Text(
//                         items[index].title.toString(),
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 25,
//                           color: MyColors.DarkBlue
//                         ),
//                       ),
//                     ),
//                   ],
//                 )),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(
//                 items.length, (index) => buildDotContainer(index, context)),
//           ),
//           SizedBox(
//             height: context.height / 15,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 50),
//             child: custom_button(
//                 voidCallback: () {
//                   if (currentIndex == items.length - 1) {
//                     sp.setBoolValue(sp.ON_BOARDING_KEY, true);
//                     Get.offNamed(RouteHelper.getLoginScreenRoute());
//                   }
//                   controller.nextPage(
//                       duration: const Duration(microseconds: 100),
//                       curve: Curves.linear);
//                 },
//                 text: "Next".tr),
//           ),
//           SizedBox(
//             height: context.height / 10,
//           ),
//         ],
//       ),
//     );
//   }
//
//   void show(BuildContext context) async {
//     AuthController controller = Get.find<AuthController>();
//     SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
//     return showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: Center(
//               child: SizedBox(
//                 height: Get.height / 2,
//                 width: double.infinity,
//                 child: Card(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     child: Obx(
//                           () => Column(
//                         children: [
//                           Text("Do You Want to Change Language".tr),
//                           SizedBox(
//                             height: 20,
//                           ),
//                           RadioListTile(
//                             title: Text("English".tr),
//                             value: "English",
//                             groupValue: controller.language.value,
//                             onChanged: (value) {
//                               controller.language.value = value!;
//                             },
//                           ),
//                           RadioListTile(
//                             title: Text("spanish".tr),
//                             value: "spanish",
//                             groupValue: controller.language.value,
//                             onChanged: (value) {
//                               controller.language.value = value!;
//                             },
//                           ),
//                           Expanded(
//                             child: Align(
//                               alignment: Alignment.bottomCenter,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20, vertical: 10),
//                                 child: custom_buttons(
//                                   voidCallback: () {
//                                     if (controller.language.value == "spanish") {
//                                       var local = Locale('es', 'ES');
//                                       Get.updateLocale(local);
//                                       sp.setStringValue(sp.LANGUAGE, local.toString());
//                                     }
//                                     else {
//                                       var local = Locale('en', 'US');
//                                       Get.updateLocale(local);
//                                       sp.setStringValue(
//                                           sp.LANGUAGE, local.toString());
//                                     }
//
//                                     Get.offAllNamed(RouteHelper.getSplashScreenRoute());
//                                   },
//                                   text: 'Done'.tr,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         });
//   }
//
//
//   Container buildDotContainer(index, context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 5),
//       height: 10,
//       width: currentIndex == index ? 15 : 10,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: currentIndex == index
//             ? MyColors.buttonColor
//             : Colors.grey.shade400,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/shared_preferences.dart';
import 'onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>with SingleTickerProviderStateMixin {
  // ... existing variables ...
  late AnimationController _animationController;
  late Animation<Offset> _titleAnimation;
  late Animation<double> _imageAnimation;

  int currentIndex = 0;
  PageController controller = PageController();
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 0);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _imageAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                  _animationController.reset();
                  _animationController.forward();
                });
              },
              itemCount: items.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    double pageOffset = 0;
                    if (controller.position.haveDimensions) {
                      pageOffset = (controller.page! - index);
                    }
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..translate(
                            MediaQuery.of(context).size.width * -pageOffset)
                        ..scale(1 - pageOffset.abs() * 0.2),
                      alignment: FractionalOffset.center,
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50,),
                      SlideTransition(
                        position: _titleAnimation,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                              child: Text(
                                items[index].title.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: MyColors.primary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                items[index].subTitle.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.DarkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50,),

                      AnimatedBuilder(
                        animation: _imageAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _imageAnimation.value,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          items[index].middleImage.toString(),
                          height: Get.height/2.9,
                          width: Get.width,
                          fit: BoxFit.cover,
                        ),
                      ),
                    /*  Expanded(
                        child: Stack(
                          children: [


                            // ... skip button ...
                          ],
                        ),
                      ),*/

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
          AnimatedDots(currentIndex: currentIndex, length: items.length),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: AnimatedNextButton(
              currentIndex: currentIndex,
              onPressed: () {
                if (currentIndex == items.length - 1) {
                  sp.setBoolValue(sp.ON_BOARDING_KEY, true);
                  Get.offNamed(RouteHelper.getLoginScreenRoute());
                } else {
                  controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedDots extends StatelessWidget {
  final int currentIndex;
  final int length;

  const AnimatedDots({required this.currentIndex, required this.length});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: currentIndex == index ? 24 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: currentIndex == index
                ? MyColors.buttonColor
                : Colors.grey.withOpacity(0.4),
          ),
        );
      }),
    );
  }
}

class AnimatedNextButton extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onPressed;

  const AnimatedNextButton({required this.currentIndex, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: currentIndex == 2
          ? ElevatedButton(
        key: const ValueKey('start'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 40, vertical: 16),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      )
          : FloatingActionButton(
        key: const ValueKey('next'),
        onPressed: onPressed,
        backgroundColor: MyColors.buttonColor,
        elevation: 4,
        child: const Icon(Icons.arrow_forward, size: 28,color: Colors.white,),
      ),
    );
  }
}