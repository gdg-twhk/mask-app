import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ImageAssets {
  static const String basePath = 'assets/images';

  static const String gdgCloud = '$basePath/gdg-cloud.png';
  static const String gdgTaiwan = '$basePath/gdg-taiwan.png';
  static const String gdgTainan = '$basePath/gdg-tainan.png';

  static const String markerRed = '$basePath/marker_red.png';
  static const String markerYellow = '$basePath/marker_yellow.png';
  static const String markerGreen = '$basePath/marker_green.png';
  static const String markerGrey = '$basePath/marker_grey.png';
}

class MarkerIcon {
  static BitmapDescriptor red;

  static BitmapDescriptor yellow;

  static BitmapDescriptor green;

  static BitmapDescriptor grey;

  static Future<void> initMarker() async {
    red = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      ImageAssets.markerRed,
    );
    yellow = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      ImageAssets.markerYellow,
    );
    green = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      ImageAssets.markerGreen,
    );
    grey = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      ImageAssets.markerGrey,
    );
  }
}
