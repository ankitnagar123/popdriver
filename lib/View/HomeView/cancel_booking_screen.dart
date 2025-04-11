
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/booking_controller.dart';
import '../../controller/home_screen_controller.dart';
import '../../utils/colors.dart';
import '../../utils/custom_button.dart';
import '../../utils/polyline_handler.dart';
import '../../utils/snackBar.dart';


class CancelBooking extends StatefulWidget {
  const CancelBooking({Key? key}) : super(key: key);

  @override
  State<CancelBooking> createState() => _CancelBookingState();
}

class _CancelBookingState extends State<CancelBooking> {

  BookingController controller = Get.find<BookingController>();
  HomeController controllers = Get.find<HomeController>();
TextEditingController messageCtr = TextEditingController();


  List<String> list = [
    "User not responding".tr,
    "The user did not arrive".tr,
    "The user entered the wrong address".tr,
    "Please tell us Why You Want To Cancel".tr
  ];

  String type = "";

  @override
  void initState() {
    type = Get.arguments['type'];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primary,
        title: Text("Cancel Booking".tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Please select the reason for the cancellation".tr,
              style: TextStyle(fontSize: 20),),
            SizedBox(height: 20,),
            ListView.builder(
                itemCount: list.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Obx(() =>
                      InkWell(
                        onTap: () {
                          controller.selectedIndex.value = index;
                          controller.reason.value = list[index];
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.check_circle,
                            color: controller.selectedIndex.value == index ?
                            Color(0xff0CBB70) :
                            MyColors.DarkBlue,
                            size: 30,),
                          title: Text(list[index]),
                        ),
                      ));
                }),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text("Write your reason".tr),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: messageCtr,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                maxLines: 7,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: MyColors.TextField,
                  hintText: "Write your reason for cancellation".tr,
                  hintStyle: TextStyle(fontSize: 15),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1, color: MyColors.TextField,),
                  ),
                ),
                onChanged: (value){
                  setState(() {
                    controller.reason.value = value;
                  });
                },
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Obx(() {
                return controller.cancelBookLoader.value || controller.cancelStartBookLoader.value?
                    Center(
                      child: myIndicator(),
                    ):
                  custom_button(voidCallback: () {
                    validation();
                }, text: "Submit".tr);
              }),
            )
          ],
        ),
      ),
    );
  }

  Future<void> validation()async{
    if(controller.reason.value == "Please tell us Why You Want To Cancel".tr&& messageCtr.text.isEmpty){
      customSnackBar('Please write cancel reason'.tr);
    }else if(controller.reason.value ==""){
      customSnackBar('Please choose cancel reason'.tr);
    }else{

      controller.driverBookingCancel(Get.arguments["ID"],
          '${controller.reason.value}', () {
            polyline.clear();
            controllers.markers.clear();
            controllers.hide.value = false;
            controllers.onOff.value = true;
        controller.userAcceptBooking(() { });
          controller.completeText.value = "";
            controllers.polylineVariable.value = "";
            controllers.polylineVariable2.value = "";
            controllers.driverArriveValue.value = false;
            controller.reason.value = "";
            controller.selectedIndex.value = -1;
            controllers.arriveDriver.value = "";
            controllers.painButton.value = false;
            Get.back();
          });

        /*controller.cancelBooking(Get.arguments["ID"],'${controller.reason.value + messageCtr.text}',(){
          controllers.polylineVariable.value = "";
          controllers.polylineVariable2.value = "";
          controller.rideLaterBooking();
          controllers.driverArriveValue.value = false;
          controller.reason.value = "";
          controller.selectedIndex.value = -1;
          Get.back();
        });*/
      }
    }
  }


