import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/ptz_control/ptz_control_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'circle_button.dart';

class FocusControl extends StatefulWidget {
  FocusControl({Key key}) : super(key: key);

  @override
  _FocusControlState createState() => _FocusControlState();
}

class _FocusControlState extends State<FocusControl> {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        color: const Color.fromARGB(200, 44, 52, 62),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleButton(
                text: "-",
                onTap: () {
                  _focus("focusConFar");
                },
                onLongPressStart: () {
                  _startFocus("focusConFar");
                },
                onLongPressEnd: _stopFocus,
              ),
            ),
            Text("Focus", style: TextStyle(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleButton(
                text: "+",
                onTap: () {
                  _focus("focusConNear");
                },
                onLongPressStart: () {
                  _startFocus("focusConNear");
                },
                onLongPressEnd: _stopFocus,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _focus(String action) async {
    try {
      await _ptzControlStore.focus(_cameraStore.camera, action, context);
      await _ptzControlStore.focus(_cameraStore.camera, "focusStop", context);
    } catch (e) {}
  }

  _startFocus(String action) async {
    try {
      await _ptzControlStore.focus(_cameraStore.camera, action, context);
    } catch (e) {}
  }

  _stopFocus() async {
    try {
      await _ptzControlStore.focus(_cameraStore.camera, "focusStop", context);
    } catch (e) {}
  }
}
