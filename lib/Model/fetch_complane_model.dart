// To parse this JSON data, do
//
//     final fetchComplaneModel = fetchComplaneModelFromJson(jsonString);

import 'dart:convert';

List<FetchComplaneModel> fetchComplaneModelFromJson(String str) => List<FetchComplaneModel>.from(json.decode(str).map((x) => FetchComplaneModel.fromJson(x)));

String fetchComplaneModelToJson(List<FetchComplaneModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FetchComplaneModel {
  String subject;
  String email;
  String bookingId;
  String message;
  String complainNumber;
  String status;
  String time;
  String image;

  FetchComplaneModel({
    required this.subject,
    required this.email,
    required this.bookingId,
    required this.message,
    required this.complainNumber,
    required this.status,
    required this.time,
    required this.image,
  });

  factory FetchComplaneModel.fromJson(Map<String, dynamic> json) => FetchComplaneModel(
    subject: json["subject"],
    email: json["email"],
    bookingId: json["booking_id"],
    message: json["message"],
    complainNumber: json["complain_number"],
    status: json["status"],
    time: json["time"].toString(),
    image: json["Image"],
  );

  Map<String, dynamic> toJson() => {
    "subject": subject,
    "email": email,
    "booking_id": bookingId,
    "message": message,
    "complain_number": complainNumber,
    "status": status,
    "time": time.toString(),
    "Image": image,
  };
}
