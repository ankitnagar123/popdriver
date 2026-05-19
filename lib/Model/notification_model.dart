// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

List<NotificationModel> notificationModelFromJson(String str) => List<NotificationModel>.from(json.decode(str).map((x) => NotificationModel.fromJson(x)));

String notificationModelToJson(List<NotificationModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationModel {
  String id;
  String driverId;
  String title;
  String message;
  String date;
  String time;

  NotificationModel({
    required this.id,
    required this.driverId,
    required this.title,
    required this.message,
    required this.date,
    required this.time,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json["id"]?.toString() ?? '',
    driverId: json["driver_id"]?.toString() ?? '',
    title: json["title"]?.toString() ?? '',
    message: json["message"]?.toString() ?? '',
    date: json["date"]?.toString() ?? '',
    time: json["time"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "driver_id": driverId,
    "title": title,
    "message": message,
    "date": date,
    "time": time,
  };
}
