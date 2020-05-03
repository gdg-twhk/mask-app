import 'dart:async';

import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:mask/config/constants.dart';
import 'package:mask/models/api/feedback.dart';
import 'package:mask/models/api/feedback_option_response.dart';
import 'package:mask/models/api/mask.dart';
import 'package:mask/models/api/mask_data_request.dart';
import 'package:mask/models/api/pharmacies_response.dart';
import 'package:mask/models/api/store_feedback_store_response.dart';
import 'package:mask/models/callback/feedback_options_callback.dart';
import 'package:mask/models/callback/general_callback.dart';
import 'package:mask/models/callback/mask_data_callback.dart';
import 'package:mask/models/callback/news_data_callback.dart';
import 'package:mask/models/callback/feedback_data_callback.dart';
import 'package:mask/models/new_response.dart';

class Helper {
  static const String HOST = "mask-9999.appspot.com";

  static const int PORT = 443;

  static const String API_URL = "https://$HOST:$PORT";

  static const String API_STORE = "/api/pharmacies";

  static const String API_FEEDBACK_OPTIONS = "/api/feedback/options";
  static const String API_FEEDBACK = "/api/feedback";
  static const String API_FEEDBACK_STORE = "/api/feedback/pharmacies";
  static const String API_FEEDBACK_USER = "/api/feedback/users";

  static Helper _instance;
  static BaseOptions options;
  static Dio dio;
  static CancelToken cancelToken;

  static String username;
  static String password;

  static Helper get instance {
    if (_instance == null) {
      _instance = Helper();
      cancelToken = CancelToken();
    }
    return _instance;
  }

  Helper() {
    options = BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 10000,
    );
    dio = Dio(options);
  }

  static resetInstance() {
    _instance = Helper();
    cancelToken = CancelToken();
  }

  Future<void> getMaskData({
    @required MaskDataRequest maskDataRequest,
    @required MaskDataCallback callback,
  }) async {
    try {
      var response = await dio.post(
        '$API_URL$API_STORE',
        data: maskDataRequest.toJson(),
      );
      var pharmaciesResponse = PharmaciesResponse.fromJson(response.data);
      var data = pharmaciesResponse?.data?.items;
      if (data != null)
        callback.onSuccess(data);
      else
        callback.onError('api error');
    } on DioError catch (dioError) {
      callback.onFailure(dioError);
    } catch (e) {
      callback.onError(e);
    }
  }

  Future<void> getNewsData({
    @required NewsDataCallback callback,
  }) async {
    try {
      final RemoteConfig remoteConfig = await RemoteConfig.instance;
      await remoteConfig.fetch(
        expiration: const Duration(seconds: 10),
      );
      await remoteConfig.activateFetched();
      var newsResponse = NewsResponse.fromRawJson(
        remoteConfig.getString(Constants.NEWS_DATA),
      );
      var data = newsResponse?.data?.items;
      if (data != null)
        callback.onSuccess(data);
      else
        callback.onError('api error');
    } catch (e) {
      callback.onError(e);
    }
  }

  Future<void> getFeedBackOptions({
    @required FeedbackOptionsCallback callback,
  }) async {
    try {
      var response = await dio.get(
        '$API_URL$API_FEEDBACK_OPTIONS',
      );
      var feedBackOptionResponse =
          FeedbackOptionResponse.fromJson(response.data);
      var data = feedBackOptionResponse?.data?.items;
      if (data != null)
        callback.onSuccess(data);
      else
        callback.onError('api error');
    } on DioError catch (dioError) {
      callback.onFailure(dioError);
    } catch (e) {
      callback.onError(e);
    }
  }

  Future<List<Option>> getOptions() async {
    var response = await dio.get(
      '$API_URL$API_FEEDBACK_OPTIONS',
    );
    var feedBackOptionResponse = FeedbackOptionResponse.fromJson(response.data);
    return feedBackOptionResponse?.data?.items;
  }

  Future<void> sendFeedback({
    @required UserFeedback feedback,
    @required GeneralCallback callback,
  }) async {
    try {
      var response = await dio.post(
        '$API_URL$API_FEEDBACK',
        data: feedback.toJson(),
      );
      if (response.data != null)
        callback.onSuccess();
      else
        callback.onError('api error');
    } on DioError catch (dioError) {
      callback.onFailure(dioError);
    } catch (e) {
      callback.onError(e);
    }
  }

  Future<void> getStoreFeedBack({
    @required String storeId,
    @required DateTime date,
    @required int offset,
    @required int limit,
    @required FeedbackDataCallback callback,
  }) async {
    try {
      final format = DateFormat('yyyy_MMdd');
      var response = await dio.get(
        '$API_URL$API_FEEDBACK_STORE/$storeId?'
        'date=${format.format(date)}&'
        'offset=$offset&'
        'limit=$limit',
      );
      var pharmaciesResponse = FeedbackDataResponse.fromJson(response.data);
      var options = await getOptions();
      if (pharmaciesResponse?.data?.items != null)
        callback.onSuccess(pharmaciesResponse?.data, options);
      else
        callback.onError('api error');
    } on DioError catch (dioError) {
      callback.onFailure(dioError);
    } catch (e) {
      callback.onError(e);
    }
  }

  Future<void> getUserFeedBack({
    @required String userId,
    @required DateTime date,
    @required int offset,
    @required int limit,
    @required FeedbackDataCallback callback,
  }) async {
    try {
      final format = DateFormat('yyyy_MMdd');
      var response = await dio.get(
        '$API_URL$API_FEEDBACK_USER/$userId?'
        'date=${format.format(date)}&'
        'offset=$offset&'
        'limit=$limit',
      );
      var pharmaciesResponse = FeedbackDataResponse.fromJson(response.data);
      var data = pharmaciesResponse?.data?.items;
      var options = await getOptions();
      if (data != null && options != null)
        callback.onSuccess(pharmaciesResponse?.data, options);
      else
        callback.onError('api error');
    } on DioError catch (dioError) {
      callback.onFailure(dioError);
    } catch (e) {
      callback.onError(e);
    }
  }

  static example() {
    Helper.instance.getMaskData(
      maskDataRequest: MaskDataRequest(
        center: Point(
          lat: 24.1471183,
          lng: 120.60848320000001,
        ),
        bounds: Bounds(
          northEast: Point(
            lat: 24.155508090745688,
            lng: 120.61994159691163,
          ),
          southEast: Point(
            lat: 24.13872795846499,
            lng: 120.61994159691163,
          ),
          southWest: Point(
            lat: 24.13872795846499,
            lng: 120.59702480308839,
          ),
          northWest: Point(
            lat: 24.155508090745688,
            lng: 120.59702480308839,
          ),
        ),
        max: 10,
      ),
      callback: MaskDataCallback(
        onSuccess: (List<Mask> masks) {
          print('onSuccess ${masks.length}');
          masks.forEach((m) {
            print(m.name);
          });
        },
        onError: (e) {
          print('unkown error');
          throw e;
        },
        onFailure: (DioError e) {
          switch (e.type) {
            case DioErrorType.CONNECT_TIMEOUT:
            case DioErrorType.SEND_TIMEOUT:
            case DioErrorType.RECEIVE_TIMEOUT:
              print('timeout');
              break;
            case DioErrorType.RESPONSE:
            case DioErrorType.DEFAULT:
              print(e.message);
              print('api error');
              break;
            case DioErrorType.CANCEL:
              break;
          }
        },
      ),
    );
  }
}
