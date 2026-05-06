// To parse this JSON data, do
//
//     final vehicleFetchModel = vehicleFetchModelFromJson(jsonString);

import 'dart:convert';

List<VehicleFetchModel> vehicleFetchModelFromJson(String str) => List<VehicleFetchModel>.from(json.decode(str).map((x) => VehicleFetchModel.fromJson(x)));

String vehicleFetchModelToJson(List<VehicleFetchModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VehicleFetchModel {
  String carId;
  String carName;
  String carImage;

  VehicleFetchModel({
    required this.carId,
    required this.carName,
    required this.carImage,
  });

  factory VehicleFetchModel.fromJson(Map<String, dynamic> json) => VehicleFetchModel(
    carId: json["car_id"].toString(),
    carName: json["car_name"].toString(),
    carImage: json["car_image"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "car_id": carId,
    "car_name": carName,
    "car_image": carImage,
  };
}
