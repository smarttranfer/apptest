import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/ptz_control/ptz_control_store.dart';
import 'package:boilerplate/widgets/icon_assets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class PtzControlBarLandscape extends StatefulWidget {
  PtzControlBarLandscape({Key key}) : super(key: key);

  @override
  _PtzControlBarState createState() => _PtzControlBarState();
}

class _PtzControlBarState extends State<PtzControlBarLandscape> {
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
    return Observer(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: IconAssets(
                name: "ptz_zoom",
                width: 16,
                color: _ptzControlStore.isZoom ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                _ptzControlStore.toggleZoom();
              },
            ),
            Text("—", style: TextStyle(color: Colors.white, fontSize: 20)),
            IconButton(
              icon: IconAssets(
                name: "focus",
                color: _ptzControlStore.isFocus ? Colors.blue : null,
              ),
              onPressed: () {
                _ptzControlStore.toggleFocus();
              },
            ),
            Text("—", style: TextStyle(color: Colors.white, fontSize: 20)),
            IconButton(
              icon: IconAssets(
                name: "rotate",
                color: _ptzControlStore.isRotating ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                _ptzControlStore.rotate(_cameraStore.camera, context);
              },
            ),
          ],
        ),
      );
    });
  }
}
