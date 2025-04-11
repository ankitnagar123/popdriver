import '../../route_helper/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/text_field.dart';
import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
import '../../utils/snackBar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../controller/home_screen_controller.dart';
import '../../utils/custom_button.dart';
import 'onboarding_model.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
     with SingleTickerProviderStateMixin  {


  int currentIndex = 0;
  PageController controller = PageController();
  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();

  @override
  void initState() {
    controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: PageView.builder(
                controller: controller,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) => Column(
                  children: [
                   Stack(
                     children: [
                       Image.asset(
                         items[index].middleImage.toString(),
                         height: Get.height/2.5,
                         width: Get.width,
                         fit: BoxFit.cover,
                       ),
                       Positioned(
                         left: Get.width/1.3,
                           top: 40,
                           child: TextButton(
                               onPressed: (){
                                 sp.setBoolValue(sp.ON_BOARDING_KEY, true);
                                 Get.offNamed(RouteHelper.getLoginScreenRoute());
                               },
                               child: Text("Skip".tr,style: TextStyle(
                                 fontSize: 18,
                                 color: Colors.white
                               ),),),),
                       Positioned(
                         left: 20,
                         top: 40,
                         child: IconButton(
                           onPressed: (){
                             show(context);
                           },
                           icon: Icon(Icons.language,color: Colors.white,))),

                     ],
                   ),

                    SizedBox(
                      height: context.height / 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        items[index].title.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          color: MyColors.DarkBlue
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                items.length, (index) => buildDotContainer(index, context)),
          ),
          SizedBox(
            height: context.height / 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: custom_button(
                voidCallback: () {
                  if (currentIndex == items.length - 1) {
                    sp.setBoolValue(sp.ON_BOARDING_KEY, true);
                    Get.offNamed(RouteHelper.getLoginScreenRoute());
                  }
                  controller.nextPage(
                      duration: const Duration(microseconds: 100),
                      curve: Curves.linear);
                },
                text: "Next".tr),
          ),
          SizedBox(
            height: context.height / 10,
          ),
        ],
      ),
    );
  }

  void show(BuildContext context) async {
    AuthController controller = Get.find<AuthController>();
    SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Center(
              child: SizedBox(
                height: Get.height / 2,
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Obx(
                          () => Column(
                        children: [
                          Text("Do You Want to Change Language".tr),
                          SizedBox(
                            height: 20,
                          ),
                          RadioListTile(
                            title: Text("English".tr),
                            value: "English",
                            groupValue: controller.language.value,
                            onChanged: (value) {
                              controller.language.value = value!;
                            },
                          ),
                          RadioListTile(
                            title: Text("spanish".tr),
                            value: "spanish",
                            groupValue: controller.language.value,
                            onChanged: (value) {
                              controller.language.value = value!;
                            },
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: custom_buttons(
                                  voidCallback: () {
                                    if (controller.language.value == "spanish") {
                                      var local = Locale('es', 'ES');
                                      Get.updateLocale(local);
                                      sp.setStringValue(sp.LANGUAGE, local.toString());
                                    }
                                    else {
                                      var local = Locale('en', 'US');
                                      Get.updateLocale(local);
                                      sp.setStringValue(
                                          sp.LANGUAGE, local.toString());
                                    }

                                    Get.offAllNamed(RouteHelper.getSplashScreenRoute());
                                  },
                                  text: 'Done'.tr,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }


  Container buildDotContainer(index, context) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      width: currentIndex == index ? 15 : 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index
            ? MyColors.buttonColor
            : Colors.grey.shade400,
      ),
    );
  }
}
