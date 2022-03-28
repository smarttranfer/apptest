import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/ptz_control/ptz_control_store.dart';
import 'package:boilerplate/widgets/icon_assets_button.dart';
import 'package:boilerplate/widgets/swipe_detector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PtzMoveControl extends StatefulWidget {
  PtzMoveControl({Key key}) : super(key: key);

  @override
  _PtzMoveControlState createState() => _PtzMoveControlState();
}

class _PtzMoveControlState extends State<PtzMoveControl> {
  PtzControlStore _ptzControlStore;
  CameraStore _cameraStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ptzControlStore = Provider.of(context);
    _cameraStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return SwipeDetector(
      onSwipeUpLeft: () {
        print("onSwipeUpLeft");
        _ptzControl("moveConUpLeft");
      },
      onSwipeUp: () {
        print("onSwipeUp");
        _ptzControl("moveConUp");
      },
      onSwipeUpRight: () {
        print("onSwipeUpRight");
        _ptzControl("moveConUpRight");
      },
      onSwipeLeft: () {
        print("onSwipeLeft");
        _ptzControl("moveConLeft");
      },
      onSwipeRight: () {
        print("onSwipeRight");
        _ptzControl("moveConRight");
      },
      onSwipeDownLeft: () {
        print("onSwipeDownLeft");
        _ptzControl("moveConDownLeft");
      },
      onSwipeDown: () {
        print("onSwipeDown");
        _ptzControl("moveConDown");
      },
      onSwipeDownRight: () {
        print("onSwipeDownRight");
        _ptzControl("moveConDownRight");
      },
      onEnd: _moveStop,
      child: Padding(
        padding: EdgeInsets.only(
            left: _getHorizontalMargin(),
            right: _getHorizontalMargin(),
            top: 10,
            bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconAssetsButton(
                  name: "ptz_top_left",
                  controlAction: "moveConUpLeft",
                  width: 15,
                ),
                IconAssetsButton(
                  name: "ptz_top",
                  controlAction: "moveConUp",
                  width: 18,
                ),
                IconAssetsButton(
                  name: "ptz_top_right",
                  controlAction: "moveConUpRight",
                  width: 15,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconAssetsButton(
                  name: "ptz_left",
                  controlAction: "moveConLeft",
                  width: 12,
                ),
                IconAssetsButton(
                  name: "ptz_right",
                  controlAction: "moveConRight",
                  width: 12,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconAssetsButton(
                  name: "ptz_bottom_left",
                  controlAction: "moveConDownLeft",
                  width: 15,
                ),
                IconAssetsButton(
                  name: "ptz_bottom",
                  controlAction: "moveConDown",
                  width: 18,
                ),
                IconAssetsButton(
                  name: "ptz_bottom_right",
                  controlAction: "moveConDownRight",
                  width: 15,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _moveStop() async {
    try {
      await _ptzControlStore.ptzControl(
          _cameraStore.camera, "moveStop", context);
    } catch (e) {}
  }

  _ptzControl(String action) async {
    if (_ptzControlStore.actionControl == action) return;
    await _ptzControlStore.ptzControl(_cameraStore.camera, action, context);
  }

  double _getHorizontalMargin() {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? 30
        : 10;
  }
}
