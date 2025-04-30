import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:mtaanidriver/View/HomeView/wallet_screen/sendwalletAmount.dart';


import '../../../controller/wallet_controller/wallet_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';

import '../drawer_tab_screen/my_ride_screen.dart';
import 'addTopUp.dart';
import 'ammount_withdrawal_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletController controller = Get.put(WalletController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      controller.walletFetch();
      controller.fetchTransaction();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: MyColors.primary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Get.arguments == "drawer"
                ? InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  )
                : SizedBox(),
            Row(
              children: [
                Image.asset(
                  'assets/images/headLogo.png',
                  height: 28,
                ),  Image.asset(
                  color: Colors.white,
                  'assets/images/stearing.png',
                  height: 37,
                ),

              ],
            ),
            /*  Center(
                child: Text(
              "Wallet".tr,
              style: TextStyle(
                fontSize: 20,
                color: MyColors.white,
                fontFamily: "Poppins",
              ),
            )),*/
            SizedBox(
              width: 10,
            )
          ],
        ),
        elevation: 0.0,
      ),
      body: Obx(
        () {
          if (controller.walletFetchLoader.value) {
            return Center(
              child: myIndicator(),
            );
          } else {
            return SingleChildScrollView(
              /* padding: EdgeInsets.all(20),*/
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Center(
                            child: Text(
                          "Wallet".tr,
                          style: TextStyle(
                            fontSize: 18,
                            color: MyColors.black,
                            fontFamily: "Poppins",
                          ),
                        )),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  MyColors.primary,
                                  MyColors.primary.withOpacity(0.5)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Account Balance',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 16)),
                                SizedBox(height: 10),
                                Row(
                                  spacing: 10,
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet,
                                      size: 50,
                                      color: MyColors.white,
                                    ),
                                    Text(
                                      controller.walletBalance.value == ""
                                          ? "KSh 0"
                                          : "KSh ${controller.walletBalance.value}",
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          decoration: controller
                                                  .walletBalance.value
                                                  .contains("-")
                                              ? TextDecoration.underline
                                              : null,
                                          decorationColor: Colors.red,
                                          wordSpacing: 1.5,
                                          color: MyColors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    height: 15,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                     MyColors.primary
                                       )),
                            onPressed: () {
                              Get.to(()=>AddTopUpScreen());
                            },
                            child: Text(
                              "Top Up".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                                  ,
                                fontSize: 13,
                                color: MyColors.white,
                                fontFamily: "Poppins",
                              ),
                            )),
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                   MyColors.primary
                                      )),
                            onPressed: () {
                              Get.to(()=>SendWalletAmount());
                            },
                            child: Text(
                              "Send".tr,
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold
                                       ,
                                fontSize: 13,
                                color: MyColors.white,
                                fontFamily: "Poppins",
                              ),
                            )),
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    MyColors.primary
                                        )),
                            onPressed: () {
                              Get.to(()=>AmountWithdrawalScreen());
                            },
                            child: Text(
                              "Withdrawal".tr,
                              style: TextStyle(
                                fontWeight:
                                     FontWeight.bold
                                ,
                                fontSize: 13,
                                color: MyColors.white,
                                fontFamily: "Poppins",
                              ),
                            )),
                      ],
                    ),
                  ),


                  controller.walletFetchHistoryLoader.value
                      ? SizedBox(
                          height: Get.height / 2,
                          child: Center(
                            child: myIndicator(),
                          ),
                        )
                      : controller.transactionList.length == 0
                          ? SizedBox(
                              height: Get.height / 3,
                              child: Center(
                                child: Text(
                                  "No Data Found".tr,
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: MyColors.black,
                                      fontSize: 15),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                /* Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              controller.status.value = "0";
                                              datePicker();
                                            },
                                            child: Container(
                                              height: 40,
                                              width: Get.width / 3.5,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                    color:
                                                        MyColors.buttonColor),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.calendar_month,
                                                    color: MyColors.primary,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller
                                                          .startDate.value,
                                                      style: TextStyle(
                                                          fontSize: 10.0),
                                                    ),
                                                  ),
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
                                              controller.status.value = "1";
                                              datePicker();
                                            },
                                            child: Container(

                                              height: 40,
                                              width: Get.width / 3.5,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),

                                                border: Border.all(
                                                    color:
                                                        MyColors.buttonColor),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.calendar_month,
                                                    color: MyColors.primary,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.endDate.value,
                                                      style: TextStyle(
                                                          fontSize: 10.0),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Obx(() {
                                        if (controller.receiptLoader.value) {
                                          return Center(
                                            child: myIndicator(),
                                          );
                                        } else {
                                          return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    MyColors.primary),
                                            onPressed: () {
                                              if (controller.startDate.value ==
                                                      "Select" &&
                                                  controller.endDate.value ==
                                                      "") {
                                                controller.printReceipt(
                                                    controller.startDate.value,
                                                    controller.endDate.value,
                                                    context);
                                              } else {
                                                customSnackBar(
                                                    "Please Select both date"
                                                        .tr);
                                              }
                                            },
                                            child: Center(
                                              child: Text(
                                                "Print".tr,
                                                style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    color: MyColors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                    ),
                                  ],
                                ),*/
                               /* Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Row(
                                          children: [
                                            // Start Date Picker
                                            Expanded(
                                              flex: 4,
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  onTap: () {
                                                    controller.status.value =
                                                        "0";
                                                    datePicker();
                                                  },
                                                  child: Container(
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: MyColors
                                                            .buttonColor
                                                            .withOpacity(0.3),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .calendar_today_rounded,
                                                          size: 18,
                                                          color:
                                                              MyColors.primary,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            controller.startDate
                                                                .value,
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  "Poppins",
                                                              color: controller
                                                                          .startDate
                                                                          .value ==
                                                                      "Select"
                                                                  ? Colors
                                                                      .grey[400]
                                                                  : Colors
                                                                      .black,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(6),
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
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  onTap: () {
                                                    controller.status.value =
                                                        "1";
                                                    datePicker();
                                                  },
                                                  child: Container(
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: MyColors
                                                            .buttonColor
                                                            .withOpacity(0.3),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .calendar_today_rounded,
                                                          size: 18,
                                                          color:
                                                              MyColors.primary,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            controller
                                                                .endDate.value,
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  "Poppins",
                                                              color: controller
                                                                          .endDate
                                                                          .value ==
                                                                      "Select"
                                                                  ? Colors
                                                                      .grey[400]
                                                                  : Colors
                                                                      .black,
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

                                  *//*  // Print Button
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Obx(() {
                                        if (controller.receiptLoader.value) {
                                          return const SizedBox(
                                            width: 45,
                                            height: 45,
                                            child: Center(
                                                child:
                                                    CupertinoActivityIndicator()),
                                          );
                                        }
                                        return ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: MyColors.primary,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 2,
                                          ),
                                          onPressed: () {
                                            if (controller.startDate.value !=
                                                    "Select" &&
                                                controller.endDate.value !=
                                                    "Select") {
                                              controller.printReceipt(
                                                  controller.startDate.value,
                                                  controller.endDate.value,
                                                  context);
                                            } else {
                                              customSnackBar(
                                                  "Please select both dates"
                                                      .tr);
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
                                        );
                                      }),
                                    ),*//*
                                  ],
                                ),*/
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.transactionList.length,
                                  itemBuilder: (context, index) {
                                    final transaction =
                                        controller.transactionList[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: MyColors.primary
                                                  .withOpacity(0.2),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Header Row (Status & Amount)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Chip(
                                                    label: Text(
                                                      transaction.status
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 9,
                                                        fontFamily: "Poppins",
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    backgroundColor: MyColors
                                                        .primary
                                                        .withOpacity(0.1),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  ),
                                                  Text(
                                                    "KSh ${transaction.driverEarning}",
                                                    style: const TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Ride ID
                                              transaction.bookingId =="0"?SizedBox():

                                              Row(
                                                children: [
                                                  Icon(Icons.receipt,
                                                      size: 18,
                                                      color: Colors.grey[600]),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Ride ID: ${transaction.bookingId}"
                                                        .tr,
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      color: Colors.grey[800],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Balance Information
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .account_balance_wallet,
                                                          size: 18,
                                                          color:
                                                              Colors.grey[600]),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "Balance:".tr,
                                                        style: TextStyle(
                                                          fontFamily: "Poppins",
                                                          color:
                                                              Colors.grey[700],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        "KSh ${transaction.driverEarning}",
                                                        style: TextStyle(
                                                          fontFamily: "Poppins",
                                                          color:
                                                              MyColors.primary,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Date & Time
                                              Row(
                                                children: [
                                                  Icon(Icons.access_time,
                                                      size: 16,
                                                      color: Colors.grey[600]),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "${transaction.date} • ${transaction.time}",
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            )
                ],
              ),
            );
          }
        },
      ),
    );
  }


  datePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime(2100),
        builder: (context, child) => Theme(
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
      log('formated date---->$formattedDate');
      print(formattedDate);
      setState(() {
        if (controller.status.value == "0") {
          controller.startDate.value = formattedDate;
        } else {
          controller.endDate.value = formattedDate;
          final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
          DateTime fromDate = _dateFormat.parse(controller.startDate.value);
          DateTime toDate = _dateFormat.parse(controller.endDate.value);
          if (fromDate.isAfter(toDate)) {
            showErrorDialog(
                'Invalid date: "From" date must be earlier than or equal to "To" date.',
                context);
          }
        }
      });
    } else {}
  }



}
