import 'package:flutter/material.dart';
import 'package:mpesa_flutter_plugin/initializer.dart';
import 'package:mpesa_flutter_plugin/payment_enums.dart';

import '../utils/snackBar.dart';
class Mpesapayment extends StatefulWidget {
  const Mpesapayment({super.key});

  @override
  State<Mpesapayment> createState() => _MpesapaymentState();
}

class _MpesapaymentState extends State<Mpesapayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

      Center(
        heightFactor: 10,
        child: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
          icon: Icon(Icons.account_balance_wallet),
          label: Text('Pay', style: TextStyle(color: Colors.white),),
          onPressed: () {
            _showToast(context);
            startCheckout(
                userPhone: "254704444999", amount: "1");
          },
        ),
      ),

        ]
      ),
    );
  }


  //method to initiate the transaction
  Future<void> startCheckout({required String userPhone, required String amount}) async {
    dynamic transactionInitialization;

    try {
      transactionInitialization =
      await MpesaFlutterPlugin.initializeMpesaSTKPush(

        businessShortCode: "4140907",
        transactionType: TransactionType.CustomerPayBillOnline,
        amount: double.parse(amount),
        partyA: userPhone,
        partyB: "4140907",
        callBackURL: Uri.parse("https://ride.mtaani.com/API/driverCallback.php?driver_id=8"),
        accountReference: "Flutter Mpesa Tim",
        phoneNumber: userPhone,
        transactionDesc: "Purchase",
        baseUri: Uri.parse("https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"),
        passKey:
        "8aef5d9afbe773d71e4f78f870666b2e49cd4bd2e299c04c4294f126861e1891",
      );
      print("Transaction Result: $transactionInitialization");
      return transactionInitialization;
    } catch (e) {
      print("Exception: $e");
    }
  }

  void _showToast(BuildContext context) {

    customSnackBar("Sending");

  }
}
