// To parse this JSON data, do
//
//     final taxiCompanyFetchModel = taxiCompanyFetchModelFromJson(jsonString);

import 'dart:convert';

List<TaxiCompanyFetchModel> taxiCompanyFetchModelFromJson(String str) => List<TaxiCompanyFetchModel>.from(json.decode(str).map((x) => TaxiCompanyFetchModel.fromJson(x)));

String taxiCompanyFetchModelToJson(List<TaxiCompanyFetchModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TaxiCompanyFetchModel {
  String companyId;
  String companyName;

  TaxiCompanyFetchModel({
    required this.companyId,
    required this.companyName,
  });

  factory TaxiCompanyFetchModel.fromJson(Map<String, dynamic> json) => TaxiCompanyFetchModel(
    companyId: json["company_id"],
    companyName: json["company_name"],
  );

  Map<String, dynamic> toJson() => {
    "company_id": companyId,
    "company_name": companyName,
  };
}
