import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mask/models/api/feedback_option_response.dart';
import 'package:mask/models/api/store_feedback_store_response.dart';

class FeedbackDataCallback {
  final Function(DioError e) onFailure;
  final Function(dynamic e) onError;
  final Function(FeedbackData data, List<Option> options) onSuccess;

  FeedbackDataCallback({
    @required this.onFailure,
    @required this.onError,
    @required this.onSuccess,
  });
}
