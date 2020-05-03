// To parse this JSON data, do
//
//     final maskDataRequest = maskDataRequestFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/foundation.dart';

class MaskDataRequest {
  Point center;
  Bounds bounds;
  int max;

  MaskDataRequest({
    @required this.center,
    @required this.bounds,
    @required this.max,
  });

  factory MaskDataRequest.fromRawJson(String str) =>
      MaskDataRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MaskDataRequest.fromJson(Map<String, dynamic> json) =>
      MaskDataRequest(
        center: json["center"] == null ? null : Point.fromJson(json["center"]),
        bounds: json["bounds"] == null ? null : Bounds.fromJson(json["bounds"]),
        max: json["max"] == null ? null : json["max"],
      );

  Map<String, dynamic> toJson() => {
        "center": center == null ? null : center.toJson(),
        "bounds": bounds == null ? null : bounds.toJson(),
        "max": max == null ? null : max,
      };
}

class Bounds {
  Point northEast;
  Point southEast;
  Point southWest;
  Point northWest;

  Bounds({
    @required this.northEast,
    @required this.southEast,
    @required this.southWest,
    @required this.northWest,
  });

  factory Bounds.fromRawJson(String str) => Bounds.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Bounds.fromJson(Map<String, dynamic> json) => Bounds(
        northEast: json["ne"] == null ? null : Point.fromJson(json["ne"]),
        southEast: json["se"] == null ? null : Point.fromJson(json["se"]),
        southWest: json["sw"] == null ? null : Point.fromJson(json["sw"]),
        northWest: json["nw"] == null ? null : Point.fromJson(json["nw"]),
      );

  Map<String, dynamic> toJson() => {
        "ne": northEast == null ? null : northEast.toJson(),
        "se": southEast == null ? null : southEast.toJson(),
        "sw": southWest == null ? null : southWest.toJson(),
        "nw": northWest == null ? null : northWest.toJson(),
      };
}

class Point {
  double lat;
  double lng;

  Point({
    this.lat,
    this.lng,
  });

  factory Point.fromRawJson(String str) => Point.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Point.fromJson(Map<String, dynamic> json) => Point(
        lat: json["lat"] == null ? null : json["lat"].toDouble(),
        lng: json["lng"] == null ? null : json["lng"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat == null ? null : lat,
        "lng": lng == null ? null : lng,
      };
}
