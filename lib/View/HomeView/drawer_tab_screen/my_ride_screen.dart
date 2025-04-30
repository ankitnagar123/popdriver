
import 'package:flutter/cupertino.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/my_ride_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyRideScreen extends StatefulWidget {
  const MyRideScreen({Key? key}) : super(key: key);

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen> {
  MyRidesController controller = Get.find<MyRidesController>();

  @override
  void initState() {
    controller.rideLaterScreenBooking("", '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: MyColors.white
        ),
        backgroundColor: MyColors.primary,
        title:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/headLogo.png',height: 28,),
            Image.asset('assets/images/stearing.png',height: 38,color: Colors.white,),
          ],
        ),


        centerTitle: true,

      ),
      body: Obx(() {
        if (controller.rideLoader.value) {
          return Center(
            child: myIndicator(),
          );
        }
        else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(

              children: [
                Text("Upcoming Rides".tr,
                  style: TextStyle(fontSize: 18, color: MyColors.black,fontFamily: "Poppins"),),

               SizedBox(height: 8,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            // Start Date Picker
                            Expanded(
                              flex: 4,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    controller.status.value = "0";
                                    datePicker();
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: MyColors.buttonColor.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 18,
                                          color: MyColors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            controller.startDate.value,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontFamily: "Poppins",
                                              color: controller.startDate.value == "Select"
                                                  ? Colors.grey[400]
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Separator
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "To".tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),

                            // End Date Picker
                            Expanded(
                              flex: 4,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    controller.status.value = "1";
                                    datePicker();
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: MyColors.buttonColor.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 18,
                                          color: MyColors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            controller.endDate.value,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontFamily: "Poppins",
                                              color: controller.endDate.value == "Select"
                                                  ? Colors.grey[400]
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            if (controller.startDate.value != "Select" &&
                                controller.endDate.value != "Select") {
                              controller.rideLaterScreenBooking(
                                  controller.startDate.value,
                                  controller.endDate.value);
                            } else {
                              customSnackBar("Please select both dates".tr);
                            }
                          },
                          child: Text(
                            "Print".tr,
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),

                    ),
                  ],
                ),

                Expanded(
                  child: controller.rideLaterScreenLoader.value == true
                      ? Center(
                    child: myIndicator(),
                  )
                      : controller.rideLaterScreenList.length == 0
                      ? Center(
                    child: Text("No Booking Found".tr),
                  )
                      : ListView.builder(
                        itemCount: controller.rideLaterScreenList.length,
                        itemBuilder: (context, index) {
                          var reverseList = controller.rideLaterScreenList.reversed.toList();
                          var list = reverseList[index];
                      return InkWell(
                        onTap: () {
                          controller.fetchDriverBookingDetails(list.bookingId,(){});
                          dialogueBox();
                        },
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 10),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${list.carTypeName}" +
                                          "  " +
                                          "${list.rideTime}" + "  "
                                          "${list.rideDate}",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Final Cost".tr,
                                            style: TextStyle(
                                                fontSize: 10),
                                          ),
                                          Text(
                                            "KSh ${list.totalPrice}",
                                            style: TextStyle(
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Ride Later".tr,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff0CBB70)),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      list.rideTime,
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                      width: Get.width / 1.5,
                                      child: Text(
                                        list.sourceAdd,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        maxLines: 2,
                                        softWrap: false,
                                        style:
                                        TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(left: 40),
                                  child: SizedBox(
                                    height: 35,
                                    child: VerticalDivider(
                                      color: MyColors.black,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                      child: Text(
                                        "End...".tr,
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.location_on,
                                      color: MyColors.primary,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: Get.width / 1.5,
                                            child: Text(
                                              list.destinationAdd,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                              style: TextStyle(
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: SizedBox(
                                    width: 100,
                                    child: Obx(() {
                                      return controller.driverStartBookingLoader.value && controller.startIndex.value == index?
                                          Center(
                                            child: myIndicator(),
                                          ):
                                        ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: MyColors.primary),
                                        onPressed: () {
                                          controller.startIndex.value = index;
                                          controller.driverStartRide(
                                              list.bookingId, () {
                                            showDialog(
                                                context: context,
                                                builder: (
                                                    BuildContext context) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        ),
                                                    child: Center(
                                                      child: SizedBox(
                                                          height: Get.height/5.5,
                                                          child: Card(
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 10,
                                                                  vertical: 5),
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                      "You Can Start Ride Only Before 30 Min of Ride Time ".tr,textAlign: TextAlign.center,
                                                                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                                                                  SizedBox(
                                                                    height: 25,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 40,width: 100,
                                                                      child: custom_buttons(voidCallback: (){
                                                                        Get.back();
                                                                      }, text: "Ok".tr))
                                                                ],
                                                              ),
                                                            ),
                                                          )),
                                                    ),
                                                  );
                                                });
                                          });
                                        },
                                        child: Center(
                                          child: Text("Start Ride".tr,
                                            style: TextStyle(fontSize: 10,color: MyColors.white),),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }


  void dialogueBox1() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(() {
          if (controller.fetchBookLoader.value) {
            return Center(
              child: myIndicator(),
            );
          } else {
            var list = controller.bookingDetailsModel!;
            return AlertDialog.adaptive(


              contentPadding: EdgeInsets.all(10),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Makes the dialog box content compact
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Vehicle Type".tr,
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          list.carTypeName,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date Of Ride".tr,
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          "${list.rideTime} ${list.rideDate}",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ride ID".tr,
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          list.bookingId,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Final Cost".tr,
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          "KSh ${list.totalPrice}",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment Type".tr,
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          list.paymentMode,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: MyColors.primary,
                          backgroundImage: NetworkImage(list.image),
                          radius: 24,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(list.userName),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          list.rideTime,
                          style: TextStyle(fontSize: 10),
                        ),
                        Icon(Icons.location_on, color: Colors.green),
                        SizedBox(
                          width: Get.width / 1.8,
                          child: Text(
                            list.sourceAdd,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 53),
                      child: SizedBox(
                        height: 35,
                        child: VerticalDivider(color: MyColors.black),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 45,
                          child: Text(
                            list.rideEndTime.isEmpty
                                ? "End...".tr
                                : list.rideEndTime,
                            style: TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Icon(Icons.location_on, color: MyColors.primary),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: Get.width / 1.5,
                                child: Text(
                                  list.destinationAdd,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${list.distance} Km".tr,
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "Distance".tr,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black45),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              list.duration,
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "Duration".tr,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black45),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        });
      },
    );
  }

  void dialogueBox() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Obx(() {
          if (controller.fetchBookLoader.value) {
            return Container(
              height: 100,
              child: Center(child: myIndicator()),
            );
          } else {
            var list = controller.bookingDetailsModel!;
            return SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildInfoRow("Vehicle Type".tr, list.carTypeName),
                      _buildInfoRow("Date Of Ride".tr, "${list.rideTime} ${list.rideDate}"),
                      _buildInfoRow("Ride ID".tr, list.bookingId),
                      _buildInfoRow("Final Cost".tr, "KSh ${list.totalPrice}"),
                      _buildInfoRow("Payment Type".tr, list.paymentMode),

                      SizedBox(height: 15),
                      _buildDriverInfo(list),
                      SizedBox(height: 15),
                      _buildLocationInfo(list),
                      SizedBox(height: 20),
                      _buildStatsRow(list),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                ),
              ),
            );
          }
        });
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(list) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: MyColors.primary,
          backgroundImage: NetworkImage(list.image),
          radius: 24,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(list.userName, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(list) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 24),
            Icon(Icons.location_on, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(list.rideTime, style: TextStyle(fontSize: 12)),
                  Text(
                    list.sourceAdd,
                    style: TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Container(
            height: 20,
            width: 1,
            color: MyColors.black,
            margin: EdgeInsets.only(left: 10),
          ),
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 24),
            Icon(Icons.location_on, color: MyColors.primary, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.rideEndTime.isEmpty ? "End...".tr : list.rideEndTime,
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    list.destinationAdd,
                    style: TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(list) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn("${list.distance} Km", "Distance".tr),
        _buildStatColumn(list.duration, "Duration".tr),
      ],
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  datePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2050),
        builder: (context, child) =>
            Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: MyColors.primary,
                    onPrimary: MyColors.white,
                    onSurface: MyColors.DarkBlue,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      backgroundColor: MyColors.white, // button text color
                    ),
                  ),
                ),
                child: child!));

    if (pickedDate != null) {
      print(pickedDate);
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      print(
          formattedDate);
      setState(() {
        if (controller.status.value == "0") {
          controller.startDate.value = formattedDate;
        } else {
          controller.endDate.value = formattedDate;
          final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
          DateTime fromDate = _dateFormat.parse(controller.startDate.value);
          DateTime toDate = _dateFormat.parse(controller.endDate.value);
          if (fromDate.isAfter(toDate)) {
            showErrorDialog('Invalid date: "From" date must be earlier than or equal to "To" date.',context);
          }
        }
      });
    } else {}
  }
}

void showErrorDialog(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
