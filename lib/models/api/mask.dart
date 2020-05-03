import 'dart:convert';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mask/config/config.dart';
import 'package:mask/res/app_color.dart';
import 'package:mask/res/assets.dart';
import 'package:mask/utils/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

class Mask {
  String id;
  double distance;
  String name;
  String phone;
  String address;
  int maskAdult;
  int maskChild;
  String available;
  String customNote;
  String website;
  String note;
  double longitude;
  double latitude;
  String servicePeriods;
  String serviceNote;
  String county;
  String town;
  String cunli;
  String updated;

  Mask({
    this.id,
    this.distance,
    this.name,
    this.phone,
    this.address,
    this.maskAdult,
    this.maskChild,
    this.available,
    this.customNote,
    this.website,
    this.note,
    this.longitude,
    this.latitude,
    this.servicePeriods,
    this.serviceNote,
    this.county,
    this.town,
    this.cunli,
    this.updated,
  });

  factory Mask.fromRawJson(String str) => Mask.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Mask.fromJson(Map<String, dynamic> json) => Mask(
        id: json["id"] == null ? null : json["id"],
        distance: json["distance"] == null ? null : json["distance"].toDouble(),
        name: json["name"] == null ? null : json["name"],
        phone: json["phone"] == null ? null : json["phone"],
        address: json["address"] == null ? null : json["address"],
        maskAdult: json["maskAdult"] == null ? null : json["maskAdult"],
        maskChild: json["maskChild"] == null ? null : json["maskChild"],
        available: json["available"] == null ? null : json["available"],
        customNote: json["customNote"] == null ? null : json["customNote"],
        website: json["website"] == null ? null : json["website"],
        note: json["note"] == null ? null : json["note"],
        longitude:
            json["longitude"] == null ? null : json["longitude"].toDouble(),
        latitude: json["latitude"] == null ? null : json["latitude"].toDouble(),
        servicePeriods:
            json["servicePeriods"] == null ? null : json["servicePeriods"],
        serviceNote: json["serviceNote"] == null ? null : json["serviceNote"],
        county: json["county"] == null ? null : json["county"],
        town: json["town"] == null ? null : json["town"],
        cunli: json["cunli"] == null ? null : json["cunli"],
        updated: json["updated"] == null ? null : json["updated"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "distance": distance == null ? null : distance,
        "name": name == null ? null : name,
        "phone": phone == null ? null : phone,
        "address": address == null ? null : address,
        "maskAdult": maskAdult == null ? null : maskAdult,
        "maskChild": maskChild == null ? null : maskChild,
        "available": available == null ? null : available,
        "customNote": customNote == null ? null : customNote,
        "website": website == null ? null : website,
        "note": note == null ? null : note,
        "longitude": longitude == null ? null : longitude,
        "latitude": latitude == null ? null : latitude,
        "servicePeriods": servicePeriods == null ? null : servicePeriods,
        "serviceNote": serviceNote == null ? null : serviceNote,
        "county": county == null ? null : county,
        "town": town == null ? null : town,
        "cunli": cunli == null ? null : cunli,
        "updated": updated == null ? null : updated,
      };

  String get updateDateTime {
    var data = '';
    if (this.updated != null && this.updated.isNotEmpty) {
      final format = DateFormat('yyyy-MM-ddTHH:mm:ss');
      DateTime time = format.parse(this.updated);
      data = DateFormat('yyyy-MM-dd HH:mm').format(time);
    }
    return data;
  }

  String get beforeTime {
    var data = '';
    if (this.updated != null && this.updated.isNotEmpty) {
      final format = DateFormat('yyyy-MM-ddTHH:mm:ss');
      DateTime time = format.parse(this.updated);
      data = timeago.format(time, locale: AppLocalizations.locale.languageCode);
    }
    return data;
  }

  static List<Mask> toList(List<dynamic> jsonArray) {
    List<Mask> list = [];
    for (var item in (jsonArray ?? [])) list.add(Mask.fromJson(item));
    return list;
  }
}

extension MaskExtension on Mask {
  static bool isChildShow = true;
  static bool isAdultShow = true;

  BitmapDescriptor get marker {
    var count = (MaskExtension.isChildShow ? this.maskChild : 0) +
        (MaskExtension.isAdultShow ? this.maskAdult : 0);
    if (count >= Config.greenMiniCount)
      return MarkerIcon.green;
    else if (count >= Config.yellowMiniCount)
      return MarkerIcon.yellow;
    else if (count > Config.greyMiniCount)
      return MarkerIcon.red;
    else
      return MarkerIcon.grey;
  }

  Color get childColor {
    var count = this.maskChild;
    if (count >= Config.greenMiniCount)
      return AppColors.green;
    else if (count >= Config.yellowMiniCount)
      return AppColors.yellow;
    else if (count > Config.greyMiniCount)
      return AppColors.red;
    else
      return AppColors.gray;
  }

  Color get adultColor {
    var count = this.maskAdult;
    if (count >= Config.greenMiniCount)
      return AppColors.green;
    else if (count >= Config.yellowMiniCount)
      return AppColors.yellow;
    else if (count > Config.greyMiniCount)
      return AppColors.red;
    else
      return AppColors.gray;
  }

  Color get totalColor {
    var count = this.maskChild + this.maskAdult;
    if (count >= Config.greenMiniCount)
      return AppColors.green;
    else if (count >= Config.yellowMiniCount)
      return AppColors.yellow;
    else if (count > Config.greyMiniCount)
      return AppColors.red;
    else
      return AppColors.gray;
  }
}