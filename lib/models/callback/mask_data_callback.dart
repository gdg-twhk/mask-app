import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mask/models/api/mask.dart';

class MaskDataCallback {
  final Function(DioError e) onFailure;
  final Function(dynamic e) onError;
  final Function(List<Mask> masks) onSuccess;

  MaskDataCallback({
    @required this.onFailure,
    @required this.onError,
    @required this.onSuccess,
  });
}
