import 'dart:convert';

import 'feedback.dart';

class FeedbackDataResponse {
  String apiVersion;
  FeedbackData data;

  FeedbackDataResponse({
    this.apiVersion,
    this.data,
  });

  factory FeedbackDataResponse.fromRawJson(String str) =>
      FeedbackDataResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FeedbackDataResponse.fromJson(Map<String, dynamic> json) =>
      FeedbackDataResponse(
        apiVersion: json["apiVersion"] == null ? null : json["apiVersion"],
        data: json["data"] == null
            ? null
            : FeedbackData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "apiVersion": apiVersion == null ? null : apiVersion,
        "data": data == null ? null : data.toJson(),
      };
}

class FeedbackData {
  int total;
  int offset;
  int limit;
  List<UserFeedback> items;

  FeedbackData({
    this.total,
    this.offset,
    this.limit,
    this.items,
  });

  factory FeedbackData.fromRawJson(String str) =>
      FeedbackData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FeedbackData.fromJson(Map<String, dynamic> json) =>
      FeedbackData(
        total: json["total"] == null ? null : json["total"],
        offset: json["offset"] == null ? null : json["offset"],
        limit: json["limit"] == null ? null : json["limit"],
        items: json["items"] == null
            ? null
            : List<UserFeedback>.from(
                json["items"].map((x) => UserFeedback.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total": total == null ? null : total,
        "offset": offset == null ? null : offset,
        "limit": limit == null ? null : limit,
        "items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson())),
      };
}
