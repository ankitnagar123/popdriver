// To parse this JSON data, do
//
//     final printModel = printModelFromJson(jsonString);

import 'dart:convert';

List<PrintModel> printModelFromJson(String str) => List<PrintModel>.from(json.decode(str).map((x) => PrintModel.fromJson(x)));

String printModelToJson(List<PrintModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PrintModel {
  String paymentMode;
  String amount;
  String status;
  String date;
  String time;

  PrintModel({
    required this.paymentMode,
    required this.amount,
    required this.status,
    required this.date,
    required this.time,
  });

  factory PrintModel.fromJson(Map<String, dynamic> json) => PrintModel(
    paymentMode: json["Payment Mode"],
    amount: json["Amount"],
    status: json["Status"],
    date: json["Date"],
    time: json["Time"],
  );

  Map<String, dynamic> toJson() => {
    "Payment Mode": paymentMode,
    "Amount": amount,
    "Status": status,
    "Date": date,
    "Time": time,
  };
}

