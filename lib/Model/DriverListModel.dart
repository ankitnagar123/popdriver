// To parse this JSON data, do
//
//     final driverListModel = driverListModelFromJson(jsonString);

import 'dart:convert';

List<DriverListModel> driverListModelFromJson(String str) => List<DriverListModel>.from(json.decode(str).map((x) => DriverListModel.fromJson(x)));

String driverListModelToJson(List<DriverListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DriverListModel {
  String id;
  String firstName;
  String lastName;
  String email;
  String countryCode;
  String contact;
  String image;

  DriverListModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.contact,
    required this.image,
  });

  factory DriverListModel.fromJson(Map<String, dynamic> json) => DriverListModel(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    countryCode: json["country_code"],
    contact: json["contact"],
    image: json["Image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "country_code": countryCode,
    "contact": contact,
    "Image": image,
  };
}
