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
    totalRating: json["total_rating"].toString(),
    rating1: json["rating1"].toString(),
    rating2: json["rating2"].toString(),
    rating3: json["rating3"].toString(),
    rating4: json["rating4"].toString(),
    rating5: json["rating5"].toString(),
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
  List<PositivePointList> positivePointList;
  List<NegativePointList> negativePointList;

  ListElement({
    required this.rateId,
    required this.userName,
    required this.image,
    required this.feedback,
    required this.rating,
    required this.date,
    required this.time,
    required this.positivePointList,
    required this.negativePointList,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    rateId: (json['rate_id '] ?? json['rate_id'] ?? '').toString(),
    userName: json["user_name"].toString(),
    image: json["image"].toString(),
    feedback: json["feedback"].toString(),
    rating: json["rating"].toString(),
    date: json["date"].toString(),
    time: json["time"].toString(),
    positivePointList: List<PositivePointList>.from(json["positive_point_list"].map((x) => PositivePointList.fromJson(x))),
    negativePointList: List<NegativePointList>.from(json["negative_point_list"].map((x) => NegativePointList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "rate_id ": rateId,
    "user_name": userName,
    "image": image,
    "feedback": feedback,
    "rating": rating,
    "date": date,
    "time": time,
    "positive_point_list": List<dynamic>.from(positivePointList.map((x) => x.toJson())),
    "negative_point_list": List<dynamic>.from(negativePointList.map((x) => x.toJson())),
  };
}

class NegativePointList {
  String negativePoint;

  NegativePointList({
    required this.negativePoint,
  });

  factory NegativePointList.fromJson(Map<String, dynamic> json) => NegativePointList(
    negativePoint: json["negative_point"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "negative_point": negativePoint,
  };
}

class PositivePointList {
  String positivePoint;

  PositivePointList({
    required this.positivePoint,
  });

  factory PositivePointList.fromJson(Map<String, dynamic> json) => PositivePointList(
    positivePoint: json["positive_point"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "positive_point": positivePoint,
  };
}
