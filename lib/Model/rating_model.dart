// To parse this JSON data, do
//
//     final ratingModel = ratingModelFromJson(jsonString);

import 'dart:convert';

RatingModel ratingModelFromJson(String str) => RatingModel.fromJson(json.decode(str));

String ratingModelToJson(RatingModel data) => json.encode(data.toJson());

class RatingModel {
  String totalRating;
  String rating1;
  String rating2;
  String rating3;
  String rating4;
  String rating5;
  List<ListElement> list;

  RatingModel({
    required this.totalRating,
    required this.rating1,
    required this.rating2,
    required this.rating3,
    required this.rating4,
    required this.rating5,
    required this.list,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
    totalRating: json["total_rating"],
    rating1: json["rating1"],
    rating2: json["rating2"],
    rating3: json["rating3"],
    rating4: json["rating4"],
    rating5: json["rating5"],
    list: List<ListElement>.from(json["list"].map((x) => ListElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total_rating": totalRating,
    "rating1": rating1,
    "rating2": rating2,
    "rating3": rating3,
    "rating4": rating4,
    "rating5": rating5,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class ListElement {
  String rateId;
  String userName;
  String image;
  String feedback;
  String rating;
  String date;
  String time;

  ListElement({
    required this.rateId,
    required this.userName,
    required this.image,
    required this.feedback,
    required this.rating,
    required this.date,
    required this.time,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    rateId: json["rate_id "],
    userName: json["user_name"],
    image: json["image"],
    feedback: json["feedback"],
    rating: json["rating"],
    date: json["date"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "rate_id ": rateId,
    "user_name": userName,
    "image": image,
    "feedback": feedback,
    "rating": rating,
    "date": date,
    "time": time,
  };
}

