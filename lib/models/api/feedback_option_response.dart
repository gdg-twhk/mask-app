import 'dart:convert';

class FeedbackOptionResponse {
  String apiVersion;
  OptionData data;

  FeedbackOptionResponse({
    this.apiVersion,
    this.data,
  });

  factory FeedbackOptionResponse.fromRawJson(String str) =>
      FeedbackOptionResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FeedbackOptionResponse.fromJson(Map<String, dynamic> json) =>
      FeedbackOptionResponse(
        apiVersion: json["apiVersion"] == null ? null : json["apiVersion"],
        data: json["data"] == null ? null : OptionData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "apiVersion": apiVersion == null ? null : apiVersion,
        "data": data == null ? null : data.toJson(),
      };
}

class OptionData {
  List<Option> items;

  OptionData({
    this.items,
  });

  factory OptionData.fromRawJson(String str) =>
      OptionData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OptionData.fromJson(Map<String, dynamic> json) => OptionData(
        items: json["items"] == null
            ? null
            : List<Option>.from(json["items"].map((x) => Option.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Option {
  String id;
  String name;

  Option({
    this.id,
    this.name,
  });

  factory Option.fromRawJson(String str) => Option.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
      };
}
