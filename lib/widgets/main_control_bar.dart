import 'dart:async';

import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/live_camera/grid_camera_store.dart';
import 'package:boilerplate/stores/ptz_control/ptz_control_store.dart';
import 'package:boilerplate/stores/record_camera/record_camera_store.dart';
import 'package:provider/provider.dart';

import 'main_control_button.dart';
import 'package:flutter/material.dart';

class MainControlBar extends StatefulWidget {
  MainControlBar({Key key}) : super(key: key);

  @override
  _MainControlBarState createState() => _MainControlBarState();
}

class _MainControlBarState extends State<MainControlBar> {
  GridCameraStore _gridCameraStore;
  RecordCameraStore _recordCameraStore;
  CameraStore _cameraStore;
  PtzControlStore _ptzControlStore;
  HomeStore _homeStore;
  FavoriteStore _favoriteStore;

  int cacheNumberCam = 4;

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
    _gridCameraStore = Provider.of(context);
    _recordCameraStore = Provider.of(context);
    _cameraStore = Provider.of(context);
    _ptzControlStore = Provider.of(context);
    _homeStore = Provider.of(context);
    _favoriteStore = Provider.of(context);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MainControlButton(
            icon: "screenshot",
            iconColor: Colors.black,
            onPressed: _screenShot,
          ),
          MainControlButton(
            icon: "ptz",
            iconColor: _getPtzButtonColor(),
            onPressed: _ptz,
          ),
          MainControlButton(icon: _getVolumeIcon(), onPressed: _controlVolume),
          MainControlButton(
            icon: "zoom",
            iconColor: _gridCameraStore.isZoomMode ? Colors.blue : null,
            onPressed: _zoom,
          ),
        ],
      );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(150, 42, 43, 49),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: MainControlButton(
                icon: "favorite",
                iconColor: Colors.black,
                onPressed: () {
                  _favoriteStore.setNavigateValue(true);
                  _homeStore.setActiveScreen('favoritesList');
                  Navigator.of(context).pushNamed(Routes.favoritesList);
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: MainControlButton(
                icon: "${_gridCameraStore.numberCameraOfGrid == 4 ? 1 : 4}",
                iconColor: Colors.black,
                onPressed: () {
                  _ptzControlStore.cancelPtz();
                  if (_cameraStore.camera == null) return;
                  _gridCameraStore.toggleFullGrid();
                  int page = _cameraStore.camera.position ~/
                      _gridCameraStore.numberCameraOfGrid;
                  _gridCameraStore.setPage(page);
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: MainControlButton(
              icon: "screenshot",
              iconColor: Colors.black,
              onPressed: _screenShot,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: MainControlButton(
              icon: "ptz",
              iconColor: _getPtzButtonColor(),
              onPressed: _ptz,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: MainControlButton(
              icon: _getVolumeIcon(),
              onPressed: _controlVolume,
            ),
          ),
          MainControlButton(
            icon: "zoom",
            iconColor: _gridCameraStore.isZoomMode ? Colors.blue : null,
            onPressed: _zoom,
          ),
        ],
      ),
    );
  }

  _ptz() {
    _ptzControlStore.cancelPtz();
    if (_cameraStore.camera == null) return;
    if (_cameraStore.camera.controllable != "1") return;
    if (!_gridCameraStore.isSingleMode) {
      cacheNumberCam = _gridCameraStore.numberCameraOfGrid;
    }
    _gridCameraStore.togglePtzMode();
    _gridCameraStore
        .setNumberCameraOfGrid(_gridCameraStore.isPtzMode ? 1 : cacheNumberCam);
    int page =
        _cameraStore.camera.position ~/ _gridCameraStore.numberCameraOfGrid;
    _gridCameraStore.setPage(page);
  }

  _zoom() {
    if (_cameraStore.camera == null) {
      _gridCameraStore.reset();
      return;
    }
    if (!_gridCameraStore.isSingleMode) {
      cacheNumberCam = _gridCameraStore.numberCameraOfGrid;
    }
    _gridCameraStore.toggleZoomMode();
    _gridCameraStore.setNumberCameraOfGrid(
        _gridCameraStore.isZoomMode ? 1 : cacheNumberCam);
    int page =
        _cameraStore.camera.position ~/ _gridCameraStore.numberCameraOfGrid;
    _gridCameraStore.setPage(page);
  }

  _screenShot() async {
    if (_cameraStore.camera == null) return;
    final snapshot = await _cameraStore.camera.controller?.takeSnapshot();
    _recordCameraStore.savePicture(_cameraStore.camera, snapshot, context);
  }

  _controlVolume() {
    if (_cameraStore.camera == null) return;
    final controller = _cameraStore.camera.controller;
    if (controller == null) return;
    if (controller.value.volume == 0) {
      controller.setVolume(100);
    } else {
      controller.setVolume(0);
    }
  }

  _getPtzButtonColor() {
    if (_cameraStore.camera == null) return Colors.black;
    if (_cameraStore.camera.controllable != "1") return Colors.grey;
    if (_gridCameraStore.isPtzMode) return Colors.blue;
    return Colors.black;
  }

  _getVolumeIcon() {
    if (_cameraStore.camera?.controller?.value?.volume == 0) return "mute";
    return "volume";
  }
}
