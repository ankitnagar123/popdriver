// To parse this JSON data, do
//
//     final driverRideHistoryModel = driverRideHistoryModelFromJson(jsonString);

import 'dart:convert';

List<DriverRideHistoryModel> driverRideHistoryModelFromJson(String str) => List<DriverRideHistoryModel>.from(json.decode(str).map((x) => DriverRideHistoryModel.fromJson(x)));

String driverRideHistoryModelToJson(List<DriverRideHistoryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DriverRideHistoryModel {
  String bookingId;
  String sourceAdd;
  String destinationAdd;
  String tolloptionPrice;
  String rideDate;
  String rideTime;
  String duration;
  String rideEndDate;
  String rideEndTime;
  String carTypeName;
  String status;
  String totalPrice;

  DriverRideHistoryModel({
    required this.bookingId,
    required this.sourceAdd,
    required this.destinationAdd,
    required this.tolloptionPrice,
    required this.rideDate,
    required this.rideTime,
    required this.duration,
    required this.rideEndDate,
    required this.rideEndTime,
    required this.carTypeName,
    required this.status,
    required this.totalPrice,
  });

  factory DriverRideHistoryModel.fromJson(Map<String, dynamic> json) => DriverRideHistoryModel(
    bookingId: json["booking_id"],
    sourceAdd: json["source_add"],
    destinationAdd: json["destination_add"],
    tolloptionPrice: json["tolloption_price"],
    rideDate: json["ride_date"],
    rideTime: json["ride_time"],
    duration: json["duration"],
    rideEndDate: json["ride_end_date"],
    rideEndTime: json["ride_end_time"],
    carTypeName: json["car_type_name"],
    status: json["status"],
    totalPrice: json["total_price"],
  );

  Map<String, dynamic> toJson() => {
    "booking_id": bookingId,
    "source_add": sourceAdd,
    "destination_add": destinationAdd,
    "tolloption_price": tolloptionPrice,
    "ride_date": rideDate,
    "ride_time": rideTime,
    "duration": duration,
    "ride_end_date": rideEndDate,
    "ride_end_time": rideEndTime,
    "car_type_name": carTypeName,
    "status": status,
    "total_price": totalPrice,
  };
}
