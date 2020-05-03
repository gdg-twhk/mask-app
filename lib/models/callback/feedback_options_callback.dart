import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mask/models/api/feedback_option_response.dart';

class FeedbackOptionsCallback {
  final Function(DioError e) onFailure;
  final Function(dynamic e) onError;
  final Function(List<Option> masks) onSuccess;

  FeedbackOptionsCallback({
    @required this.onFailure,
    @required this.onError,
    @required this.onSuccess,
  });
}
