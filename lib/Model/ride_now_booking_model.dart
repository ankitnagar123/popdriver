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
  String taxiPrice;
  String sharePrice;
  String userOfferPrice;
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
    required this.taxiPrice,
    required this.sharePrice,
    required this.userOfferPrice,
    required this.rideType,
    required this.distance,
    required this.duration,
    required this.rideDate,
    required this.rideTime,
  });

  factory RideNowBookingModel.fromJson(Map<String, dynamic> json) => RideNowBookingModel(
    bookingId: json["booking_id"].toString(),
    userName: json["user_name"].toString(),
    sourceAdd: json["source_add"].toString(),
    destinationAdd: json["destination_add"].toString(),
    taxiPrice: json["taxi_price"].toString(),
    sharePrice: json["share_price"].toString(),
    userOfferPrice: json["user_offer_price"].toString(),
    rideType: json["ride_type"].toString(),
    distance: json["distance"].toString(),
    duration: json["duration"].toString(),
    rideDate: json["ride_date"].toString(),
    rideTime: json["ride_time"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "booking_id": bookingId,
    "user_name": userName,
    "source_add": sourceAdd,
    "destination_add": destinationAdd,
    "taxi_price": taxiPrice,
    "share_price": sharePrice,
    "user_offer_price": userOfferPrice,
    "ride_type": rideType,
    "distance": distance,
    "duration": duration,
    "ride_date": rideDate,
    "ride_time": rideTime,
  };
}
