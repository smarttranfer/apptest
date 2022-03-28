import 'dart:math';
import 'dart:ui';

import 'package:boilerplate/constants/mode_type.dart';
import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/live_camera/grid_camera_store.dart';
import 'package:boilerplate/stores/ptz_control/ptz_control_store.dart';
import 'package:boilerplate/widgets/focus_control.dart';
import 'package:boilerplate/widgets/live_camera_player.dart';
import 'package:boilerplate/widgets/ptz_control_bar_landscape.dart';
import 'package:boilerplate/widgets/ptz_move_control.dart';
import 'package:boilerplate/widgets/zoom_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import 'camera_info.dart';
import 'icon_assets.dart';
import 'list_live_camera.dart';
import 'record_time.dart';
import 'package:flutter/material.dart';

class LiveCameraView extends StatefulObserverWidget {
  final Camera camera;
  final int position;

  LiveCameraView({Key key, this.camera, this.position}) : super(key: key);

  @override
  _LiveCameraViewState createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView> {
  GridCameraStore _gridCameraStore;
  PtzControlStore _ptzControlStore;
  CameraStore _cameraStore;
  PhotoViewScaleStateController _scaleStateController =
      PhotoViewScaleStateController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gridCameraStore = Provider.of(context);
    _ptzControlStore = Provider.of(context);
    _cameraStore = Provider.of(context);
  }

  @override
  void didUpdateWidget(covariant LiveCameraView oldWidget) {
    if (!_gridCameraStore.isZoomMode) {
      _scaleStateController.reset();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        width: _getWidth(),
        height: _getHeight(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _getColor(),
                border: Border.all(
                  color: _isSelected(widget.camera)
                      ? Colors.blueAccent
                      : Colors.white,
                  width: _isSelected(widget.camera) ? 1 : 0.25,
                ),
              ),
            ),
            if (widget.camera != null)
              Container(
                padding: const EdgeInsets.all(1),
                child: PhotoView.customChild(
                  scaleStateController: _scaleStateController,
                  child: LiveCameraPlayer(camera: widget.camera),
                  minScale: 1.0,
                  maxScale: _gridCameraStore.isZoomMode ? 20.0 : 1.0,
                  initialScale: 1.0,
                ),
              ),
            if (_gridCameraStore.numberCameraOfGrid != 1 &&
                !_gridCameraStore.isSingleMode)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: CameraInfo(
                    selected: _isSelected(widget.camera),
                    name: widget.camera?.name ?? "",
                    speed: null,
                  ),
                ),
              ),
            if (widget.camera == null)
              Center(
                child: IconButton(
                  onPressed: _showPUSelectCam,
                  icon: const IconAssets(name: "add"),
                ),
              ),
            if (_isRecording())
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(left: 10, top: 10, right: 20),
                child: RecordTime(start: _getStartTimeRecord()),
              ),
            if (_ptzControlStore.isZoom || _ptzControlStore.isFocus)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _ptzControlStore.cancelPtz();
                },
                child: Container(),
              ),
            if (_gridCameraStore.mode == ModeType.PTZ_MODE &&
                !_ptzControlStore.isZoom &&
                !_ptzControlStore.isFocus)
              PtzMoveControl(),
            if (MediaQuery.of(context).orientation == Orientation.landscape &&
                _gridCameraStore.mode == ModeType.PTZ_MODE)
              Align(
                alignment: Alignment.centerRight,
                child: PtzControlBarLandscape(),
              ),
            if (_ptzControlStore.isZoom)
              Positioned(bottom: 50, child: ZoomControl()),
            if (_ptzControlStore.isFocus)
              Positioned(bottom: 50, child: FocusControl()),
          ],
        ),
      ),
    );
  }

  _getColor() {
    if (widget.camera == null) return Color.fromARGB(255, 42, 43, 49);
    // if (widget.camera.error == true) return Color.fromARGB(255, 0, 0, 0);
  }

  _showPUSelectCam() async {
    return showCupertinoModalBottomSheet(
        expand: true,
        context: context,
        builder: (context) => ListLiveCamera(
              position: widget.position,
            ));
  }

  bool _isSelected(Camera camera) {
    return _cameraStore.camera != null &&
        camera != null &&
        camera.position == _cameraStore.camera.position;
  }

  double _getWidth() {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    if (MediaQuery.of(context).orientation == Orientation.landscape)
      return size.width /
          (_gridCameraStore.isSingleMode
              ? 1
              : sqrt(_gridCameraStore.numberCameraOfGrid));
    if (_gridCameraStore.isSingleMode) return width;
    return width / sqrt(_gridCameraStore.numberCameraOfGrid);
  }

  double _getHeight() {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    if (MediaQuery.of(context).orientation == Orientation.landscape)
      return size.height /
          (_gridCameraStore.isSingleMode
              ? 1
              : sqrt(_gridCameraStore.numberCameraOfGrid));
    if (_gridCameraStore.isSingleMode) return width;
    return width / sqrt(_gridCameraStore.numberCameraOfGrid);
  }

  bool _isRecording() {
    return false;
  }

  DateTime _getStartTimeRecord() {
    return DateTime.now();
  }
}
