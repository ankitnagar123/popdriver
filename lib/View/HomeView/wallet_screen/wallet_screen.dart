import 'dart:developer';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
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
  TextEditingController amtController = TextEditingController();
  WalletController controller = Get.put(WalletController());
  TextEditingController accountNumberCtr = TextEditingController();
  TextEditingController nameCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();

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
        }
      });
      controller.walletFetch();
      controller.fetchTransaction();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: MyColors.primary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           Get.arguments =="drawer"? InkWell(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ):SizedBox(),
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
                          height: 10,
                        ),
                        Icon(
                          Icons.account_balance_wallet,
                          size: 100,
                          color: MyColors.primary,
                        ),
                        // Text("Your wallet amount is"),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          controller.walletBalance.value == ""
                              ? "${"J\$0"}"
                              : "KSh ${controller.walletBalance.value}",
                          style: TextStyle(color: MyColors.black),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: MyColors.black,
                    height: 10,
                    thickness: 1,
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
                  Visibility(
                      visible: controller.buttonColor.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Add Amount".tr,
                              style: TextStyle(
                                  color: MyColors.DarkBlue, fontSize: 14),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: context.width,
                            padding: const EdgeInsets.only(left: 10),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
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
                              onChanged: (value) {
                                // Agar pehla character 0 hai aur total length 1 hai, to text ko clear kar do
                                if (value.length == 1 && value == "0") {
                                  amtController.clear();
                                }
                              },
                              decoration: InputDecoration(
                                  counterText: "",
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: "Enter Amount".tr,
                                  hintStyle: const TextStyle(
                                      color: MyColors.DarkBlue, fontSize: 13)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Account Details:".tr,
                              style: TextStyle(
                                  color: MyColors.black, fontSize: 13),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  "Ac No.".tr,
                                  style: TextStyle(
                                      color: MyColors.DarkBlue, fontSize: 13),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                controller.adminAccount.value,
                                style: TextStyle(
                                    color: MyColors.DarkBlue, fontSize: 13),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              _showImagePicker(context);
                            },
                            child: Container(
                                height: 100,
                                width: context.width,
                                padding: const EdgeInsets.only(left: 10),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    color: MyColors.TextField,
                                    border: Border.all(
                                        color: MyColors.TextField, width: 1)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    controller.imageString.value == null
                                        ? Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: MyColors.buttonColor,
                                            size: 30,
                                          )
                                        : Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    controller.imageString.value == null
                                        ? Text(
                                            "Upload ScreenShot".tr,
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                                color: MyColors.DarkBlue,
                                                fontSize: 13),
                                          )
                                        : Text(
                                            "Uploaded".tr,
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                                color: MyColors.DarkBlue,
                                                fontSize: 13),
                                          ),
                                  ],
                                )),
                          ),
                        ],
                      )),
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
                              maximumSize: Size(Get.width / 2, 50),
                              backgroundColor: MyColors.primary),
                          onPressed: () {
                            validation();
                          },
                          child: Center(
                            child: Text("Submit".tr,  style: TextStyle(
                                fontFamily: "Poppins",
                                color: MyColors.white,
                                fontSize: 14),),
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
                                child: Text("No Data Found".tr,  style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: MyColors.black,
                                    fontSize: 15),),
                              ),
                            )
                          : Column(
                              children: [
                                Row(
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
                                              height: 35,
                                              width: Get.width / 3.5,
                                              decoration: BoxDecoration(
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
                                              height: 35,
                                              width: Get.width / 3.5,
                                              decoration: BoxDecoration(
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
                                        } else{
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
                                              child: Text("Print".tr,style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: MyColors.white,
                                                  fontSize: 12),),
                                            ),
                                          );
                                        }

                                      }),
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    itemCount:
                                        controller.transactionList.length,
                                    itemBuilder: (context, index) {
                                      var list =
                                          controller.transactionList[index];
                                      return Card(
                                        elevation: 10.0,
                                        shape: RoundedRectangleBorder(
                                          side:
                                          BorderSide(
                                              color: MyColors.primary,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                list.status,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                    fontFamily: "Poppins",

                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Text(
                                                  "Amount".tr,
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",

                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              Text(
                                                "Ride ID: ${list.bookingId}".tr,
                                                style: TextStyle(
                                                  fontFamily: "Poppins",
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Wrap(
                                                    children: [
                                                      Text(
                                                        "Balance:".tr,
                                                        style: TextStyle(
                                                            fontFamily: "Poppins",
                                                            fontSize: 13,

                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      SizedBox(
                                                        width: 5.0,
                                                      ),
                                                      Text(
                                                        "KSh ${list.driverEarning}",
                                                        style: TextStyle(
                                                            fontSize: 13,

                                                            fontFamily: "Poppins",

                                                            color: MyColors
                                                                .primary,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    "KSh ${list.driverEarning}",
                                                    style: TextStyle(
                                                        fontSize: 13,

                                                        fontFamily: "Poppins",

                                                        color: MyColors.primary,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                              Wrap(
                                                children: [
                                                  Text(
                                                    list.date,
                                                    style: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 12,

                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Text(
                                                    list.time,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                        fontFamily: "Poppins",

                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
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

  final ImagePicker picker = ImagePicker();

  void takePhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 60);
    print("picked file -----$pickedFile");
    if (pickedFile != null) {
      controller.imageString.value = File(pickedFile.path);
      log('image path---------->:${controller.imageString.value}');
    } else {
      print('No image selected.');
    }
  }

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
      } else if (controller.imageString.value == null) {
        customSnackBar("Please upload screenshot".tr);
      } else {
        controller.walletBalanceAdd(
            amtController.text, controller.imageString.value);
        amtController.text = "";
        setState(() {
          amtController.clear();
        });
      }
    }
  }
}
