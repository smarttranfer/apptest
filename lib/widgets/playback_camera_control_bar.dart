import 'dart:async';

import 'package:boilerplate/stores/record_camera/record_camera_store.dart';
import 'package:boilerplate/stores/roll_camera/roll_camera_store.dart';
import 'package:provider/provider.dart';

import 'main_control_button.dart';
import 'package:flutter/material.dart';

class PlaybackCameraControlBar extends StatefulWidget {
  PlaybackCameraControlBar({Key key}) : super(key: key);

  @override
  _PlaybackCameraControlBarState createState() =>
      _PlaybackCameraControlBarState();
}

class _PlaybackCameraControlBarState extends State<PlaybackCameraControlBar> {
  RecordCameraStore _recordCameraStore;
  RollCameraStore _rollCameraStore;
  Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recordCameraStore = Provider.of(context);
    _rollCameraStore = Provider.of(context);
  }

  @override
  void dispose() {
    _timer.cancel();
    _rollCameraStore.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MainControlButton(
            icon: "delete_one_cam",
            iconColor: Colors.black,
            onPressed: _deleteCamera,
          ),
          MainControlButton(icon: "screenshot", onPressed: _screenShot),
          MainControlButton(icon: _getPlayButtonIcon(), onPressed: _togglePlay),
          MainControlButton(icon: _getVolumeIcon(), onPressed: _controlVolume),
          MainControlButton(
            icon: "speed",
            iconColor:
                _rollCameraStore.isShowSpeed ? Colors.blueAccent : Colors.black,
            onPressed: _controlSpeed,
          ),
        ],
      );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration:
          const BoxDecoration(color: const Color.fromARGB(150, 42, 43, 49)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MainControlButton(
            icon: "delete_one_cam",
            iconColor: Colors.black,
            onPressed: _deleteCamera,
          ),
          const SizedBox(width: 15),
          MainControlButton(icon: "screenshot", onPressed: _screenShot),
          const SizedBox(width: 15),
          MainControlButton(icon: _getPlayButtonIcon(), onPressed: _togglePlay),
          const SizedBox(width: 15),
          MainControlButton(icon: _getVolumeIcon(), onPressed: _controlVolume),
          const SizedBox(width: 15),
          MainControlButton(
            icon: "speed",
            iconColor:
                _rollCameraStore.isShowSpeed ? Colors.blueAccent : Colors.black,
            onPressed: _controlSpeed,
          ),
        ],
      ),
    );
  }

  _deleteCamera() {
    _rollCameraStore.setCamera(null);
    _rollCameraStore.events = [];
    _rollCameraStore.event = null;
  }

  _screenShot() async {
    if (_rollCameraStore.camera == null) return;
    final controller = _rollCameraStore.controller;
    if (controller == null) return;
    final snapshot = await controller.takeSnapshot();
    _recordCameraStore.savePicture(_rollCameraStore.camera, snapshot, context);
  }

  _togglePlay() {
    if (_rollCameraStore.camera == null) return;
    final controller = _rollCameraStore.controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  _controlVolume() {
    if (_rollCameraStore.camera == null) return;
    final controller = _rollCameraStore.controller;
    if (controller == null) return;
    if (controller.value.volume == 0) {
      controller.setVolume(100);
    } else {
      controller.setVolume(0);
    }
  }

  _controlSpeed() {
    if (_rollCameraStore.camera == null) return;
    final controller = _rollCameraStore.controller;
    if (controller == null) return;
    _rollCameraStore.toggleShowSpeed();
  }

  _getPlayButtonIcon() {
    if (_rollCameraStore.camera != null &&
        _rollCameraStore.controller?.value?.isPlaying == true) return "pause";
    return "play";
  }

  _getVolumeIcon() {
    if (_rollCameraStore.camera != null &&
        _rollCameraStore.controller?.value?.volume == 0) return "mute";
    return "volume";
  }
}
