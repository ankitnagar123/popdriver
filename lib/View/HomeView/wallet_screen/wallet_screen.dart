import 'dart:developer';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/wallet_controller/wallet_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';
import '../drawer_tab_screen/my_ride_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletController controller = Get.put(WalletController());

  TextEditingController amtController = TextEditingController();
  TextEditingController accountNumberCtr = TextEditingController();
  TextEditingController nameCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthController>().fetchBankDetail().then((value) {
        if (value != "") {
          nameCtr.text = Get.find<AuthController>().accountHolderName.value;
          accountNumberCtr.text =
              Get.find<AuthController>().accountNumber.value;
          emailCtr.text = Get.find<AuthController>().email.value;
          mobileController.text = Get.find<AuthController>().contacts.value;
        }
      });
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
            Center(
                child: Text(
              "Wallet".tr,
              style: TextStyle(
                fontSize: 20,
                color: MyColors.white,
                fontFamily: "Poppins",
              ),
            )),
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
                          height: 15,
                        ),
                        Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 50,
                              color: MyColors.primary,
                            ),
                            Text(
                              controller.walletBalance.value == ""
                                  ? "KSh 0"
                                  : "KSh ${controller.walletBalance.value}",
                              style: TextStyle(
                                  color: MyColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                        // Text("Your wallet amount is"),
                        SizedBox(
                          height: 10,
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
                                    controller.buttonColor.value == true
                                        ? MyColors.primary
                                        : Colors.grey)),
                            onPressed: () {
                              controller.buttonColor.value = true;
                            },
                            child: Text(
                              "Coin Request".tr,
                              style: TextStyle(
                                fontWeight: controller.buttonColor.value == true
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                                color: MyColors.white,
                                fontFamily: "Poppins",
                              ),
                            )),
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    controller.buttonColor.value == false
                                        ? MyColors.primary
                                        : Colors.grey)),
                            onPressed: () {
                              controller.buttonColor.value = false;
                            },
                            child: Text(
                              "Withdrawal Request".tr,
                              style: TextStyle(
                                fontWeight:
                                    controller.buttonColor.value == false
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize: 13,
                                color: MyColors.white,
                                fontFamily: "Poppins",
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(10),
                    child: Visibility(
                      visible: controller.buttonColor.value,
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            _buildTextField(
                              controller: amtController,
                              label: 'Amount (KES)',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                }
                                if (double.tryParse(value) == null ||
                                    double.parse(value) <= 0) {
                                  return 'Enter valid amount';
                                }
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: mobileController,
                              label: 'Mobile Number',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter mobile number';
                                }
                              /*  if (!RegExp(r'^\+254\d{9}$').hasMatch(value)) { // Updated regex
                                  return 'Invalid Kenyan number'; // Updated error message
                                }*/
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: nameCtr,
                              label: 'Full Names',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: emailController,
                              label: 'Email (Optional)',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value!.isNotEmpty &&
                                    !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                                        .hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: reasonController,
                              label: 'Payment Reason',
                              maxLines: 2,
                            ),
                            const SizedBox(height: 20),
                            /*ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.teal,
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Processing Payment...'),
                                    ),
                                  );
                                  // Payment logic yaha likh sakte ho.
                                }
                              },
                              child: Text(
                                'Make Payment',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ),
                  ),

                  /**/
                  Visibility(
                    visible: controller.buttonColor.value == false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter Amount".tr,
                            style: TextStyle(
                                color: MyColors.DarkBlue, fontSize: 15),
                          ),
                          Container(
                            height: 50,
                            width: context.width,
                            padding: const EdgeInsets.only(left: 10),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                                color: MyColors.TextField,
                                border: Border.all(
                                    color: MyColors.TextField, width: 1)),
                            child: TextFormField(
                              toolbarOptions: ToolbarOptions(
                                copy: true,
                                cut: true,
                                paste: false,
                                selectAll: false,
                              ),
                              enableInteractiveSelection: false,
                              controller: amtController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              decoration: InputDecoration(
                                  counterText: "",
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: "Enter Amount".tr,
                                  hintStyle: const TextStyle(
                                      color: MyColors.DarkBlue, fontSize: 15)),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          custom_textfield(
                            manditory: "*",
                            labletext: "Account Holder Name".tr,
                            textInputType: TextInputType.text,
                            textEditingController: nameCtr,
                          ),
                          custom_textfield(
                            isEmail: true,
                            manditory: "*",
                            maxlenth: 9,
                            labletext: "Account Number".tr,
                            textInputType: TextInputType.number,
                            textEditingController: accountNumberCtr,
                          ),
                          custom_textfield(
                            isEmail: true,
                            manditory: "*",
                            labletext: "Email Address".tr,
                            textInputType: TextInputType.text,
                            textEditingController: emailCtr,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Obx(() {
                      if (controller.balanceAddLoader.value ||
                          controller.withdrawLoader.value) {
                        return Center(
                          child: myIndicator(),
                        );
                      } else {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              alignment: Alignment.center,
                              maximumSize: Size(Get.width / 1.1, 50),
                              backgroundColor: MyColors.black),
                          onPressed: () {
                            if(controller.buttonColor.value = true){
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Processing Payment...'),
                                  ),
                                );
                                controller.addWalletAmountPaymentInitialize(amtController.text,mobileController.text,reasonController.text,nameCtr.text,() {

                                },);
                              }
                            }else{
                              validation();
                            }
                          },
                          child: Center(
                            child: Text(
                              "Process".tr,
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  color: MyColors.white,
                                  fontSize: 14),
                            ),
                          ),
                        );
                      }
                    }),
                  ),
                  SizedBox(
                    height: 30,
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

                                    // Print Button
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Obx(() {
                                        if (controller.receiptLoader.value) {
                                          return const SizedBox(
                                            width: 45,
                                            height: 45,
                                            child: Center(child: CupertinoActivityIndicator()),
                                          );
                                        }
                                        return ElevatedButton(
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
                                              controller.printReceipt(
                                                  controller.startDate.value,
                                                  controller.endDate.value,
                                                  context
                                              );
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
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.transactionList.length,
                                  itemBuilder: (context, index) {
                                    final transaction = controller.transactionList[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: MyColors.primary.withOpacity(0.2), width: 1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Header Row (Status & Amount)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Chip(
                                                    label: Text(
                                                      transaction.status.toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 9,
                                                        fontFamily: "Poppins",
                                                        fontWeight: FontWeight.w600,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    backgroundColor: MyColors.primary.withOpacity(0.1),
                                                    visualDensity: VisualDensity.compact,
                                                  ),
                                                  Text(
                                                    "KSh ${transaction.driverEarning}",
                                                    style: const TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Ride ID
                                              Row(
                                                children: [
                                                  Icon(Icons.receipt, size: 18, color: Colors.grey[600]),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Ride ID: ${transaction.bookingId}".tr,
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      color: Colors.grey[800],
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Balance Information
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.account_balance_wallet, size: 18, color: Colors.grey[600]),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "Balance:".tr,
                                                        style: TextStyle(
                                                          fontFamily: "Poppins",
                                                          color: Colors.grey[700],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        "KSh ${transaction.driverEarning}",
                                                        style: TextStyle(
                                                          fontFamily: "Poppins",
                                                          color: MyColors.primary,
                                                          fontWeight: FontWeight.w700,
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
                                                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "${transaction.date} • ${transaction.time}",
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        cursorColor: MyColors.primary,
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),

          labelText: label,
          labelStyle: TextStyle(fontSize: 12,color: Colors.grey),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: MyColors.primary)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.grey)),
        ),
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

  // final ImagePicker picker = ImagePicker();

/*  void takePhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 60);
    print("picked file -----$pickedFile");
    if (pickedFile != null) {
      controller.imageString.value = File(pickedFile.path);
      log('image path---------->:${controller.imageString.value}');
    } else {
      print('No image selected.');
    }
  }*/

/*
  void _showImagePicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Gallery'.tr),
                  onTap: () {
                    Get.back();
                    takePhoto(
                      ImageSource.gallery,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'.tr),
                  onTap: () {
                    Get.back();
                    takePhoto(
                      ImageSource.camera,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
*/

  void validation() async {
    if (controller.buttonColor.value == false) {
      if (amtController.text.isEmpty) {
        customSnackBar("Please enter amount".tr);
      } else if (nameCtr.text.isEmpty) {
        customSnackBar("Please Fill Account Holder Name".tr);
      } else if (accountNumberCtr.text.isEmpty) {
        customSnackBar("Please Fill Account Number".tr);
      } else if (accountNumberCtr.text.length < 9) {
        customSnackBar("Account Number must be more than 9 characters long".tr);
      } else if (emailCtr.text.isEmpty) {
        customSnackBar("Please Fill Email Address".tr);
      } else if (EmailValidator.validate(emailCtr.text.trim().toString()) !=
          true) {
        customSnackBar("Please Fill Valid Email Address".tr);
      } else {
        controller.withdrawalBalance(amtController.text, emailCtr.text,
            nameCtr.text, accountNumberCtr.text);
        setState(() {
          amtController.clear();
        });
      }
    } else {
      if (amtController.text.isEmpty) {
        customSnackBar("Please enter amount".tr);
      }
      /* else if (controller.imageString.value == null) {
        customSnackBar("Please upload screenshot".tr);
      }*/
      else {

        amtController.text = "";
        setState(() {
          amtController.clear();
        });
      }
    }
  }
}
