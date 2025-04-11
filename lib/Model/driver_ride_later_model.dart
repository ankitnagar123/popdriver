// To parse this JSON data, do
//
//     final rideLaterScreenBookingModel = rideLaterScreenBookingModelFromJson(jsonString);

import 'dart:convert';

List<RideLaterScreenBookingModel> rideLaterScreenBookingModelFromJson(String str) => List<RideLaterScreenBookingModel>.from(json.decode(str).map((x) => RideLaterScreenBookingModel.fromJson(x)));

String rideLaterScreenBookingModelToJson(List<RideLaterScreenBookingModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RideLaterScreenBookingModel {
  String bookingId;
  String sourceAdd;
  String destinationAdd;
  String totalPrice;
  String rideType;
  String rideDate;
  String rideTime;
  String duration;
  String rideEndDate;
  String rideEndTime;
  String carTypeName;

  RideLaterScreenBookingModel({
    required this.bookingId,
    required this.sourceAdd,
    required this.destinationAdd,
    required this.totalPrice,
    required this.rideType,
    required this.rideDate,
    required this.rideTime,
    required this.duration,
    required this.rideEndDate,
    required this.rideEndTime,
    required this.carTypeName,
  });

  factory RideLaterScreenBookingModel.fromJson(Map<String, dynamic> json) => RideLaterScreenBookingModel(
    bookingId: json["booking_id"],
    sourceAdd: json["source_add"],
    destinationAdd: json["destination_add"],
    totalPrice: json["total_price"],
    rideType: json["ride_type"],
    rideDate: json["ride_date"],
    rideTime: json["ride_time"],
    duration: json["duration"],
    rideEndDate: json["ride_end_date"],
    rideEndTime: json["ride_end_time"],
    carTypeName: json["car_type_name"],
  );

  Map<String, dynamic> toJson() => {
    "booking_id": bookingId,
    "source_add": sourceAdd,
    "destination_add": destinationAdd,
    "total_price": totalPrice,
    "ride_type": rideType,
    "ride_date": rideDate,
    "ride_time": rideTime,
    "duration": duration,
    "ride_end_date": rideEndDate,
    "ride_end_time": rideEndTime,
    "car_type_name": carTypeName,
  };
}
