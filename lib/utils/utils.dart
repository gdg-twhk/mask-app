import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mask/api/helper.dart';
import 'package:mask/config/config.dart';
import 'package:mask/config/constants.dart';
import 'package:mask/utils/preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_localizations.dart';

class Utils {
  static void showToast(BuildContext context, String message) {
    Toast.show(
      message,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
    );
  }

  static void showFCMNotification(
      String title, String body, String payload) async {
    //limit Android and iOS system
    if (Platform.isAndroid || Platform.isIOS) {
      var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      var initializationSettings = InitializationSettings(
        AndroidInitializationSettings('ic_stat_place'),
        IOSInitializationSettings(
          onDidReceiveLocalNotification: (id, title, body, payload) async {
            print('$title');
          },
        ),
      );
      flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (text) async {
          print('test');
        },
      );
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '101',
        'fcm',
        'fcm',
        importance: Importance.Max,
        priority: Priority.Max,
        style: AndroidNotificationStyle.BigText,
        enableVibration: false,
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        101,
        title,
        payload,
        platformChannelSpecifics,
        payload: payload,
      );
    } else {
      //TODO implement other platform system local notification
    }
  }

  static checkRemoteConfig(BuildContext context) async {
    await Future.delayed(
      Duration(milliseconds: 50),
    );
    if (kIsWeb && !(Platform.isAndroid || Platform.isIOS)) return;
    final app = AppLocalizations.of(context);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!Constants.isInDebugMode) {
      final RemoteConfig remoteConfig = await RemoteConfig.instance;
      try {
        await remoteConfig.fetch(
          expiration: const Duration(seconds: 10),
        );
        await remoteConfig.activateFetched();
      } on FetchThrottledException catch (exception) {} catch (exception) {}
      Preferences.setInt(Constants.GREEN_MINI_COUNT,
          remoteConfig.getInt(Constants.GREEN_MINI_COUNT));
      Preferences.setInt(Constants.YELLOW_MINI_COUNT,
          remoteConfig.getInt(Constants.YELLOW_MINI_COUNT));
      Preferences.setInt(Constants.GREY_MINI_COUNT,
          remoteConfig.getInt(Constants.GREY_MINI_COUNT));
      Preferences.init();
      Config.isShowLinks = remoteConfig.getBool(Constants.IS_SHOW_LINKS);
      String url = "";
      int versionDiff = 0, newVersion;
      if (Platform.isAndroid) {
        url = "market://details?id=${packageInfo.packageName}";
        newVersion = remoteConfig.getInt(Constants.ANDROID_APP_VERSION);
      } else if (Platform.isIOS) {
        url =
            "itms-apps://itunes.apple.com/tw/app/apple-store/id1498239100?mt=8";
        newVersion = remoteConfig.getInt(Constants.IOS_APP_VERSION);
      }
      bool forceUpdate = remoteConfig.getBool(Constants.FORCE_UPDATE) ?? false;
      versionDiff = newVersion - int.parse(packageInfo.buildNumber);
      if (versionDiff > 0) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => WillPopScope(
            child: AlertDialog(
              title: Text(app.updateTitle),
              content: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                      color: Colors.grey, height: 1.3, fontSize: 16.0),
                  children: [
                    TextSpan(
                      text: '${app.updateContent}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                if (!forceUpdate)
                  FlatButton(
                    child: Text(app.skip),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                FlatButton(
                  child: Text(app.update),
                  onPressed: () {
                    launch(url);
                  },
                ),
              ],
            ),
            onWillPop: () async {
              return !forceUpdate;
            },
          ),
        );
      }
    }
  }
}
