import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:dio/dio.dart'as DIO;
import 'package:mtaanidriver/controller/auth_controller.dart';
import '../../Model/DriverListModel.dart';
import '../../Model/print_model.dart';
import '../../Model/wallet_history_model.dart';
import '../../Network/api_service.dart';
import '../../Network/urls.dart';
import '../../utils/shared_preferences.dart';
import '../../utils/snackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class WalletController extends GetxController{
  
  DIO.Dio dioClient = DIO.Dio();
  SecureStorageService secure = SecureStorageService();

  // var imageString = Rxn<File>();

  var walletFetchLoader = false.obs;
  var walletFetchHistoryLoader = false.obs;
  var fetchDriverLoader = false.obs;
  var receiptLoader = false.obs;
  RxString walletBalance = "".obs;
  RxString adminAccount = "".obs;

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  ApiService apiService = ApiService();
  var status = "".obs;
  RxString startDate = "Select".tr.obs;
  RxString endDate = "Select".tr.obs;
  var printList = <PrintModel>[].obs;

  var transactionList = <WalletHistoryModel>[].obs;
  var driverList = <DriverListModel>[].obs;        // For filtered list (UI)
  var allDrivers = <DriverListModel>[].obs;        // Store full original list

  void fetchDriverListApi() async {
    fetchDriverLoader.value = true;

    Map<String, dynamic> walletHistory = {
      "id": await secure.readData(secure.user_id),
      "type": "Driver"
    };

    try {
      final response = await apiService.postData(URLS.DRIVER_LIST_FETCH, walletHistory);
      print("fetchDriverListApi response-------->:${response.body}");

      var fetchedDrivers = driverListModelFromJson(response.body);

      allDrivers.value = fetchedDrivers;      // Save full list
      driverList.value = fetchedDrivers;      // Initial filtered list is full

      fetchDriverLoader.value = false;
    } catch (e) {
      fetchDriverLoader.value = false;
      print("Exception-----${e.toString()}");
    }
  }
  void filterDrivers(String query) {
    if (query.isEmpty) {
      driverList.value = allDrivers;
    } else {
      final search = query.toLowerCase();
      driverList.value = allDrivers.where((driver) {
        final name = "${driver.firstName} ${driver.lastName}".toLowerCase();
        final phone = driver.contact.toLowerCase();
        final email = driver.email.toLowerCase();
        return name.contains(search) || phone.contains(search) || email.contains(search);
      }).toList();
    }
  }

  Future<void> sendWalletAmountToDriver(String receiverId ,amount,VoidCallback call) async {
    checkPaymentLoader.value = true;

    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id),
      "reciever_id":receiverId,
      "amount":amount
    };
    log("sendWalletAmountToDriver  Check: $map");

    try {
      final response = await apiService.postDatatoken(URLS.SEND_WALLET_AMOUNT_TO_DRIVER, map);
      var jsonString = jsonDecode(response.data);
      log("Payment Status Response Check: ${jsonString['result']}");

      if (jsonString['result'] == "success") {
        call();
        walletFetch();
        customSnackBar("✅Send Wallet Payment successful!");

      } else {
        var jsonString = jsonDecode(response.data);

        customSnackBar(jsonString['result'].toString());
      }
    } catch (e) {
      log("Exception during payment status check", error: e.toString());
      customSnackBar("❌ Error checking payment status.");
    } finally {
      checkPaymentLoader.value = false;
    }
  }





  void walletFetch()async{

    walletFetchLoader.value = true;
    Map<String,dynamic> walletFetch = {
      "driver_id"  : await secure.readData(secure.user_id),
    };
    
    try{
      
      final response = await apiService.postData(URLS.DRIVER_WALLET_FETCH, walletFetch);

      var data = jsonDecode(response.body);
      print("wallet response------->:$data");
      var result = data['result'];
      if(result == "success"){
        walletFetchLoader.value = false;
        walletBalance.value = data['driver_wallet'];
        adminAccount.value = data['admin_account'];
      }else{
        customSnackBar('something went wrong'.tr);
        walletFetchLoader.value = false;
      }
      
    }catch(e){
      print("Exception-----${e.toString()}",);
      walletFetchLoader.value = false;
    }

  }


  void fetchTransaction()async{

    walletFetchHistoryLoader.value = true;
    Map<String,dynamic> walletHistory = {
      "driver_id"  : await secure.readData(secure.user_id),
    };

    try{

      final response = await apiService.postData(URLS.DRIVER_WALLET_TRANSACTION_HISTORY, walletHistory);

      print("history response-------->:${response.body}");

      transactionList.value = walletHistoryModelFromJson(response.body);
      walletFetchHistoryLoader.value = false;

    }catch(e){
      walletFetchHistoryLoader.value = false;
      print("Exception-----${e.toString()}",);
    }

  }

  void fetchTransaction1() async {
    walletFetchHistoryLoader.value = true;

    // Dummy Data
    await Future.delayed(Duration(seconds: 1)); // simulate loading

    transactionList.value = [
      WalletHistoryModel(
        bookingId: "BKG123",
        paymentMode: "Cash",
        status: "Completed",
        driverEarning: "25.50",
        date: "2025-05-01",
        time: "10:30 AM",
      ),
      WalletHistoryModel(
        bookingId: "BKG124",
        paymentMode: "Card",
        status: "Completed",
        driverEarning: "32.75",
        date: "2025-05-02",
        time: "11:00 AM",
      ),
      WalletHistoryModel(
        bookingId: "BKG125",
        paymentMode: "Wallet",
        status: "Pending",
        driverEarning: "18.00",
        date: "2025-05-10",
        time: "09:45 AM",
      ),
      WalletHistoryModel(
        bookingId: "BKG126",
        paymentMode: "Cash",
        status: "Completed",
        driverEarning: "40.25",
        date: "2025-05-04",
        time: "02:15 PM",
      ),   WalletHistoryModel(
        bookingId: "BKG126",
        paymentMode: "Cash",
        status: "Completed",
        driverEarning: "100.25",
        date: "2025-05-15",
        time: "02:15 PM",
      ),   WalletHistoryModel(
        bookingId: "BKG126",
        paymentMode: "Cash",
        status: "Completed",
        driverEarning: "40.25",
        date: "2025-05-17",
        time: "02:15 PM",
      ),   WalletHistoryModel(
        bookingId: "BKG126",
        paymentMode: "Cash",
        status: "Completed",
        driverEarning: "40.28",
        date: "2025-05-25",
        time: "02:15 PM",
      ),   WalletHistoryModel(
        bookingId: "BKG126",
        paymentMode: "Cash",
        status: "Completed",
        driverEarning: "50.25",
        date: "2025-05-24",
        time: "02:15 PM",
      ), WalletHistoryModel(
        bookingId: "BKG126",
        paymentMode: "Cash",
        status: "Completed",
        driverEarning: "50.25",
        date: "2025-05-24",
        time: "02:15 PM",
      ), WalletHistoryModel(
        bookingId: "BKG126",
        paymentMode: "Cash",
        status: "Completed",
        driverEarning: "50.25",
        date: "2025-05-24",
        time: "02:15 PM",
      ),
    ];

    walletFetchHistoryLoader.value = false;
  }




  void printReceipt(String start_date, String end_date,BuildContext context)async{
    receiptLoader.value = true;
    Map<String,dynamic> forgetParameter = {
      "driver_id" : await secure.readData(secure.user_id),
      "start_date"     : start_date == 'Select'?"":start_date,
      "end_date":end_date == "Select"?"":end_date
    };

    log("receipt parameter------>:$forgetParameter");
    try{

      var response = await apiService.postDatas(URLS.DRIVER_WALLET_HISTORY_DOWNLOAD, forgetParameter);

      print("receipt response ------>:${response.data}");

      var jsonString = jsonDecode(response.data);

      log("receipt result ------>:${jsonString['result']}");

      var url = jsonString['result'];

      if(url == "No data Available"){
        receiptLoader.value = false;
        startDate.value = "Select";
        endDate.value = "Select";
        customSnackBar("No data Available");
      }else{
        startDate.value = "Select";
        endDate.value = "Select";
        downLoadFile(url);
      }

    }catch(e){
      receiptLoader.value = false;
      print("Exception-----${e.toString()}",);
    }
  }


  downLoadFile(String fileurl)async{
    FileDownloader.downloadFile(
        url: fileurl,
        name: "Payment History.pdf", //THE FILE NAME AFTER DOWNLOADING,
        onProgress: (String? fileName, double? progress) {
          print('FILE fileName HAS PROGRESS $progress');
        },
        onDownloadCompleted: (String path) {
          print('FILE DOWNLOADED TO PATH: $path');
          startDate.value = "Select";
          endDate.value = "Select";
          customSnackBar("file downloaded check download folder");
          receiptLoader.value = false;
        },
        onDownloadError: (String error) {
          startDate.value = "Select";
          endDate.value = "Select";
          print('DOWNLOAD ERROR: $error');
          receiptLoader.value = false;

        },
        notificationType: NotificationType.all
    );
  }

  /*void downloadFile(String fileurl)async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isDenied ||
        status.isPermanentlyDenied ||
        status.isRestricted) {
      throw "Please allow storage permission to upload files";
    }else if (status.isGranted) {

      Directory _directory = Directory("");
      if (Platform.isAndroid) {
        // Redirects it to download folder in android
        _directory = Directory("/storage/emulated/0/Download");
      } else {
        _directory = await getApplicationDocumentsDirectory();
      }

      if (_directory != null) {
        String savename = "Payment History.pdf";
        String savePath = _directory.path+"/$savename";
        print(savePath);
        //output:  /storage/emulated/0/Download/banner.png

        try {
          await Dio().download(
              fileurl,
              savePath,
              onReceiveProgress: (received, total) {
                if (total != -1) {
                  print((received / total * 100).toStringAsFixed(0) + "%");
                  //you can build progressbar feature too
                }
              });
          customSnackBar("File is saved to download folder.");
        } on DioError catch (e) {
          print(e.message);
          customSnackBar("Something went wrong");
        }
      }
    } else {
      customSnackBar("Something went wrong");
    }
  }*/

  var balanceAddLoader = false.obs;
  var checkPaymentLoader = false.obs;
  var withdrawLoader = false.obs;

  void addWalletAmountPaymentInitialize(String amount ,contactNumber,VoidCallback callback) async {
    balanceAddLoader.value = true;

    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id),
      "amount": amount,
      "phone": contactNumber,
    };
    log("Payment Request Params Initialize: $map");

    try {
      final response = await apiService.postDatatoken(URLS.add_driver_amount, map);
      var jsonString = jsonDecode(response.data);
      log("Payment Request Response Initialize: ${jsonString['result'].toString()}");

      if (jsonString['result'] == "Payment request sent successfully. Enter M-PESA PIN to complete.") {
        callback();
        customSnackBar(jsonString['result'].toString());
        showPaymentProcessingDialog(Get.context!, () {
          checkPaymentStatus(amount,contactNumber);
        });
        // 🔁 Wait 30 seconds before checking payment
        /* await Future.delayed(Duration(seconds: 30));
        await checkPaymentStatus(membership_id, type);*/
      } else {
        customSnackBar(jsonString['result'].toString());
      }
    } catch (e) {
      log("Exception during payment request", error: e.toString());
      customSnackBar("❌ Error initiating payment.");
    } finally {
      balanceAddLoader.value = false;
    }
  }

  Future<void> checkPaymentStatus(String amount ,contactNumber) async {
    checkPaymentLoader.value = true;

    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id),
      "payment_type":"Wallet"
    };
    log("Check Payment Params Check: $map");

    try {
      final response = await apiService.postDatatoken(URLS.check_payment_status, map);
      var jsonString = jsonDecode(response.data);
      log("Payment Status Response Check: ${jsonString['result']}");

      if (jsonString['result'] == "paid") {
        customSnackBar("✅ Payment successful!");
         addWalletAmountPaymentMain(amount,contactNumber,() {

        },);
      } else {
        customSnackBar("⏳ Payment still pending. Try again later.");
      }
    } catch (e) {
      log("Exception during payment status check", error: e.toString());
      customSnackBar("❌ Error checking payment status.");
    } finally {
      checkPaymentLoader.value = false;
    }
  }

  void addWalletAmountPaymentMain(String amount ,contactNumber,VoidCallback callback) async {
    balanceAddLoader.value = true;

    Map<String, dynamic> map = {
      "driver_id": await secure.readData(secure.user_id),
      "amount": amount,
      "phone": contactNumber,
    };
    log("Payment Request Response Main: $map");

    try {
      final response = await apiService.postDatatoken(URLS.wallet_payment_driver_main, map);
      var jsonString = jsonDecode(response.data);
      log("Payment Request Response Main: ${jsonString['result']}");

      if (jsonString['result'].toString() == "success") {
        callback();
        customSnackBar(jsonString['result'].toString());

        // 🔁 Wait 30 seconds before checking payment
        /* await Future.delayed(Duration(seconds: 30));
        await checkPaymentStatus(membership_id, type);*/
      } else {
        customSnackBar(jsonString['result'].toString());
      }
    } catch (e) {
      log("Exception during payment request", error: e.toString());
      customSnackBar("❌ Error initiating payment.");
    } finally {
      balanceAddLoader.value = false;
    }
  }

  void showPaymentProcessingDialog(BuildContext context, VoidCallback onComplete) {
    int secondsLeft = 30;
    Timer? timer;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
          if (secondsLeft == 0) {
            t.cancel();
            Navigator.of(context).pop(); // Close the dialog
            onComplete(); // Trigger payment check
          } else {
            secondsLeft--;
          }
        });

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Processing Payment"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Please enter your M-PESA PIN on your phone."),
                SizedBox(height: 8),
                Text("Checking payment in $secondsLeft seconds..."),
              ],
            ),
          );
        });
      },
    ).then((_) {
      timer?.cancel(); // Cancel if dialog closed early
    });
  }







  void withdrawalBalance(String amount,email,account_holder_name,account_number)async{
    withdrawLoader.value = true;
    Map<String,dynamic> withdrawal = {
    "driver_id": await secure.readData(secure.user_id)??"",
    "amount":amount,
    "email":email,
    "account_holder_name":account_holder_name,
    "account_number":account_number,
    };
    
    log("parameter ----$withdrawal");
    
    try {
      final response = await apiService.postData(URLS.add_driver_withdraw_request, withdrawal);

      var jsonString = jsonDecode(response.body);

      if(jsonString['result']=="Insufficient wallet amount"){
        customSnackBar("Insufficient wallet amount");
      }else if(jsonString['result'] == "success"){
        customSnackBar("Withdrawal Request sent successfully");
      }else{
        customSnackBar(jsonString['result'].toString());
      }
      withdrawLoader.value = false;
    } on Exception catch (e) {
      withdrawLoader.value = false;
    log("Exception ---",error: e.toString());
    }
  }

}
