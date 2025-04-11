// To parse this JSON data, do
//
//     final fetchSingleQueryModel = fetchSingleQueryModelFromJson(jsonString);

import 'dart:convert';

List<FetchSingleQueryModel> fetchSingleQueryModelFromJson(String str) => List<FetchSingleQueryModel>.from(json.decode(str).map((x) => FetchSingleQueryModel.fromJson(x)));

String fetchSingleQueryModelToJson(List<FetchSingleQueryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FetchSingleQueryModel {
  String message;
  String userId;
  String complainNumber;
  String role;
  String time;

  FetchSingleQueryModel({
    required this.message,
    required this.userId,
    required this.complainNumber,
    required this.role,
    required this.time,
  });

  factory FetchSingleQueryModel.fromJson(Map<String, dynamic> json) => FetchSingleQueryModel(
    message: json["message"],
    userId: json["user_id"],
    complainNumber: json["complain_number"],
    role: json["role"],
    time: json["time"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "user_id": userId,
    "complain_number": complainNumber,
    "role": role,
    "time": time.toString(),
  };
}
