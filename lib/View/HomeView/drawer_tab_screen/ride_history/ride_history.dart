
import 'package:mtaanidriver/View/HomeView/drawer_tab_screen/ride_history/ride_history_tab.dart';

import '../../../../controller/auth_controller.dart';
import '../../../../route_helper/route_helper.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/custom_button.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controller/my_ride_controller.dart';

import '../my_ride_screen.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({Key? key}) : super(key: key);

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  MyRidesController controller = Get.find<MyRidesController>();


  final List<String> tabs = ["All", "Completed","Cancelled"];
  @override
  void initState() {
    controller.rideHistory("", "","All");
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
        title:   Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/headLogo.png',
              height: 28,
            ),  Image.asset(
              color: Colors.white,
              'assets/images/stearing.png',
              height: 33,
            ),

          ],
        ),
        centerTitle: true,

      ),

      body: Obx(() {
        if (controller.historyLoader.value && controller.rideLoader.value) {
          return Center(
            child: myIndicator(),
          );
        }
       /* else if (controller.historyList.length == 0)
          return Center(
            child: Text('No History Found'),
          );*/
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text("Ride History".tr,
                  style: TextStyle(fontSize: 18, color: MyColors.black,fontFamily: "Poppins"),),
              ),
              SizedBox(height: 5,),
              _buildStatsRow(),
              SizedBox(
                height: 20,
              ),


              _buildDateFilters(
                 ),
              // Expanded(child: RideHistoryTab(startDate: controller.HistoryStartDate.value,endDate: controller.HistoryEndDate.value,)),
              Expanded(child: _buildRideList())

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
                                      "\$ ${list.totalPrice}",
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


  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.directions_car,
          title: "Total Rides",
          value: controller.totalBooking.value,
          color: MyColors.primary,
        ),
        SizedBox(width: 10),
        _buildStatCard(
          icon: Icons.attach_money,
          title: "Earnings",
          value: "\$ ${controller.totalEarning.value}",
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard({IconData? icon, String? title, String? value, Color? color}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color ?? MyColors.primary, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title!.tr,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500
                  ),
                ),
                Text(value!,
                  style: TextStyle(
                      fontSize: 18,
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDateFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDatePickerField(
                label: "From",
                value: controller.HistoryStartDate.value,
                onTap: () => _handleDatePicker(0),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDatePickerField(
                label: "To",
                value: controller.HistoryEndDate.value,
                onTap: () => _handleDatePicker(1),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildFilterButton(
                text: "Submit",
                onPressed: () => controller.rideHistory(
                  controller.HistoryStartDate.value,
                  controller.HistoryEndDate.value,
                  "All"
                ),
                isLoading: controller.historyLoader.value,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildFilterButton(
                text: "Reset",
                onPressed: () {
                  controller.HistoryEndDate.value = "";
                  controller.HistoryStartDate.value = "";
                  controller.rideHistory("", "","");
                },
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleDatePicker(int status) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: MyColors.primary,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: MyColors.primary,
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        if (status == 0) { // Start date
          controller.HistoryStartDate.value = formattedDate;
        } else { // End date
          controller.HistoryEndDate.value = formattedDate;

          // Validate date range
          final DateFormat format = DateFormat('dd-MM-yyyy');
          final DateTime start = format.parse(controller.HistoryStartDate.value);
          final DateTime end = format.parse(controller.HistoryEndDate.value);

          if (start.isAfter(end)) {
            showErrorDialog(
              'Invalid date range: Start date must be before end date',
              context,
            );
          }
        }
      });
    }
  }

  Widget _buildDatePickerField({String? label, String? value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: MyColors.primary),
            SizedBox(width: 10),
            Text(value ?? "Select $label",
              style: TextStyle(
                fontSize: 14,
                color: value == "Select" ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFilterButton({
    String? text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Color? color
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? MyColors.primary,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      )
          : Text(
        text!.tr,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }



  Widget _buildRideList() {
    if (controller.historyList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey[400]),
            SizedBox(height: 10),
            Text("No ride history found".tr,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      
      itemCount: controller.historyList.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ride = controller.historyList.reversed.toList()[index];
        return _buildRideCard(ride);
      },
    );
  }

  Widget _buildRideCard(dynamic ride) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _handleRideTap(ride),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header Row
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${ride.carTypeName} • ${ride.rideTime}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MyColors.primary,
                ),
              ),
              _buildStatusChip(ride.status),
            ],
          ),
          SizedBox(height: 12),
          // Route Information
          _buildLocationRow(
            icon: Icons.location_on_outlined,
            time: ride.rideTime,
            address: ride.sourceAdd,
            color: Colors.green,
          ),
          _buildDivider(),
          _buildLocationRow(
            icon: Icons.flag_outlined,
            time: ride.rideEndTime.isEmpty ? "End..." : ride.rideEndTime,
            address: ride.destinationAdd,
            color: Colors.red,
          ),
          SizedBox(height: 12),
          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$ ${ride.totalPrice}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(
                  RouteHelper.getReportScreenRout(),
                  arguments: {"id": ride.bookingId},
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  backgroundColor: MyColors.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child:  Text(
                  "Report Issue".tr,
                  style: TextStyle(
                      color: MyColors.primary,
                      fontWeight: FontWeight.w500
                  ),
                ),
              )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "Complete":
        bgColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case "Cancelled":
        bgColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.tr,
        style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500
        ),
      ),
    );
  }

  Widget _buildLocationRow({IconData? icon, String? time, String? address, Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(height: 4),
            Text(time ?? "",
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600]
              ),
            ),
          ],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(address!,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey[200],
        indent: 32,
      ),
    );
  }


  void _handleRideTap(dynamic ride) {
    // if (ride.status == "Complete") {
      controller.fetchDriverBookingDetails(
        ride.bookingId,
            () {
          // Show details dialog after data loads
          showDialog(
            context: context,
            builder: (context) => _buildRideDetailsDialog(),
          );
        },
      );
    // }
  }

  Widget _buildRideDetailsDialog() {
    return Obx(() {
      if (controller.fetchBookLoader.value) {
        return Center(child: myIndicator());
      }

      final details = controller.bookingDetailsModel!;
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogSectionTitle("Ride Details"),
              _buildDetailRow("Vehicle Type", details.carTypeName),
              _buildDetailRow("Date", "${details.rideTime} ${details.rideDate}"),
              _buildDetailRow("Ride ID", details.bookingId),
              _buildDetailRow("Total Cost", "\$ ${details.totalPrice}"),
              _buildDetailRow("Payment Mode", details.paymentMode),

              SizedBox(height: 20),
              _buildDialogSectionTitle("User Info"),
              _buildUserInfoRow(details),

              SizedBox(height: 20),
              _buildDialogSectionTitle("Route Details"),
              _buildRouteDetails(details),

              SizedBox(height: 20),
              _buildRideStatsRow(details),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: MyColors.primary)),
          ),
        ],
      );
    });
  }

// Helper widgets for dialog
  Widget _buildDialogSectionTitle(String title) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Text(title,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: MyColors.primary
      ),
    ),
  );

  Widget _buildDetailRow(String label, String value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$label:",
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700])),
        Text(value, style: TextStyle(color: Colors.black87)),
      ],
    ),
  );

  Widget _buildUserInfoRow(dynamic details) => Row(
    children: [
      CircleAvatar(
        backgroundImage: NetworkImage(details.image),
        radius: 24,
      ),
      SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(details.userName,
              style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text("★★★★☆ (4.0)",
              style: TextStyle(color: Colors.amber[700])),
        ],
      ),
    ],
  );

  Widget _buildRouteDetails(dynamic details) => Column(
    children: [
      _buildLocationDetail(
        icon: Icons.location_on,
        time: details.rideTime,
        address: details.sourceAdd,
        color: Colors.green,
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(height: 1),
      ),
      _buildLocationDetail(
        icon: Icons.flag,
        time: details.rideEndTime.isEmpty ? "End..." : details.rideEndTime,
        address: details.destinationAdd,
        color: Colors.red,
      ),
    ],
  );

  Widget _buildLocationDetail({IconData? icon, String? time, String? address, Color? color}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: color),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(address!,
                style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ],
  );

  Widget _buildRideStatsRow(dynamic details) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _buildStatItem("${details.distance} km", "Distance"),
      _buildStatItem(details.duration, "Duration"),
    ],
  );

  Widget _buildStatItem(String value, String label) => Column(
    children: [
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.grey[600])),
    ],
  );
}
