// To parse this JSON data, do
//
//     final memberShipModel = memberShipModelFromJson(jsonString);

import 'dart:convert';

List<MemberShipModel> memberShipModelFromJson(String str) => List<MemberShipModel>.from(json.decode(str).map((x) => MemberShipModel.fromJson(x)));

String memberShipModelToJson(List<MemberShipModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MemberShipModel {
  String membershipId;
  String membershipType;
  String name;
  String price;
  String duration;
  String tax;
  String commission;
  String description;

  MemberShipModel({
    required this.membershipId,
    required this.membershipType,
    required this.name,
    required this.price,
    required this.duration,
    required this.tax,
    required this.commission,
    required this.description,
  });

  factory MemberShipModel.fromJson(Map<String, dynamic> json) => MemberShipModel(
    membershipId: json["membership_id"].toString(),
    membershipType: json["membership_type"].toString(),
    name: json["name"].toString(),
    price: json["price"].toString(),
    duration: json["duration"].toString(),
    tax: json["tax"].toString(),
    commission: json["commission"].toString(),
    description: json["description"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "membership_id": membershipId,
    "membership_type": membershipType,
    "name": name,
    "price": price,
    "duration": duration,
    "tax": tax,
    "commission": commission,
    "description": description,
  };
}
