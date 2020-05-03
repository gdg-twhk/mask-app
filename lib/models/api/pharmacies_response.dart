// To parse this JSON data, do
//
//     final pharmaciesResponse = pharmaciesResponseFromJson(jsonString);

import 'dart:convert';

import 'package:mask/models/api/mask.dart';

class PharmaciesResponse {
  String apiVersion;
  Data data;

  PharmaciesResponse({
    this.apiVersion,
    this.data,
  });

  factory PharmaciesResponse.fromRawJson(String str) =>
      PharmaciesResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PharmaciesResponse.fromJson(Map<String, dynamic> json) =>
      PharmaciesResponse(
        apiVersion: json["apiVersion"] == null ? null : json["apiVersion"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "apiVersion": apiVersion == null ? null : apiVersion,
        "data": data == null ? null : data.toJson(),
      };
}

class Data {
  List<Mask> items;

  Data({
    this.items,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        items: json["items"] == null
            ? null
            : List<Mask>.from(json["items"].map((x) => Mask.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson())),
      };
}
