import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/ptz_control/ptz_control_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'circle_button.dart';

class ZoomControl extends StatefulWidget {
  ZoomControl({Key key}) : super(key: key);

  @override
  _ZoomControlState createState() => _ZoomControlState();
}

class _ZoomControlState extends State<ZoomControl> {
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
        color: Color.fromARGB(200, 44, 52, 62),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleButton(
                text: "-",
                onTap: () {
                  _zoom("zoomConWide");
                },
                onLongPressStart: () {
                  _startZoom("zoomConWide");
                },
                onLongPressEnd: _stopZoom,
              ),
            ),
            Text("Zoom", style: TextStyle(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleButton(
                text: "+",
                onTap: () {
                  _zoom("zoomConTele");
                },
                onLongPressStart: () {
                  _startZoom("zoomConTele");
                },
                onLongPressEnd: _stopZoom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _zoom(String action) async {
    try {
      await _ptzControlStore.ptzControl(_cameraStore.camera, action, context);
      await _ptzControlStore.ptzControl(
          _cameraStore.camera, "zoomStop", context);
    } catch (e) {}
  }

  _startZoom(String action) async {
    try {
      await _ptzControlStore.ptzControl(_cameraStore.camera, action, context);
    } catch (e) {}
  }

  _stopZoom() async {
    try {
      await _ptzControlStore.ptzControl(
          _cameraStore.camera, "zoomStop", context);
    } catch (e) {}
  }
}
