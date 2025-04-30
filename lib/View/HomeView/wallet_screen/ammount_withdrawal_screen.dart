import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/wallet_controller/wallet_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/text_field.dart';
class AmountWithdrawalScreen extends StatefulWidget {
  const AmountWithdrawalScreen({super.key});

  @override
  State<AmountWithdrawalScreen> createState() => _AmountWithdrawalScreenState();
}

class _AmountWithdrawalScreenState extends State<AmountWithdrawalScreen> {

  WalletController controller = Get.put(WalletController());

  TextEditingController amtController = TextEditingController();
  TextEditingController nameCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();
  TextEditingController accountNoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthController>().fetchBankDetail().then((value) {
        if (value != "") {
          nameCtr.text = Get.find<AuthController>().accountHolderName.value;

          emailCtr.text = Get.find<AuthController>().email.value;
        }
      });
      controller.walletFetch();
      controller.fetchTransaction();
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: MyColors.primary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            )
            ,
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
                              "WITHDRAWAL".tr,
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
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0,right: 18),
                    child: Container(
                        decoration: BoxDecoration(border: Border.all(color: MyColors.primary),),
                        child: Image.asset("assets/images/safariMPesa.jpg")),
                  ),



                  Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(10),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          _buildTextField(
                            controller: amtController,
                            label: 'Amount (kSh)',
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
                            controller: nameCtr,
                            label: 'Account Holder Name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full Account Holder Name';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: accountNoController,
                            label: 'Account Number',
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Account number is required';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9]{8,34}$').hasMatch(value)) {
                                return 'Enter a valid account number';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: emailCtr,
                            label: 'Email address',
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
                  Center(
                    child: Obx(() {
                      if (controller.withdrawLoader.value) {
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
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Processing Payment...'),
                                ),
                              );
                              controller.withdrawalBalance(amtController.text, emailCtr.text, nameCtr.text, accountNoController.text);


                            }
                          },
                          child: Center(
                            child: Text(
                              "Withdraw Request".tr,
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
              ]

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
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MyColors.primary)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey)),
        ),
      ),
    );
  }

}
