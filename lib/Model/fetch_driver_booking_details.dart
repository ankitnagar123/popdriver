// To parse this JSON data, do
//
//     final fetchDriverBookingDetailsModel = fetchDriverBookingDetailsModelFromJson(jsonString);

import 'dart:convert';

FetchDriverBookingDetailsModel fetchDriverBookingDetailsModelFromJson(String str) => FetchDriverBookingDetailsModel.fromJson(json.decode(str));

String fetchDriverBookingDetailsModelToJson(FetchDriverBookingDetailsModel data) => json.encode(data.toJson());

class FetchDriverBookingDetailsModel {
  String bookingId;
  String userId;
  String carTypeName;
  String sourceAdd;
  String sourceLat;
  String sourceLong;
  String destinationAdd;
  String destinationLat;
  String destinationLong;
  String totalPrice;
  String rideType;
  String paymentMode;
  String distance;
  String rideDate;
  String rideTime;
  String rideEndDate;
  String rideEndTime;
  String duration;
  String userName;
  String image;


  FetchDriverBookingDetailsModel({
    required this.bookingId,
    required this.userId,
    required this.carTypeName,
    required this.sourceAdd,
    required this.sourceLat,
    required this.sourceLong,
    required this.destinationAdd,
    required this.destinationLat,
    required this.destinationLong,
    required this.totalPrice,
    required this.rideType,
    required this.paymentMode,
    required this.distance,
    required this.rideDate,
    required this.rideTime,
    required this.rideEndDate,
    required this.rideEndTime,
    required this.duration,
    required this.userName,
    required this.image,
  });

  factory FetchDriverBookingDetailsModel.fromJson(Map<String, dynamic> json) => FetchDriverBookingDetailsModel(
    bookingId: json["booking_id"].toString(),
    userId: json["user_id"].toString(),
    carTypeName: json["car_type_name"].toString(),
    sourceAdd: json["source_add"].toString(),
    sourceLat: json["source_lat"].toString(),
    sourceLong: json["source_long"].toString(),
    destinationAdd: json["destination_add"].toString(),
    destinationLat: json["destination_lat"].toString(),
    destinationLong: json["destination_long"].toString(),
    totalPrice: json["total_price"].toString(),
    rideType: json["ride_type"].toString(),
    paymentMode: json["payment_mode"].toString(),
    distance: json["distance"].toString(),
    rideDate: json["ride_date"].toString(),
    rideTime: json["ride_time"].toString(),
    rideEndDate: json["ride_end_date"].toString(),
    rideEndTime: json["ride_end_time"].toString(),
    duration: json["duration"].toString(),
    userName: json["user_name"].toString(),
    image: json["Image"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "booking_id": bookingId,
    "user_id": userId,
    "car_type_name": carTypeName,
    "source_add": sourceAdd,
    "source_lat": sourceLat,
    "source_long": sourceLong,
    "destination_add": destinationAdd,
    "destination_lat": destinationLat,
    "destination_long": destinationLong,
    "total_price": totalPrice,
    "ride_type": rideType,
    "payment_mode": paymentMode,
    "distance": distance,
    "ride_date": rideDate,
    "ride_time": rideTime,
    "ride_end_date": rideEndDate,
    "ride_end_time": rideEndTime,
    "duration": duration,
    "user_name": userName,
    "Image": image,
  };
}
