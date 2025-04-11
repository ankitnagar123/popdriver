// To parse this JSON data, do
//
//     final rideLaterBookingModel = rideLaterBookingModelFromJson(jsonString);

import 'dart:convert';

List<RideLaterBookingModel> rideLaterBookingModelFromJson(String str) => List<RideLaterBookingModel>.from(json.decode(str).map((x) => RideLaterBookingModel.fromJson(x)));

String rideLaterBookingModelToJson(List<RideLaterBookingModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RideLaterBookingModel {
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

  RideLaterBookingModel({
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

  factory RideLaterBookingModel.fromJson(Map<String, dynamic> json) => RideLaterBookingModel(
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
