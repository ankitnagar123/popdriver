
import 'dart:developer';

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
  String bookingId = "";

  @override
  void initState() {
    type = Get.arguments['type'];
    bookingId = Get.arguments['bookingId'].toString();
    log("----------$bookingId");
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
              child:
                  custom_button(voidCallback: () {
                    showCustomDialog(context);
                }, text: "Cancel".tr),
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

      controller.driverBookingCancel(bookingId,
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


  void showCustomDialog(BuildContext context) {

    final String dialogTitle = "Are you sure you want to cancel this booking"
        .tr;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon
                Icon(
                  Icons.warning_amber_rounded,

                  color:  Colors.orange,
                  size: 40,
                ),
                const SizedBox(height: 16),

                // Message Text
                Text(
                  dialogTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),     Text(
                  "If you cancel this booking, you will not receive any new bookings for the next 10 minutes",
                  textAlign: TextAlign.center,
                  style:  TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons Row
                Obx(() {
                  if (controller.cancelBookLoader.value || controller.cancelStartBookLoader.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Back".tr,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Confirm Button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                           Colors.red,
                            padding:
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            validation();
                          },
                          child: Text(
                            "Cancel".tr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ));
  }

}


