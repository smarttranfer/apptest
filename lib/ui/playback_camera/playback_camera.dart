import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/record_camera/record_camera_store.dart';
import 'package:boilerplate/stores/roll_camera/roll_camera_store.dart';
import 'package:boilerplate/ui/home/home.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/camera_roll.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:boilerplate/widgets/playback_camera_view.dart';
import 'package:boilerplate/widgets/playback_camera_control_bar.dart';
import 'package:boilerplate/widgets/speed_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class PlayBackCameraScreen extends HomeScreen {
  @override
  _PlayBackCameraScreenState createState() => _PlayBackCameraScreenState();
}

class _PlayBackCameraScreenState extends HomeScreenState<PlayBackCameraScreen>
    with HomeScreenPage {
  RollCameraStore _rollCameraStore;
  RecordCameraStore _recordCameraStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rollCameraStore = Provider.of(context);
    _recordCameraStore = Provider.of(context);
  }

  @override
  void dispose() {
    _rollCameraStore.camera = null;
    _rollCameraStore.controller = null;
    _rollCameraStore.cameraSelected = null;
    _rollCameraStore.events = [];
    _rollCameraStore.event = null;
    super.dispose();
  }

  @override
  Widget body() {
    return Observer(builder: (context) {
      return Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: _getHeight(),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (!_isPortrait()) {
                                _rollCameraStore.toggleShowControlBar();
                              }
                            },
                            child: PlayBackCameraView(
                              camera: _rollCameraStore.camera,
                              event: _rollCameraStore.event,
                              onCompleteEvent: _rollCameraStore.setNextEvent,
                            ),
                          ),
                          if (_rollCameraStore.isShowSpeed)
                            Positioned(
                              bottom: 50,
                              child: SpeedControl(
                                initSpeed: _rollCameraStore
                                    .controller.value.playbackSpeed,
                                onSpeedChange: (speed) {
                                  final controller =
                                      _rollCameraStore.controller;
                                  controller.setPlaybackSpeed(speed);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isPortrait()) ...[
                      const SizedBox(height: 20),
                      CameraRoll(
                        key: GlobalKey(),
                        onTimeSelected: (timeSelected) {
                          _rollCameraStore.setTimeSelected(timeSelected);
                          final event = _rollCameraStore.events.firstWhere(
                              (e) => _isTimeBetween(
                                  e.startTime, e.endTime, timeSelected.toUtc()),
                              orElse: () => null);
                          _rollCameraStore.setEvent(event);
                        },
                        onSeek: (value) {
                          final controller = _rollCameraStore.controller;
                          if (controller == null) return;
                          Duration position = controller.value.position +
                              Duration(seconds: value);
                          controller.seekTo(position);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              if (_isPortrait()) ...[
                PlaybackCameraControlBar(),
                const SizedBox(height: 15),
              ],
            ],
          ),
          if (!_isPortrait() && _rollCameraStore.isShowBar)
            CameraRoll(
              onTimeSelected: (timeSelected) {
                _rollCameraStore.setTimeSelected(timeSelected);
                final event = _rollCameraStore.events.firstWhere(
                    (e) => _isTimeBetween(
                        e.startTime, e.endTime, timeSelected.toUtc()),
                    orElse: () => null);
                _rollCameraStore.setEvent(event);
              },
              onSeek: (value) {
                final controller = _rollCameraStore.controller;
                if (controller == null) return;
                Duration position =
                    controller.value.position + Duration(seconds: value);
                controller.seekTo(position);
              },
            ),
          if (!_isPortrait() && _rollCameraStore.isShowBar)
            Container(
              child: PlaybackCameraControlBar(),
              alignment: Alignment.bottomCenter,
            ),
          if (!_isPortrait())
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5),
              child: Text(
                Translate.getString("playback.title", context),
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (_recordCameraStore.isTakingPicture)
            Positioned(
                bottom: 12,
                left: 8,
                child: Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    color: Colors.black,
                    image: _recordCameraStore.imageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_recordCameraStore.imageBytes),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _recordCameraStore.imageBytes == null
                      ? SpinKitCircle(color: Colors.white, size: 40)
                      : Container(),
                )),
        ],
      );
    });
  }

  @override
  Widget action() {
    return IconButton(
      onPressed: () {
        Navigator.pushNamed(context, Routes.devices, arguments: "roll_camera");
      },
      icon: IconAssets(name: "dual_video", height: 20),
    );
  }

  @override
  PreferredSize bottom() {
    return PreferredSize(
      preferredSize: Size(0, 0),
      child: Container(),
    );
  }

  bool _isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  bool _isTimeBetween(String start, String end, DateTime dateTime) {
    try {
      DateTime startTime = DateTime.parse(start);
      DateTime endTime = DateTime.parse(end);
      return startTime.difference(dateTime).inSeconds <= 0 &&
          endTime.difference(dateTime).inSeconds >= 0;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  double _getHeight() {
    if (_isPortrait()) {
      return MediaQuery.of(context).size.width;
    }
    return MediaQuery.of(context).size.height;
  }
}
