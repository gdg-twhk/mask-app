import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mask/api/helper.dart';
import 'package:mask/config/config.dart';
import 'package:mask/config/constants.dart';
import 'package:mask/models/api/mask.dart';
import 'package:mask/models/api/mask_data_request.dart';
import 'package:mask/models/callback/mask_data_callback.dart';
import 'package:mask/models/callback/news_data_callback.dart';
import 'package:mask/models/new_response.dart';
import 'package:mask/pages/feedback/store_feed_back_page.dart';
import 'package:mask/pages/store/store_list_page.dart';
import 'package:mask/res/app_color.dart';
import 'package:mask/utils/firebase_analytics_utils.dart';
import 'package:mask/utils/preferences.dart';
import 'package:mask/utils/utils.dart';
import 'package:mask/utils/app_localizations.dart';
import 'package:mask/widgets/drawer_body.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'news/news_list_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const UPDATE_PERIOD_SECONDS = 60;

  Timer _timer;

  GoogleMapController mapController;
  Position _currentPosition;

  List<Mask> masks = [];

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  LatLng _center;
  LatLngBounds _bounds;
  AppLocalizations app;

  double _zoom;

  bool _isCameraMoving = false;

  var myLocationEnabled = true;

  var isGreenShow;
  var isYellowShow;
  var isRedShow;
  var isGrayShow;

  var maxCounts = [10, 30, 50];
  var maxCountIndex = 0;

  var panelController = PanelController();

  Mask currentMask;

  News _news;

  var _isShowFilter = false;
  var enableBlink = false;

  Position _userPosition;

  @override
  void initState() {
    var centerRawString = Preferences.getString(Constants.PREF_LAST_CENTER, '');
    if (centerRawString.isEmpty)
      _center = LatLng(24.0266018, 120.4878059);
    else {
      Point center = Point.fromRawJson(centerRawString);
      _center = LatLng(center.lat, center.lng);
    }
    _zoom = Preferences.getDouble(Constants.PREF_LAST_ZOOM, 13);
    if (!kIsWeb && Platform.isIOS) {
      myLocationEnabled =
          Preferences.getBool(Constants.PREF_HAS_LOCATION_PERMISSION, false);
    }
    isGreenShow = Preferences.getBool(Constants.PREF_IS_GREEN_SHOW, true);
    isYellowShow = Preferences.getBool(Constants.PREF_IS_YELLOW_SHOW, true);
    isRedShow = Preferences.getBool(Constants.PREF_IS_RED_SHOW, true);
    isGrayShow = Preferences.getBool(Constants.PREF_IS_GRAY_SHOW, false);
    MaskExtension.isAdultShow =
        Preferences.getBool(Constants.PREF_IS_ADULT_SHOW, true);
    MaskExtension.isChildShow =
        Preferences.getBool(Constants.PREF_IS_CHILD_SHOW, true);
    maxCountIndex = Preferences.getInt(Constants.PREF_MAX_COUNT_INDEX, 0);
    Utils.checkRemoteConfig(context);
    FA.setUserProperty('max_mark_counts', '${maxCounts[maxCountIndex]}');
    _getNews();
    super.initState();
  }

  @override
  void dispose() {
    if (mapController != null) {
      mapController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      drawer: DrawerBody(),
      appBar: AppBar(
        title: Text(app.appName),
        backgroundColor: AppColors.blue,
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (int value) {
              FA.logEvent('menu_button_click');
              if (value > 10) {
                setState(() {
                  switch (value) {
                    case 12:
                      Preferences.setString(
                          Constants.PREF_LANGUAGE_CODE, AppLocalizations.ZH);
                      AppLocalizations.languageCode = AppLocalizations.ZH;
                      break;
                    case 13:
                      Preferences.setString(
                          Constants.PREF_LANGUAGE_CODE, AppLocalizations.EN);
                      AppLocalizations.languageCode = AppLocalizations.EN;
                      break;
                    case 11:
                    default:
                      Preferences.setString(Constants.PREF_LANGUAGE_CODE,
                          AppLocalizations.SYSTEM);
                      AppLocalizations.languageCode = AppLocalizations.SYSTEM;
                      break;
                  }
                  AppLocalizations.locale =
                      (AppLocalizations.languageCode == AppLocalizations.SYSTEM)
                          ? Localizations.localeOf(context)
                          : Locale(AppLocalizations.languageCode);
                  FA.logEventType(
                      'change_language_mode', AppLocalizations.languageCode);
                });
              } else if (value >= 0) {
                maxCountIndex = value;
                Preferences.setInt(
                    Constants.PREF_MAX_COUNT_INDEX, maxCountIndex);
                _timer?.cancel();
                _timer = Timer.periodic(
                    Duration(seconds: UPDATE_PERIOD_SECONDS), _getMaskData);
                _getMaskData(_timer);
                FA.logEventNumber(
                    'change_max_mark_counts', maxCounts[maxCountIndex]);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Center(
                  child: Text(
                    app.maximumSearchingAmount,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                value: -1,
                enabled: false,
              ),
              PopupMenuDivider(
                height: 10,
              ),
              for (var i = 0; i < maxCounts.length; i++)
                _popupMenuItem(
                  value: i,
                  check: (i == maxCountIndex),
                  text: '${maxCounts[i]}',
                ),
              PopupMenuDivider(
                height: 5,
              ),
              PopupMenuItem(
                child: Center(
                  child: Text(
                    app.language,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                value: -1,
                enabled: false,
              ),
              PopupMenuDivider(
                height: 10,
              ),
              _popupMenuItem(
                value: 11,
                check:
                    (AppLocalizations.languageCode == AppLocalizations.SYSTEM),
                text: '${app.systemLanguage}',
              ),
              _popupMenuItem(
                value: 12,
                check: (AppLocalizations.languageCode == AppLocalizations.ZH),
                text: '${app.traditionalChinese}',
              ),
              _popupMenuItem(
                value: 13,
                check: (AppLocalizations.languageCode == AppLocalizations.EN),
                text: '${app.english}',
              ),
            ],
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (Platform.isAndroid) {
            if (panelController.isPanelOpen) {
              await panelController.close();
              return false;
            }
          }
          return true;
        },
        child: Stack(
          children: <Widget>[
            SlidingUpPanel(
              controller: panelController,
              minHeight: 165.0,
              maxHeight: 500.0,
              panelBuilder: (ScrollController sc) => GestureDetector(
                onTap: () {
                  panelController.open();
                },
                child: currentMask == null
                    ? _newsBottomSheet()
                    : _bottomSheet(currentMask, sc),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              onPanelOpened: () {
                setState(() {
                  _isShowFilter = false;
                });
                FA.logEvent('on_panel_opened');
              },
              body: Padding(
                padding: const EdgeInsets.only(bottom: 190.0),
                child: GoogleMap(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  onMapCreated: _onMapCreated,
                  // 我的位置按鈕
                  myLocationButtonEnabled: true,
                  // 呈現我的位置
                  myLocationEnabled: myLocationEnabled,
                  onCameraIdle: _onMapIdle,
                  onCameraMoveStarted: () {
                    panelController.close();
                    _timer?.cancel();
                    setState(() {
                      _isCameraMoving = true;
                      _isShowFilter = false;
                    });
                  },
                  onCameraMove: (CameraPosition position) {
                    _isCameraMoving = true;
                    _center = LatLng(
                        position.target.latitude, position.target.longitude);
                    _zoom = position.zoom;
                  },
                  onTap: (_) {
                    if (panelController.isPanelOpen) {
                      setState(() {
                        _isShowFilter = false;
                      });
                      panelController.close();
                    } else {
                      setState(() {
                        currentMask = null;
                      });
                    }
                    FA.logEvent('map_on_tap');
                  },
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: _zoom,
                  ),
                  markers: Set<Marker>.of(_markers.values),
                ),
              ),
            ),
            _storeListButton(),
            _filterButton(),
          ],
        ),
      ),
    );
  }

  _storeListButton() {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isTablet = shortestSide >= 600;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment(-0.9, -0.7),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 12.0,
              borderRadius: BorderRadius.all(
                Radius.circular(36.0),
              ),
              child: IconButton(
                onPressed: () {
                  _navigateStoreListPage(context);
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => StoreListPage(masks),
                  //   ),
                  // );
                },
                icon: Icon(
                  Icons.view_list,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _navigateStoreListPage(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => StoreListPage(masks)),
    );

    if (result != null) {
      currentMask = result;
      panelController.show();

      final CameraPosition storePosition = CameraPosition(
        target: LatLng(result.latitude, result.longitude),
        zoom: _zoom,
      );
      mapController
          .animateCamera(CameraUpdate.newCameraPosition(storePosition));
    }
  }

  _filterButton() {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isTablet = shortestSide >= 600;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment(-0.9, -0.9),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 12.0,
              borderRadius: BorderRadius.all(
                Radius.circular(36.0),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isShowFilter = !_isShowFilter;
                  });
                  panelController.close();
                  FA.logEvent('filter_button_click');
                },
                icon: Icon(
                  Icons.layers,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: _isShowFilter ? (isTablet ? width * 0.4 : width * 0.7) : 0.0,
            height: _isShowFilter ? 260 : 0.0,
            child: Card(
              elevation: 16.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        app.amountRange,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8.0),
                      _filterWidget(),
                      SizedBox(height: 8.0),
                      Text(
                        app.maskType,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8.0),
                      _filterMaskWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _filterWidget() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: <Widget>[
          _filterItem(
            text: '${app.above} 50%',
            color: isGreenShow ? AppColors.green : AppColors.selectedGreen,
            isSelected: isGreenShow,
            onTap: () {
              setState(() {
                isGreenShow = !isGreenShow;
              });
              Preferences.setBool(Constants.PREF_IS_GREEN_SHOW, isGreenShow);
              updateMarker();
              FA.logEvent('filter_green_click');
            },
          ),
          _filterItem(
            text: '${app.below} 20%',
            color: isRedShow ? AppColors.red : AppColors.selectedRed,
            isSelected: isRedShow,
            onTap: () {
              setState(() {
                isRedShow = !isRedShow;
              });
              Preferences.setBool(Constants.PREF_IS_RED_SHOW, isRedShow);
              updateMarker();
              FA.logEvent('filter_red_click');
            },
          ),
          _filterItem(
            text: '20% ~ 50%',
            color: isYellowShow ? AppColors.yellow : AppColors.selectedYellow,
            isSelected: isYellowShow,
            onTap: () {
              setState(() {
                isYellowShow = !isYellowShow;
              });
              Preferences.setBool(Constants.PREF_IS_YELLOW_SHOW, isYellowShow);
              updateMarker();
              FA.logEvent('filter_yellow_click');
            },
          ),
          _filterItem(
            text: app.soldOut,
            color: isGrayShow ? AppColors.gray : AppColors.selectedGray,
            isSelected: isGrayShow,
            onTap: () {
              setState(() {
                isGrayShow = !isGrayShow;
              });
              Preferences.setBool(Constants.PREF_IS_GRAY_SHOW, isGrayShow);
              updateMarker();
              FA.logEvent('filter_gray_click');
            },
          ),
        ],
      ),
    );
  }

  _filterMaskWidget() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: <Widget>[
          _filterItem(
            text: app.maskAdult,
            color: MaskExtension.isAdultShow
                ? AppColors.green
                : AppColors.selectedGreen,
            isSelected: MaskExtension.isAdultShow,
            onTap: () {
              setState(() {
                MaskExtension.isAdultShow = !MaskExtension.isAdultShow;
              });
              Preferences.setBool(
                  Constants.PREF_IS_ADULT_SHOW, MaskExtension.isAdultShow);
              updateMarker();
              FA.logEvent('filter_adult_click');
            },
          ),
          _filterItem(
            text: app.maskChildren,
            color: MaskExtension.isChildShow
                ? AppColors.yellow
                : AppColors.selectedYellow,
            isSelected: MaskExtension.isChildShow,
            onTap: () {
              setState(() {
                MaskExtension.isChildShow = !MaskExtension.isChildShow;
              });
              Preferences.setBool(
                  Constants.PREF_IS_CHILD_SHOW, MaskExtension.isChildShow);
              updateMarker();
              FA.logEvent('filter_child_click');
            },
          ),
        ],
      ),
    );
  }

  _filterItem({
    @required String text,
    @required Color color,
    @required bool isSelected,
    @required Function onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 3,
            color: Colors.transparent,
          ),
          color: color,
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Text(
          text,
          overflow: TextOverflow.fade,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  PopupMenuEntry<int> _popupMenuItem({
    @required int value,
    @required bool check,
    @required String text,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: check
                ? Icon(
                    Icons.check,
                    color: AppColors.blue,
                  )
                : Container(),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                text,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    if (!myLocationEnabled) {
      await _requestLocationPermission();
      await FirebaseMessaging().requestNotificationPermissions(
        const IosNotificationSettings(
          sound: true,
          badge: true,
          alert: true,
        ),
      );
    }
    if (_currentPosition == null) {
      _getCurrentLocation();
    } else {
      _center = LatLng(_currentPosition.latitude, _currentPosition.longitude);
    }
  }

  void _onMapIdle() async {
    print('_onMapIdle $_isCameraMoving');
    _isCameraMoving = false;
    Future.delayed(Duration(milliseconds: 300)).then(
      (onValue) async {
        if (!_isCameraMoving) {
          Preferences.setDouble(Constants.PREF_LAST_ZOOM, _zoom);
          Preferences.setString(
            Constants.PREF_LAST_CENTER,
            Point(
              lat: _center.latitude,
              lng: _center.longitude,
            ).toRawJson(),
          );
          print("~~~~ search");
          this._bounds = await mapController.getVisibleRegion();
          _timer = Timer.periodic(
              Duration(seconds: UPDATE_PERIOD_SECONDS), _getMaskData);
          _getMaskData(_timer);
        }
      },
    );
  }

  // 取得裝置當前的座標
  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(
        () {
          _currentPosition = position;
          _userPosition = position;
          print("~~~~location:${position.latitude}, ${position.longitude}");

          Future.delayed(Duration(milliseconds: 500)).then(
            (onValue) => mapController.moveCamera(
              CameraUpdate.newLatLngZoom(
                  LatLng(_currentPosition.latitude, _currentPosition.longitude),
                  15),
            ),
          );
        },
      );
    }).catchError((e) {
      print(e);
    });
  }

  Widget _newsBottomSheet() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 24.0),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  app.news,
                  style: TextStyle(fontSize: 20.0, color: Colors.grey),
                  maxLines: 1,
                ),
              ),
              FloatingActionButton.extended(
                heroTag: 11,
                label: Text(
                  app.showMore,
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NewsListPage(),
                    ),
                  );
                  FA.logEvent('show_more_click');
                },
                backgroundColor: AppColors.blue,
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Text(
            _news?.title ?? '',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.clip,
            maxLines: 2,
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => Scaffold(
                      body: PhotoView(
                        imageProvider:
                            (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                                ? CachedNetworkImageProvider(_news.imageUrl)
                                : NetworkImage(_news.imageUrl),
                      ),
                    ),
                  ),
                );
              },
              child: (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                  ? CachedNetworkImage(
                      imageUrl: _news?.imageUrl ?? '',
                      fit: BoxFit.fitHeight,
                    )
                  : Image.network(
                      _news?.imageUrl ?? '',
                      fit: BoxFit.fitHeight,
                    ),
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _bottomSheet(Mask mask, ScrollController _controller) {
    return ListView(
      controller: _controller,
      children: <Widget>[
        Center(
          child: Container(
            height: 4.0,
            width: 32.0,
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                width: 3,
                color: AppColors.gray,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
              color: AppColors.gray,
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.store,
            size: 24.0,
          ),
          trailing: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => StoreFeedBackPage(
                    mask: mask,
                    userPosition: _userPosition,
                  ),
                ),
              );
              FA.logEvent('open_feedback_page');
            },
            label: Text(app.feedback),
            backgroundColor: AppColors.blue,
          ),
//            Material(
//              color: Colors.white,
//              child: IconButton(
//                onPressed: () {
//                  _timer?.cancel();
//                  _timer = Timer.periodic(
//                      Duration(seconds: UPDATE_PERIOD_SECONDS), _getMaskData);
//                  _getMaskData(_timer);
//                  FA.logEvent('refresh_click');
//                },
//                icon: Icon(Icons.report),
//              ),
//            ),
          title: Text(mask?.name ?? ''),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 4.0,
              ),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: mask?.adultColor ?? AppColors.gray,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: Text("${app.maskAdult}: ${mask?.maskAdult ?? 0}"),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 4.0,
              ),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: mask?.childColor ?? AppColors.gray,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: Text("${app.maskChildren}: ${mask?.maskChild ?? 0}"),
            )
          ],
        ),
        ListTile(
          title: Text("${app.updateIn} ${mask?.beforeTime ?? ''}"),
        ),
        ListTile(
          leading: Icon(
            Icons.location_on,
            size: 24.0,
          ),
          title: Text(mask?.address ?? ''),
          onTap: () {
            if (mask != null)
              openMapNavigation(
                Point(
                  lat: mask.latitude,
                  lng: mask.longitude,
                ),
              );
            FA.logEvent('map_navigation_click');
          },
        ),
        ListTile(
          leading: Icon(
            Icons.phone,
            size: 24.0,
          ),
          title: Text(mask?.phone ?? ''),
          onTap: () async {
            FA.logEvent('call_phone_click');
            var url = 'tel:${mask?.phone?.replaceAll(' ', '') ?? ''}';
            print(url);
            if (await canLaunch(url)) {
              await launch(url);
            }
          },
        ),
        ListTile(
          leading: Icon(
            Icons.note,
            size: 24.0,
          ),
          title: Text(mask?.note ?? ''),
          onTap: () {
            FA.logEvent('note_click');
          },
        ),
      ],
    );
  }

  void _getMaskData(Timer timer) async {
    if (this._bounds == null) {
      this._bounds = await mapController.getVisibleRegion();
    }
    Helper.instance.getMaskData(
      maskDataRequest: MaskDataRequest(
        center: Point(
          lat: _center.latitude,
          lng: _center.longitude,
        ),
        bounds: Bounds(
          northEast: Point(
            lat: _bounds.northeast.latitude,
            lng: _bounds.northeast.longitude,
          ),
          southEast: Point(
            lat: _bounds.southwest.latitude,
            lng: _bounds.northeast.longitude,
          ),
          southWest: Point(
            lat: _bounds.southwest.latitude,
            lng: _bounds.southwest.longitude,
          ),
          northWest: Point(
            lat: _bounds.northeast.latitude,
            lng: _bounds.southwest.longitude,
          ),
        ),
        max: maxCounts[maxCountIndex],
      ),
      callback: MaskDataCallback(
        onSuccess: (List<Mask> masks) {
          print('onSuccess ${masks.length}');
          this.masks = masks;
          updateMarker();
        },
        onError: (e) {
          Utils.showToast(context, app.unknownError);
          throw e;
        },
        onFailure: (DioError e) {
          switch (e.type) {
            case DioErrorType.DEFAULT:
              Utils.showToast(context, app.noInternetConnection);
              break;
            case DioErrorType.CONNECT_TIMEOUT:
            case DioErrorType.SEND_TIMEOUT:
            case DioErrorType.RECEIVE_TIMEOUT:
              Utils.showToast(context, app.connentionTimeout);
              break;
            case DioErrorType.RESPONSE:
              print(e.message);
              Utils.showToast(context, app.internalServerError);
              break;
            case DioErrorType.CANCEL:
              break;
          }
        },
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    await Future.delayed(Duration(seconds: 1));
    if (!kIsWeb) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions([
        PermissionGroup.location,
        PermissionGroup.locationAlways,
        PermissionGroup.locationWhenInUse
      ]);
      if (permissions[PermissionGroup.location] == PermissionStatus.granted ||
          permissions[PermissionGroup.locationAlways] ==
              PermissionStatus.granted ||
          permissions[PermissionGroup.locationWhenInUse] ==
              PermissionStatus.granted) {
        setState(() {
          myLocationEnabled = true;
        });
        Preferences.setBool(Constants.PREF_HAS_LOCATION_PERMISSION, true);
        _getCurrentLocation();
      } else {
        Utils.showToast(context, app.locationNotFound);
        Preferences.setBool(Constants.PREF_HAS_LOCATION_PERMISSION, false);
      }
    }
  }

  void openMapNavigation(Point point) async {
    final lat = point.lat, lng = point.lng;
    String googleiOSUrl = 'comgooglemaps://?daddr=$lat,$lng';
    String appleUrl = 'https://maps.apple.com/?sll=$lat,$lng';
    String androidApp = 'google.navigation:q=$lat,$lng';
    if (await canLaunch(androidApp)) {
      await launch(androidApp);
    } else if (await canLaunch(googleiOSUrl)) {
      await launch(googleiOSUrl);
    } else if (await canLaunch(appleUrl)) {
      await launch(appleUrl);
    } else {
      throw 'Could not launch url';
    }
  }

  void updateMarker() {
    _markers.clear();
    masks.forEach((mask) {
      if (currentMask != null && currentMask.id == mask.id) currentMask = mask;
      final Marker marker = Marker(
        markerId: MarkerId('${mask.id}'),
        position: LatLng(mask.latitude, mask.longitude),
        icon: mask.marker,
        onTap: () {
          currentMask = mask;
          panelController.show();
        },
      );
      bool isShow = true;
      var count = (MaskExtension.isChildShow ? mask.maskChild : 0) +
          (MaskExtension.isAdultShow ? mask.maskAdult : 0);
      if (count >= Config.greenMiniCount) {
        isShow = isGreenShow;
      } else if (count >= Config.yellowMiniCount) {
        isShow = isYellowShow;
      } else if (count > Config.greyMiniCount) {
        isShow = isRedShow;
      } else {
        isShow = isGrayShow;
      }
      if (mapController != null && isShow) {
        _markers[marker.markerId] = marker;
      }
    });
    setState(() {});
  }

  void _getNews() {
    Helper.instance.getNewsData(
      callback: NewsDataCallback(
        onSuccess: (List<News> news) {
          final latestId =
              Preferences.getString(Constants.PREF_LATEST_NEWS_ID, '0');
          if (news.length != 0) {
            if (latestId != news.first.id) {
              Preferences.setString(
                Constants.PREF_LATEST_NEWS_ID,
                news.first.id,
              );
              enableBlink = true;
            }
            setState(() {
              _news = news.first;
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
