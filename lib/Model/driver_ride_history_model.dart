// To parse this JSON data, do
//
//     final driverRideHistoryModel = driverRideHistoryModelFromJson(jsonString);

import 'dart:convert';

List<DriverRideHistoryModel> driverRideHistoryModelFromJson(String str) =>
    List<DriverRideHistoryModel>.from(
        json.decode(str).map((x) => DriverRideHistoryModel.fromJson(x)));

String driverRideHistoryModelToJson(List<DriverRideHistoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DriverRideHistoryModel {
  String bookingId;
  String sourceAdd;
  String destinationAdd;
  String rideDate;
  String rideTime;
  String duration;
  String paymentMode;
  String distance;
  String rideEndDate;
  String rideEndTime;
  String carTypeName;
  String status;
  String totalPrice;

  DriverRideHistoryModel({
    required this.bookingId,
    required this.sourceAdd,
    required this.destinationAdd,
    required this.rideDate,
    required this.rideTime,
    required this.duration,
    required this.paymentMode,
    required this.distance,
    required this.rideEndDate,
    required this.rideEndTime,
    required this.carTypeName,
    required this.status,
    required this.totalPrice,
  });

  factory DriverRideHistoryModel.fromJson(Map<String, dynamic> json) =>
      DriverRideHistoryModel(
        bookingId: json["booking_id"].toString(),
        sourceAdd: json["source_add"].toString(),
        destinationAdd: json["destination_add"].toString(),
        rideDate: json["ride_date"].toString(),
        rideTime: json["ride_time"].toString(),
        duration: json["duration"].toString(),
        paymentMode: json["payment_mode"].toString(),
        distance: json["distance"].toString(),
        rideEndDate: json["ride_end_date"].toString(),
        rideEndTime: json["ride_end_time"].toString(),
        carTypeName: json["car_type_name"].toString(),
        status: json["status"].toString(),
        totalPrice: json["total_price"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "booking_id": bookingId,
        "source_add": sourceAdd,
        "destination_add": destinationAdd,
        "ride_date": rideDate,
        "ride_time": rideTime,
        "duration": duration,
        "payment_mode": paymentMode,
        "distance": distance,
        "ride_end_date": rideEndDate,
        "ride_end_time": rideEndTime,
        "car_type_name": carTypeName,
        "status": status,
        "total_price": totalPrice,
      };
}
