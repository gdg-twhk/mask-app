import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mask/config/config.dart';
import 'package:mask/res/app_color.dart';
import 'package:mask/res/assets.dart';
import 'package:mask/utils/firebase_analytics_utils.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mask/utils/app_localizations.dart';

class DrawerBody extends StatefulWidget {
  @override
  _DrawerBodyState createState() => _DrawerBodyState();
}

AppLocalizations app;

class _DrawerBodyState extends State<DrawerBody> {
  var version = '';

  @override
  void initState() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _getVersion();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  app.appName,
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Text(
                  '${app.version}: v$version',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(color: AppColors.blue),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      app.relatedWorks,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  _urlItemOutside(
                    icon: Icons.web_asset,
                    title: '即時口罩查詢網站',
                    url: 'https://mask.goodideas-studio.com/',
                  ),
                  if (Config.isShowLinks) ...[
                    _urlItemOutside(
                      icon: Icons.assistant,
                      title: '口罩配',
                      url:
                          'https://assistant.google.com/services/a/uid/0000008dad963124',
                    ),
                    _urlItemOutside(
                      icon: Icons.speaker,
                      title: '口罩君',
                      url:
                          'https://assistant.google.com/services/a/uid/000000c92c808e9a',
                    ),
                    _urlItemOutside(
                      icon: Icons.perm_camera_mic,
                      title: '防疫機器人',
                      url:
                          'https://assistant.google.com/services/a/uid/0000003a4c53f3c6',
                    ),
                  ]
//                  Padding(
//                    padding: const EdgeInsets.all(12.0),
//                    child: Text(
//                      app.relatedLinks,
//                      style: TextStyle(color: Colors.grey),
//                    ),
//                  ),
//                  _urlItem(
//                    icon: Icons.account_balance,
//                    title: app.diseaseControlCenter,
//                    url: 'https://www.cdc.gov.tw/',
//                  ),
//                  _urlItem(
//                    icon: Icons.public,
//                    title: app.immigrationAgency,
//                    url: 'https://www.immigration.gov.tw/',
//                  ),
//                  _urlItem(
//                    icon: Icons.school,
//                    title: app.educationMinistry,
//                    url: 'https://www.edu.tw/',
//                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.grey[300],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//                Align(
//                  alignment: Alignment(0.15, 0),
//                  child: Padding(
//                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
//                    child: Image.asset(
//                      ImageAssets.gdgTaiwan,
//                      height: 65.0,
//                    ),
//                  ),
//                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'sponsored by',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    ImageAssets.gdgCloud,
                    height: 53.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '© 2020 GDG | GDG Cloud @Taiwan',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 10.0)
              ],
            ),
          ),
        ],
      ),
    );
  }

  _urlItem({
    @required IconData icon,
    @required String title,
    @required String url,
  }) =>
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
        leading: Icon(icon),
        title: Text(title),
        onTap: () async {
          FA.logEventType('related_link_click', url);
          launch(url);
        },
      );

  _urlItemOutside({
    @required IconData icon,
    @required String title,
    @required String url,
  }) =>
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
        leading: Icon(icon),
        trailing: Icon(Icons.exit_to_app),
        title: Text(title),
        onTap: () async {
          FA.logEventType('related_work_click', title);
          launch(url);
        },
      );

  void _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }
}
