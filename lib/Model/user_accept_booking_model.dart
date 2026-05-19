// To parse this JSON data, do
//
//     final userAcceptBookingModel = userAcceptBookingModelFromJson(jsonString);

import 'dart:convert';

UserAcceptBookingModel userAcceptBookingModelFromJson(String str) => UserAcceptBookingModel.fromJson(json.decode(str));

String userAcceptBookingModelToJson(UserAcceptBookingModel data) => json.encode(data.toJson());

class UserAcceptBookingModel {
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
  String duration;
  String userName;
  String contact;
  String image;
  String rating;
  String status;
  String confirmationCode;
  String locationUrl;

  UserAcceptBookingModel({
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
    required this.duration,
    required this.userName,
    required this.contact,
    required this.image,
    required this.rating,
    required this.status,
    required this.confirmationCode,
    required this.locationUrl,
  });

  /// Safe default before the first successful `userAcceptBooking` response.
  factory UserAcceptBookingModel.empty() => UserAcceptBookingModel(
        bookingId: "",
        userId: "",
        carTypeName: "",
        sourceAdd: "",
        sourceLat: "0",
        sourceLong: "0",
        destinationAdd: "",
        destinationLat: "0",
        destinationLong: "0",
        totalPrice: "",
        rideType: "",
        paymentMode: "",
        distance: "",
        rideDate: "",
        rideTime: "",
        duration: "",
        userName: "",
        contact: "",
        image: "",
        rating: "",
        status: "",
        confirmationCode: "",
        locationUrl: "",
      );

  factory UserAcceptBookingModel.fromJson(Map<String, dynamic> json) => UserAcceptBookingModel(
    bookingId: json["booking_id"],
    userId: json["user_id"],
    carTypeName: json["car_type_name"],
    sourceAdd: json["source_add"],
    sourceLat: json["source_lat"],
    sourceLong: json["source_long"],
    destinationAdd: json["destination_add"],
    destinationLat: json["destination_lat"],
    destinationLong: json["destination_long"],
    totalPrice: json["total_price"],
    rideType: json["ride_type"],
    paymentMode: json["payment_mode"],
    distance: json["distance"],
    rideDate: json["ride_date"],
    rideTime: json["ride_time"],
    duration: json["duration"],
    userName: json["user_name"],
    contact: json["contact"],
    image: json["Image"],
    rating: json["rating"].toString(),
    status: json["status"],
    confirmationCode: json["confirmation_code"],
    locationUrl: json["Location_url"],
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
    "duration": duration,
    "user_name": userName,
    "contact": contact,
    "Image": image,
    "rating": rating.toString(),
    "status": status,
    "confirmation_code": confirmationCode,
    "Location_url": locationUrl,
  };
}
