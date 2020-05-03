import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mask/api/helper.dart';
import 'package:mask/models/api/feedback.dart';
import 'package:mask/models/api/feedback_option_response.dart';
import 'package:mask/models/api/mask.dart';
import 'package:mask/models/api/store_feedback_store_response.dart';
import 'package:mask/models/callback/feedback_data_callback.dart';
import 'package:mask/models/callback/general_callback.dart';
import 'package:mask/res/app_color.dart';
import 'package:mask/utils/app_localizations.dart';
import 'package:mask/utils/firebase_analytics_utils.dart';
import 'package:mask/utils/utils.dart';

enum _State { loading, finish, loadingMore }

class StoreFeedBackPage extends StatefulWidget {
  final Mask mask;
  final Position userPosition;

  const StoreFeedBackPage({Key key, @required this.mask, this.userPosition})
      : super(key: key);

  @override
  _StoreFeedBackPageState createState() => _StoreFeedBackPageState();
}

class _StoreFeedBackPageState extends State<StoreFeedBackPage> {
  static const CUSTOM_ID = 'IRESxM58KC~dqg5XLCH~n';
  static const UPDATE_PERIOD_SECONDS = 30;

  AppLocalizations app;

  Timer _timer;

  String userId;
  List<UserFeedback> feedbackList;

  ScrollController _scrollController;

  var _controller = TextEditingController();

  List<Option> options;

  Option currentOption;

  bool isSending = false;

  Position position;

  int offset = 0;
  int limit = 10;

  _State state = _State.loading;

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_scrollListener);
    _timer = Timer.periodic(
        Duration(seconds: UPDATE_PERIOD_SECONDS), _getStoreFeedback);
    _getStoreFeedback(_timer);
    position = widget.userPosition;
    _getUserPosition();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${app.feedbackPageTitle} - ${widget.mask.name}'),
        backgroundColor: AppColors.blue,
      ),
      body: feedbackList == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: (feedbackList.length == 0)
                      ? Center(
                          child: Text(
                            app.feedbackEmptyHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          itemBuilder: (BuildContext context, int index) {
                            final UserFeedback feedback = feedbackList[index];
                            final optionText =
                                _getOptionString(feedback.optionId);
                            return optionText == null
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          (userId == feedback.userId)
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Card(
                                          elevation: 8.0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              feedback.optionId == CUSTOM_ID
                                                  ? feedback.description ?? ''
                                                  : _getOptionString(
                                                      feedback.optionId),
                                              style: TextStyle(fontSize: 18.0),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          feedback.time ?? '',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                          },
                          itemCount: feedbackList.length,
                        ),
                ),
                BottomAppBar(
                  elevation: 8.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 12.0),
                      Text(
                        app.wantToFeedback,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: <Widget>[
                                  for (var option in options) ...[
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          currentOption = option;
                                        });
                                      },
                                      child: Chip(
                                        label: Text(
                                          option.name ?? '',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor:
                                            (currentOption?.id ?? '') ==
                                                    option.id
                                                ? AppColors.selectedYellow
                                                : AppColors.yellow,
                                      ),
                                    ),
                                    SizedBox(width: 4.0),
                                  ]
                                ],
                              ),
                            ),
                          ),
                          if ((currentOption?.id ?? '') != CUSTOM_ID)
                            _sendButton()
                        ],
                      ),
                      if ((currentOption?.id ?? '') == CUSTOM_ID)
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: app.enterMessage,
                                    counterText: '',
                                  ),
                                  controller: _controller,
                                  maxLength: 100,
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                            ),
                            _sendButton(),
                          ],
                        )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sendButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FloatingActionButton.extended(
        heroTag: 11,
        label: isSending
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                app.send,
                style: TextStyle(
                  color: (isSending || currentOption == null)
                      ? Colors.white70
                      : Colors.white,
                ),
              ),
        onPressed: (isSending || currentOption == null)
            ? null
            : () async {
                setState(() {
                  isSending = true;
                });
                _timer?.cancel();
                Helper.instance.sendFeedback(
                  feedback: UserFeedback(
                    userId: userId,
                    pharmacyId: widget.mask.id,
                    optionId: currentOption.id,
                    description:
                        currentOption.id == CUSTOM_ID ? _controller.text : '',
                    longitude: position?.longitude ?? 0.0,
                    latitude: position?.latitude ?? 0.0,
                  ),
                  callback: GeneralCallback(
                    onSuccess: () {
                      Utils.showToast(context, app.success);
                      feedbackList = null;
                      offset = 0;
                      _timer = Timer.periodic(
                          Duration(seconds: UPDATE_PERIOD_SECONDS),
                          _getStoreFeedback);
                      isSending = false;
                      _controller.text = '';
                      if ((currentOption.id ?? '') != CUSTOM_ID)
                        currentOption = null;
                      _getStoreFeedback(_timer);
                    },
                    onError: (e) {
                      setState(() {
                        isSending = false;
                      });
                      Utils.showToast(context, app.unknownError);
                      throw e;
                    },
                    onFailure: (DioError e) {
                      setState(() {
                        isSending = false;
                      });
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
                FA.logEvent('send_feedback');
              },
        backgroundColor: (isSending || currentOption == null)
            ? AppColors.gray
            : AppColors.blue,
      ),
    );
  }

  void _getStoreFeedback(Timer timer) async {
    if (userId == null) {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      var result = await _auth.signInAnonymously();
      userId = result.user.uid;
    }
    Helper.instance.getStoreFeedBack(
      storeId: widget.mask.id,
      date: DateTime.now(),
      offset: offset,
      limit: limit,
      callback: FeedbackDataCallback(
        onSuccess: (FeedbackData data, List<Option> options) {
          setState(() {
            if (feedbackList == null)
              feedbackList = data.items;
            else
              feedbackList.addAll(data.items);
            this.options = options.reversed.toList();
            state = _State.finish;
          });
        },
        onError: (e) {
          Utils.showToast(context, app.unknownError);
          state = _State.finish;
          throw e;
        },
        onFailure: (DioError e) {
          state = _State.finish;
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

  String _getOptionString(String optionId) {
    for (var option in options) {
      if (option.id == optionId) return option.name;
    }
    return null;
  }

  void _getUserPosition() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    position = await geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 500) {
      if (state == _State.finish) {
        offset += limit;
        _timer?.cancel();
        state = _State.loadingMore;
        _timer = Timer.periodic(
            Duration(seconds: UPDATE_PERIOD_SECONDS), _getStoreFeedback);
        _getStoreFeedback(_timer);
      }
    }
  }
}
