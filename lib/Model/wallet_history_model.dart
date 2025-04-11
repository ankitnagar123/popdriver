// To parse this JSON data, do
//
//     final walletHistoryModel = walletHistoryModelFromJson(jsonString);

import 'dart:convert';

List<WalletHistoryModel> walletHistoryModelFromJson(String str) => List<WalletHistoryModel>.from(json.decode(str).map((x) => WalletHistoryModel.fromJson(x)));

String walletHistoryModelToJson(List<WalletHistoryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WalletHistoryModel {
  String bookingId;
  String paymentMode;
  String status;
  String driverEarning;
  String date;
  String time;

  WalletHistoryModel({
    required this.bookingId,
    required this.paymentMode,
    required this.status,
    required this.driverEarning,
    required this.date,
    required this.time,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) => WalletHistoryModel(
    bookingId: json["booking_id"],
    paymentMode:json["payment_mode"],
    status: json["status"],
    driverEarning: json["driver_earning"],
    date: json["date"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "booking_id": bookingId,
    "payment_mode": paymentMode,
    "status": status,
    "driver_earning": driverEarning,
    "date": date,
    "time": time,
  };
}


