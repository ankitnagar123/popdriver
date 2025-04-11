
import '../../../controller/auth_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/my_ride_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import 'my_ride_screen.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({Key? key}) : super(key: key);

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  MyRidesController controller = Get.find<MyRidesController>();

  @override
  void initState() {
    controller.rideHistory("", "");
    controller.driverTotalBooking();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: MyColors.white
        ),
        backgroundColor: MyColors.primary,
        title: Text("Ride History".tr,
          style: TextStyle(fontSize: 20, color: MyColors.white,fontFamily: "Poppins"),),
        centerTitle: true,

      ),

      body: Obx(() {
        if (controller.historyLoader.value && controller.rideLoader.value)
          return Center(
            child: myIndicator(),
          );
       /* else if (controller.historyList.length == 0)
          return Center(
            child: Text('No History Found'),
          );*/
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MyColors.buttonColor),
                      child: Row(
                        children: [
                          Icon(
                            Icons.car_repair_rounded,
                            size: 50,
                            color: MyColors.white,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, top: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Rides".tr,
                                    style: TextStyle(color: MyColors.white,fontFamily: "Poppins"),
                                  ),
                                  Text(
                                    controller.totalBooking.value,
                                    style: TextStyle(color: MyColors.white,fontFamily: "Poppins"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MyColors.buttonColor),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      color: MyColors.white),
                                  child: Center(
                                    child: Text(
                                      "J\$",
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          color: MyColors.buttonColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Earnings".tr,
                                          style: TextStyle(
                                              color: MyColors.white,fontFamily: "Poppins"),
                                        ),
                                        Text(
                                          "KSh ${controller.totalEarning
                                              .value}",
                                          style: TextStyle(
                                              color: MyColors.white,fontFamily: "Poppins"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          controller.dateStatus.value = "0";
                          datePicker();
                        },
                        child: Container(
                          height: 40,
                          width: Get.width / 3.5,
                          decoration: BoxDecoration(
                              border: Border.all(color: MyColors.buttonColor)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: MyColors.primary,
                              ),
                              Expanded(
                                  child: Text(
                                controller.HistoryStartDate.value,
                                style: TextStyle(fontSize: 10.0),
                              ))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text("To".tr),
                      SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          controller.dateStatus.value = "1";
                          datePicker();
                        },
                        child: Container(
                          height: 40,
                          width: Get.width / 3.5,
                          decoration: BoxDecoration(
                              border: Border.all(color: MyColors.buttonColor)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: MyColors.primary,
                              ),
                              Expanded(
                                  child: Text(
                                controller.HistoryEndDate.value,
                                style: TextStyle(fontSize: 10.0),
                              ))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Obx((){
                      if(controller.historyLoader.value){
                        return Center(child: myIndicator(),);
                      }else{
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(minimumSize: Size(30, 40),
                              maximumSize: Size(85, 40),

                              backgroundColor: MyColors.primary),
                          onPressed: () {
                            controller.rideHistory(
                                controller.HistoryStartDate.value,
                                controller.HistoryEndDate.value);
                          },
                          child: Center(
                            child: Text("Submit".tr,style: TextStyle(fontSize: 10,color: MyColors.white),),
                          ),
                        );
                      }

                    })
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primary),
                      onPressed: () {
                        controller.HistoryEndDate.value = "Select";
                        controller.HistoryStartDate.value = "Select";
                        controller.rideHistory("", "");
                      },
                      child: Center(
                        child: Text("Reset".tr,style: TextStyle(color: Colors.white,fontSize: 10),),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: controller.historyList.length == 0?
                 Center(
                 child: Text("No data found".tr,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                 ):
        controller.historyLoader.value?
            Center(child: myIndicator(),):
                ListView.builder(
                  itemCount: controller.historyList.length,
                  itemBuilder: (context, index) {
                    var reverseList = controller.historyList.reversed.toList();
                    var list = reverseList[index];
                    return InkWell(
                      onTap: () {
                        if(list.status == "Complete"){
                          controller.fetchDriverBookingDetails(
                              list.bookingId, () {});
                          dialogueBox();
                        }
                      },
                      child: Card(
                        color: MyColors.background,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "${list.carTypeName}" +
                                        " " +
                                        "${list.rideTime}" +
                                        " " +
                                        "${list.rideDate}",
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Final Cost".tr,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "KSh ${list.totalPrice}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                list.status,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: list.status == "Complete".tr
                                        ? Color(0xff0CBB70)
                                        : Colors.red),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 48,
                                    child: Text(
                                      list.rideTime,
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: Get.width / 1.5,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "PickUp Point".tr,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          list.sourceAdd,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: false,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50),
                                    child: SizedBox(
                                      height: 15,
                                      child: VerticalDivider(
                                        color: MyColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 48,
                                    child: Text(
                                      list.status == "Cancelled by user" || list.status == "Cancelled by driver"?
                                      "End.." :
                                      list.rideEndTime,
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Icon(
                                    Icons.location_on,
                                    color: MyColors.primary,
                                    size: 20,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: Get.width / 1.5,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Destination Point".tr,
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                    FontWeight.w600),
                                              ),
                                              Text(
                                                list.destinationAdd,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                softWrap: false,
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                    FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: SizedBox(
                                  width: 100,
                                  height: 30,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: MyColors.primary),
                                    onPressed: () {
                                      Get.toNamed(
                                          RouteHelper.getReportScreenRout(),
                                          arguments: {
                                            "id": list.bookingId,
                                          });
                                    },
                                    child: Center(
                                      child: Text(
                                        "Complain".tr,
                                        style: TextStyle(fontSize: 10,color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                  },
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  void dialogueBox() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      pageBuilder: (context, anim1, anim2) {
        return Obx(() {
          if (controller.fetchBookLoader.value) {
            return Center(
              child: myIndicator(),
            );
          } else {
            var list = controller.bookingDetailsModel!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 1.8,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Date Of Ride".tr,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      "${list.rideTime}" +
                                          " " +
                                          "${list.rideDate}",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(80)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(80),
                                        child: FadeInImage.assetNetwork(
                                          placeholder: 'assets/images/loader.gif',
                                          fit: BoxFit.cover,
                                          image: list.image,
                                          imageErrorBuilder: (c, o, s) => Image.asset(
                                            "assets/images/logo.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(list.userName),
                                          /*Text(
                                                "★★★★★(you Rated)",
                                                style: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 12),
                                              )*/
                                        ],
                                      ),
                                    ))
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
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
                                      width: Get.width / 1.8,
                                      child: Text(
                                        list.sourceAdd,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        softWrap: false,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 53),
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
                                      width: 45,
                                      child: Text(
                                        list.rideEndTime == ""
                                            ? "End...".tr
                                            : list.rideEndTime,
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500),
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
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ))
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                              fontSize: 14,
                                              color: Colors.black45),
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
                                              fontSize: 14,
                                              color: Colors.black45),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }
        });
      },
    );
  }

  datePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2100),
        builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: MyColors.primary, // <-- SEE HERE
                onPrimary: MyColors.white, // <-- SEE HERE
                onSurface: MyColors.DarkBlue, // <-- SEE HERE
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: MyColors.primary, // button text color
                ),
              ),
            ),
            child: child!));

    if (pickedDate != null) {
      print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      print(
          formattedDate); //formatted date output using intl package =>  2021-03-16
      setState(() {
        if (controller.dateStatus.value == "0") {
          controller.HistoryStartDate.value = formattedDate;
        } else {
          controller.HistoryEndDate.value = formattedDate;
          final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
          DateTime fromDate = _dateFormat.parse(controller.HistoryStartDate.value);
          DateTime toDate = _dateFormat.parse(controller.HistoryEndDate.value);
          if (fromDate.isAfter(toDate)) {
            showErrorDialog('Invalid date: "From" date must be earlier than or equal to "To" date.',context);
          }
        }
        //set output date to TextField value.
      });
    } else {}
  }
}
