import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mask/app.dart';
import 'package:mask/res/assets.dart';
import 'package:mask/utils/preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MarkerIcon.initMarker();
  await Preferences.init();
  timeago.setLocaleMessages('zh', timeago.ZhMessages());
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    Crashlytics.instance.enableInDevMode = false;
    FlutterError.onError = Crashlytics.instance.recordFlutterError;
    runZoned(() {
      runApp(MyApp());
    }, onError: Crashlytics.instance.recordError);
  } else {
    runApp(MyApp());
  }
}
