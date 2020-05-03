import 'package:flutter/material.dart';
import 'package:mask/api/helper.dart';
import 'package:mask/config/constants.dart';
import 'package:mask/models/callback/news_data_callback.dart';
import 'package:mask/models/new_response.dart';
import 'package:mask/pages/news/news_content_page.dart';
import 'package:mask/res/app_color.dart';
import 'package:mask/utils/app_localizations.dart';
import 'package:mask/utils/firebase_analytics_utils.dart';
import 'package:mask/utils/preferences.dart';
import 'package:mask/utils/utils.dart';

class NewsListPage extends StatefulWidget {
  @override
  _NewsListPageState createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  AppLocalizations app;

  List<News> newsList = [];

  @override
  void initState() {
    _getNews();
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
      body: ListView.separated(
        itemBuilder: (_, index) {
          final news = newsList[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewsContentPage(
                    news: news,
                  ),
                ),
              );
              FA.logEvent('show_news_content_click');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
//                Image.network(
//                  news.imageUrl,
//                  fit: BoxFit.fitHeight,
//                  height: 200.0,
//                ),
                  SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      news.dateTime,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) {
          return Divider(
            color: AppColors.gray,
          );
        },
        itemCount: newsList.length,
      ),
    );
  }

  void _getNews() {
    Helper.instance.getNewsData(
      callback: NewsDataCallback(
        onSuccess: (List<News> news) {
          final latestId =
              Preferences.getString(Constants.PREF_LATEST_NEWS_ID, '0');
          if (news.length != 0) {
            setState(() {
              newsList = news;
            });
          }
        },
        onError: (e) {
          Utils.showToast(context, app.unknownError);
          throw e;
        },
      ),
    );
  }
}
