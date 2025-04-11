import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:dio/dio.dart'as DIO;
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

  var imageString = Rxn<File>();

  var walletFetchLoader = false.obs;
  var walletFetchHistoryLoader = false.obs;
  var receiptLoader = false.obs;
  var buttonColor = true.obs;
  RxString walletBalance = "".obs;
  RxString adminAccount = "".obs;

  SharedPreferencesCrDriver sp = SharedPreferencesCrDriver();
  ApiService apiService = ApiService();
  var status = "".obs;
  RxString startDate = "Select".tr.obs;
  RxString endDate = "Select".tr.obs;
  var printList = <PrintModel>[].obs;

  var transactionList = <WalletHistoryModel>[].obs;

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
  var withdrawLoader = false.obs;

  void walletBalanceAdd(String price,File?file)async{
    balanceAddLoader.value = true;

    DIO.FormData formData = DIO.FormData.fromMap({
      "driver_id"  : await secure.readData(secure.user_id),
      "amount"     : price,
      "image"      : await DIO.MultipartFile.fromFile(file!.path,filename: file.path.split("/").last)
    });

    log("parameter ------ ${formData.fields}");

    try{
      final response = await apiService.multiPartFile(URLS.add_driver_amount, formData);
      var jsonString = jsonDecode(response.data);
      log("response --------$response");
      var result = jsonString["result"];
      if(result == "success"){
        imageString.value = null;
        balanceAddLoader.value = false;
        customSnackBar("Coin Request Submitted".tr);
      }else{
        balanceAddLoader.value = false;
        customSnackBar("Something Went Wrong".tr);
      }

    }catch(e){
      balanceAddLoader.value = false;
      log("Exception-----",error: e.toString());
    }
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
