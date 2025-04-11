// To parse this JSON data, do
//
//     final fetchSingleComplaneModel = fetchSingleComplaneModelFromJson(jsonString);

import 'dart:convert';

List<FetchSingleComplaneModel> fetchSingleComplaneModelFromJson(String str) => List<FetchSingleComplaneModel>.from(json.decode(str).map((x) => FetchSingleComplaneModel.fromJson(x)));

String fetchSingleComplaneModelToJson(List<FetchSingleComplaneModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FetchSingleComplaneModel {
  String message;
  String userId;
  String complainNumber;
  String role;
  String time;

  FetchSingleComplaneModel({
    required this.message,
    required this.userId,
    required this.complainNumber,
    required this.role,
    required this.time,
  });

  factory FetchSingleComplaneModel.fromJson(Map<String, dynamic> json) => FetchSingleComplaneModel(
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
