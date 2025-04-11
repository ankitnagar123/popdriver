
// To parse this JSON data, do
//
//     final fetchCardModel = fetchCardModelFromJson(jsonString);

import 'dart:convert';

List<FetchCardModel> fetchCardModelFromJson(String str) => List<FetchCardModel>.from(json.decode(str).map((x) => FetchCardModel.fromJson(x)));

String fetchCardModelToJson(List<FetchCardModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FetchCardModel {
  String cardId;
  String cardNo;
  String accountHolderName;
  String expMonth;
  String expYear;
  String cvv;

  FetchCardModel({
    required this.cardId,
    required this.cardNo,
    required this.accountHolderName,
    required this.expMonth,
    required this.expYear,
    required this.cvv,
  });

  factory FetchCardModel.fromJson(Map<String, dynamic> json) => FetchCardModel(
    cardId: json["card_id"],
    cardNo: json["card_no"],
    accountHolderName: json["account_holder_name"],
    expMonth: json["exp_month"],
    expYear: json["exp_year"],
    cvv: json["cvv"],
  );

  Map<String, dynamic> toJson() => {
    "card_id": cardId,
    "card_no": cardNo,
    "account_holder_name": accountHolderName,
    "exp_month": expMonth,
    "exp_year": expYear,
    "cvv": cvv,
  };
}
