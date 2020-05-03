import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mask/models/api/mask.dart';
import 'package:mask/models/new_response.dart';

class NewsDataCallback {
  final Function(dynamic e) onError;
  final Function(List<News> news) onSuccess;

  NewsDataCallback({
    @required this.onError,
    @required this.onSuccess,
  });
}
