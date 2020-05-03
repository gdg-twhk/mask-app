import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:package_info/package_info.dart';

class FA {
  static FirebaseAnalytics analytics;

  static Future<void> setCurrentScreen(
      String screenName, String screenClassOverride) async {
    await analytics?.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClassOverride,
    );
  }

  static Future<void> setUserProperty(String name, String value) async {
    await analytics?.setUserProperty(
      name: name,
      value: value,
    );
  }

  static Future<void> logEvent(String name) async {
    await analytics?.logEvent(
      name: name ?? '',
    );
  }

  static Future<void> logEventType(String name, String type) async {
    await analytics?.logEvent(
      name: name,
      parameters: <String, dynamic>{
        'type': type ?? '',
      },
    );
  }

  static Future<void> logEventNumber(String name, int number) async {
    await analytics?.logEvent(
      name: name,
      parameters: <String, dynamic>{
        'number': number,
      },
    );
  }
}
