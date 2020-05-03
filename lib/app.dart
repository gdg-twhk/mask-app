import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mask/pages/home_page.dart';
import 'package:mask/utils/app_localizations.dart';
import 'package:mask/utils/firebase_analytics_utils.dart';
import 'package:mask/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'config/constants.dart';

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics;
  FirebaseMessaging firebaseMessaging;
  String userId;

  @override
  void initState() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      FA.analytics = analytics = FirebaseAnalytics();
      firebaseMessaging = FirebaseMessaging();
      _initFCM();
    }
    _firebaseAnonymouslySignIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        return locale;
      },
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('zh', 'TW'), // Chinese
      ],
      navigatorObservers: (!kIsWeb && (Platform.isIOS || Platform.isAndroid))
          ? [
              FirebaseAnalyticsObserver(analytics: analytics),
            ]
          : [],
      home: HomePage(),
    );
  }

  void _initFCM() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (Constants.isInDebugMode) print("onMessage: $message");
        Utils.showFCMNotification(
          message['notification']['title'] ?? '',
          message['notification']['title'] ?? '',
          message['notification']['body'] ?? '',
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (Constants.isInDebugMode) print("onLaunch: $message");
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        if (Constants.isInDebugMode) print("onResume: $message");
      },
    );
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    firebaseMessaging.getToken().then((String token) {
      if (token == null) return;
      if (Constants.isInDebugMode) {
        print("Push Messaging token: $token");
      }
    });
  }

  void _firebaseAnonymouslySignIn() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var result = await _auth.signInAnonymously();
    userId = result.user.uid;
  }
}
