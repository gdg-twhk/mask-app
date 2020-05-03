class Constants {
  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static const PREF_LAST_ZOOM = "pref_last_ZOOM";
  static const PREF_LAST_CENTER = "pref_last_center";

  //only use iOS
  static const PREF_HAS_LOCATION_PERMISSION = "pref_has_location_permision";

  static const PREF_IS_GREEN_SHOW = "pref_is_green_show";
  static const PREF_IS_YELLOW_SHOW = "pref_is_yellow_show";
  static const PREF_IS_RED_SHOW = "pref_is_red_show";
  static const PREF_IS_GRAY_SHOW = "pref_is_gray_show";
  static const PREF_MAX_COUNT_INDEX = "pref_max_count_index";

  static const PREF_IS_CHILD_SHOW = "pref_is_child_show";
  static const PREF_IS_ADULT_SHOW = "pref_is_adult_show";

  static const PREF_LANGUAGE_CODE = 'pref_language_code';

  static const PREF_LATEST_NEWS_ID = "pref_latest_news_id";

  static const ANDROID_APP_VERSION = "android_app_version";
  static const IOS_APP_VERSION = "ios_app_version";
  static const APP_VERSION = "app_version";
  static const FORCE_UPDATE = 'force_update';

  static const GREEN_MINI_COUNT = "green_mini_count";
  static const YELLOW_MINI_COUNT = "yellow_mini_count";
  static const GREY_MINI_COUNT = "grey_mini_count";

  static const IS_SHOW_LINKS = "is_show_links";

  static const NEWS_DATA = 'news_data';
}
