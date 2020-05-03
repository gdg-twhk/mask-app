import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mask/api/helper.dart';
import 'package:mask/config/constants.dart';
import 'package:mask/models/callback/news_data_callback.dart';
import 'package:mask/models/new_response.dart';
import 'package:mask/res/app_color.dart';
import 'package:mask/utils/app_localizations.dart';
import 'package:mask/utils/preferences.dart';
import 'package:mask/utils/utils.dart';

class NewsContentPage extends StatefulWidget {
  final News news;

  const NewsContentPage({Key key, this.news}) : super(key: key);

  @override
  _NewsContentPageState createState() => _NewsContentPageState();
}

class _NewsContentPageState extends State<NewsContentPage> {
  AppLocalizations app;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.news),
        backgroundColor: AppColors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                widget.news.title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.0),
              (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                  ? CachedNetworkImage(
                      imageUrl: widget.news.imageUrl,
                    )
                  : Image.network(
                      widget.news.imageUrl,
                    ),
              SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.news.dateTime,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                widget.news.content,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
