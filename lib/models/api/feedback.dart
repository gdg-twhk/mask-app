import 'dart:convert';
import 'package:intl/intl.dart';

class UserFeedback {
  String id;
  String userId;
  String pharmacyId;
  String optionId;
  String description;
  double longitude;
  double latitude;
  String createdAt;

  UserFeedback({
    this.id,
    this.userId,
    this.pharmacyId,
    this.optionId,
    this.description,
    this.longitude,
    this.latitude,
    this.createdAt,
  });

  factory UserFeedback.fromRawJson(String str) => UserFeedback.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserFeedback.fromJson(Map<String, dynamic> json) => UserFeedback(
    id: json["id"] == null ? null : json["id"],
    userId: json["userId"] == null ? null : json["userId"],
    pharmacyId: json["pharmacyId"] == null ? null : json["pharmacyId"],
    optionId: json["optionId"] == null ? null : json["optionId"],
    description: json["description"] == null ? null : json["description"],
    longitude: json["longitude"] == null ? null : json["longitude"].toDouble(),
    latitude: json["latitude"] == null ? null : json["latitude"].toDouble(),
    createdAt: json["createdAt"] == null ? null : json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "userId": userId == null ? null : userId,
    "pharmacyId": pharmacyId == null ? null : pharmacyId,
    "optionId": optionId == null ? null : optionId,
    "description": description == null ? null : description,
    "longitude": longitude == null ? null : longitude,
    "latitude": latitude == null ? null : latitude,
    "createdAt": createdAt == null ? null : createdAt,
  };

  String get time {
    var data = '';
    if (this.createdAt != null && this.createdAt.isNotEmpty) {
      final format = DateFormat('yyyy-MM-ddTHH:mm:ss');
      DateTime time = format.parse(this.createdAt);
      data = DateFormat('HH:mm').format(time);
    }
    return data;
  }
}
