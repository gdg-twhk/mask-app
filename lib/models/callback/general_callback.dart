import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GeneralCallback {
  final Function(DioError e) onFailure;
  final Function(dynamic e) onError;
  final Function() onSuccess;

  GeneralCallback({
    @required this.onFailure,
    @required this.onError,
    @required this.onSuccess,
  });
}
