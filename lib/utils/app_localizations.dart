import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mask/config/constants.dart';
import 'package:mask/utils/firebase_analytics_utils.dart';
import 'package:mask/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  static const SYSTEM = 'system';
  static const ZH = 'zh';
  static const EN = 'en';

  AppLocalizations(Locale locale) {
    init(locale);
  }

  Map get _vocabularies {
    return _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  }

  String get appName => _vocabularies['app_name'];

  String get updateNoteTitle => _vocabularies['update_note_title'];

  String get updateNoteContent => _vocabularies['update_note_content'];

  String get updateContent {
    if (Platform.isAndroid)
      return updateAndroidContent;
    else if (Platform.isIOS)
      return updateIOSContent;
    else
      return _vocabularies['update_content'];
  }

  String get updateAndroidContent => _vocabularies['update_android_content'];

  String get updateIOSContent => _vocabularies['update_ios_content'];

  String get updateTitle => _vocabularies['update_title'];

  String get update => _vocabularies['update'];

  String get skip => _vocabularies['skip'];

  String get updateTime => _vocabularies['update_time'];

  String get version => _vocabularies['version'];

  String get unknownError => _vocabularies['unknown_error'];

  String get noInternetConnection => _vocabularies['no_internet_connection'];

  String get internalServerError => _vocabularies['internal_server_error'];

  String get connentionTimeout => _vocabularies['connection_timeout'];

  String get relatedLinks => _vocabularies['related_links'];

  String get relatedWorks => _vocabularies['related_works'];

  String get maximumSearchingAmount =>
      _vocabularies['maximum_searching_amount'];

  String get above => _vocabularies['above'];

  String get below => _vocabularies['below'];

  String get soldOut => _vocabularies['sold_out'];

  String get maskAdult => _vocabularies['mask_adult'];

  String get maskChildren => _vocabularies['mask_children'];

  String get locationNotFound => _vocabularies['location_not_found'];

  String get amountRange => _vocabularies['amount_range'];

  String get maskType => _vocabularies['mask_type'];

  String get diseaseControlCenter => _vocabularies['disease_control_center'];

  String get immigrationAgency => _vocabularies['immigration_agency'];

  String get educationMinistry => _vocabularies['education_ministry'];

  String get choseLanguageTitle => _vocabularies['chose_language_title'];

  String get language => _vocabularies['language'];

  String get systemLanguage => _vocabularies['system_language'];

  String get traditionalChinese => _vocabularies['traditional_chinese'];

  String get english => _vocabularies['english'];

  String get news => _vocabularies['news'];

  String get showMore => _vocabularies['show_more'];

  String get feedback => _vocabularies['feedback'];

  String get feedbackPageTitle => _vocabularies['feedback_page_title'];

  String get wantToFeedback => _vocabularies['want_to_feedback'];

  String get enterMessage => _vocabularies['enter_message'];

  String get send => _vocabularies['send'];

  String get success => _vocabularies['success'];

  String get feedbackEmptyHint => _vocabularies['feedback_empty_hint'];

  String get updateIn => _vocabularies['update_in'];

  String get storeList => _vocabularies['store_list'];

  static init(Locale locale) {
    AppLocalizations.locale = locale;
  }

  static Locale locale;
  static String languageCode = AppLocalizations.SYSTEM;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Mask Map',
      'update_note_title': 'Update Notes',
      'update_note_content': '',
      'update_content': 'Update available for Mask Map!',
      'update_android_content': 'Update available for Mask Map!',
      'update_ios_content': 'Update available for Mask Map!',
      'update_title': 'Updated',
      'update': 'Update',
      'update_time': 'Latest Updated time',
      'skip': 'Skip',
      'version': 'Version',
      'unknown_error': 'Unkown Error',
      'no_internet_connection': 'No Internet Connection',
      'internal_server_error': 'Internal Server Error',
      'connection_timeout': 'Connection Timeout',
      'location_not_found': 'Location Not Found',
      'related_links': 'Related links',
      'related_works': 'Related Works',
      'maximum_searching_amount': 'Maximum Searching Amount',
      'above': 'Above',
      'below': 'Below',
      'sold_out': 'Sold Out',
      'mask_adult': 'For Adult',
      'mask_children': 'For Children',
      'amount_range': 'Amount Range',
      'mask_type': 'Mask Type',
      'disease_control_center': 'Taiwan Centers for Disease Control',
      'immigration_agency': 'National Immigration Agency',
      'education_ministry': 'Ministry of Education',
      'language': 'Language',
      'chose_language_title': 'Language',
      'system_language': 'System Language',
      'traditional_chinese': '繁體中文',
      'english': 'English',
      'news': 'News',
      'show_more': 'Show More',
      'feedback': 'Feedback',
      'feedback_page_title': 'Feedback',
      'want_to_feedback': 'My Feedback',
      'enter_message': 'Enter Message',
      'send': 'Send',
      'success': 'Seccessful',
      'feedback_empty_hint': 'Not Feedbacks Yet\nBe the first to feedback',
      'update_in': 'Update in',
      'store_list': 'Nearby Pharmacy',
    },
    'zh': {
      'app_name': '即時口罩地圖',
      'update_note_title': '更新日誌',
      'update_note_content': '',
      'update_content': '即時口罩地圖 有新版本喲！',
      'update_android_content': '即時口罩地圖 在 Google Play 有新版本喲！',
      'update_ios_content': '即時口罩地圖 在 Apple store 有新版本喲！',
      'update_title': '版本更新',
      'update': '更新',
      'update_time': '最後更新時間',
      'skip': '略過',
      'version': '版本號',
      'unknown_error': '未知錯誤',
      'no_internet_connection': '無網路連線',
      'internal_server_error': '伺服器錯誤',
      'connection_timeout': '連線逾時',
      'location_not_found': '無法取得位置',
      'related_links': '相關連結',
      'related_works': '協作團隊作品',
      'maximum_searching_amount': '最大搜尋數量',
      'above': '超過',
      'below': '低於',
      'sold_out': '無庫存',
      'mask_adult': '成人口罩',
      'mask_children': '兒童口罩',
      'amount_range': '數量統計',
      'mask_type': '口罩種類',
      'disease_control_center': '衛生福利部疾病管制署',
      'immigration_agency': '內政部移民署',
      'education_ministry': '教育部',
      'language': '語言',
      'chose_language_title': '語言',
      'system_language': '系統語言',
      'traditional_chinese': '繁體中文',
      'english': 'English',
      'news': '最新消息',
      'show_more': '顯示更多',
      'feedback': '回報',
      'feedback_page_title': '回報系統',
      'want_to_feedback': '我要回報',
      'enter_message': '請輸入訊息',
      'send': '送出',
      'success': '成功',
      'feedback_empty_hint': '尚無回報\n成為第一個回報的人',
      'update_in': '更新於',
      'store_list': '附近藥局',
    },
  };
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    print('Load ${locale.languageCode}');
    String languageCode = Preferences.getString(
        Constants.PREF_LANGUAGE_CODE, AppLocalizations.SYSTEM);
    FA.setUserProperty('language', locale.languageCode);
    return AppLocalizations((languageCode == AppLocalizations.SYSTEM)
        ? locale
        : Locale(languageCode));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
