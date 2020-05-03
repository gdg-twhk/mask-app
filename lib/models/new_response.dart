// To parse this JSON data, do
//
//     final newsResponse = newsResponseFromJson(jsonString);

import 'dart:convert';
import 'package:intl/intl.dart';

class NewsResponse {
  NewsData data;

  NewsResponse({
    this.data,
  });

  factory NewsResponse.fromRawJson(String str) =>
      NewsResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NewsResponse.fromJson(Map<String, dynamic> json) => NewsResponse(
        data: json["data"] == null ? null : NewsData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : data.toJson(),
      };
}

class NewsData {
  List<News> items;

  NewsData({
    this.items,
  });

  factory NewsData.fromRawJson(String str) =>
      NewsData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NewsData.fromJson(Map<String, dynamic> json) => NewsData(
        items: json["items"] == null
            ? null
            : List<News>.from(json["items"].map((x) => News.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class News {
  String id;
  String imageUrl;
  String link;
  String title;
  String content;
  String time;

  News({
    this.id,
    this.imageUrl,
    this.link,
    this.title,
    this.content,
    this.time,
  });

  factory News.fromRawJson(String str) => News.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory News.fromJson(Map<String, dynamic> json) => News(
        id: json["id"] == null ? null : json["id"],
        imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
        link: json["link"] == null ? null : json["link"],
        title: json["title"] == null ? null : json["title"],
        content: json["content"] == null ? null : json["content"],
        time: json["time"] == null ? null : json["time"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "imageUrl": imageUrl == null ? null : imageUrl,
        "link": link == null ? null : link,
        "title": title == null ? null : title,
        "content": content == null ? null : content,
        "time": time == null ? null : time,
      };

  String get dateTime {
    var data = '';
    if (this.time != null && this.time.isNotEmpty) {
      final format = DateFormat('yyyy-MM-ddTHH:mm:ss');
      DateTime time = format.parse(this.time);
      data = DateFormat('yyyy-MM-dd').format(time);
    }
    return data;
  }
}
