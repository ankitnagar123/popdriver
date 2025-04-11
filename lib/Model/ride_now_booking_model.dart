// To parse this JSON data, do
//
//     final rideNowBookingModel = rideNowBookingModelFromJson(jsonString);

import 'dart:convert';

List<RideNowBookingModel> rideNowBookingModelFromJson(String str) => List<RideNowBookingModel>.from(json.decode(str).map((x) => RideNowBookingModel.fromJson(x)));

String rideNowBookingModelToJson(List<RideNowBookingModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RideNowBookingModel {
  String bookingId;
  String userName;
  String sourceAdd;
  String destinationAdd;
  String totalPrice;
  String rideType;
  String distance;
  String duration;
  String rideDate;
  String rideTime;

  RideNowBookingModel({
    required this.bookingId,
    required this.userName,
    required this.sourceAdd,
    required this.destinationAdd,
    required this.totalPrice,
    required this.rideType,
    required this.distance,
    required this.duration,
    required this.rideDate,
    required this.rideTime,
  });

  factory RideNowBookingModel.fromJson(Map<String, dynamic> json) => RideNowBookingModel(
    bookingId: json["booking_id"],
    userName: json["user_name"],
    sourceAdd: json["source_add"],
    destinationAdd: json["destination_add"],
    totalPrice: json["total_price"],
    rideType: json["ride_type"],
    distance: json["distance"],
    duration: json["duration"],
    rideDate: json["ride_date"],
    rideTime: json["ride_time"],
  );

  Map<String, dynamic> toJson() => {
    "booking_id": bookingId,
    "user_name": userName,
    "source_add": sourceAdd,
    "destination_add": destinationAdd,
    "total_price": totalPrice,
    "ride_type": rideType,
    "distance": distance,
    "duration": duration,
    "ride_date": rideDate,
    "ride_time": rideTime,
  };
}
