import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/ptz_control/ptz_control_store.dart';
import 'package:boilerplate/widgets/icon_assets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class PtzControlBar extends StatefulWidget {
  PtzControlBar({Key key}) : super(key: key);

  @override
  _PtzControlBarState createState() => _PtzControlBarState();
}

class _PtzControlBarState extends State<PtzControlBar> {
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
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 10),
        color: Color.fromARGB(255, 44, 52, 62),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: IconAssets(
                name: "rotate",
                color: _ptzControlStore.isRotating ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                _ptzControlStore.rotate(_cameraStore.camera, context);
              },
            ),
            SizedBox(width: 10),
            Text("|", style: TextStyle(color: Colors.white)),
            SizedBox(width: 10),
            IconButton(
              icon: IconAssets(
                name: "focus",
                color: _ptzControlStore.isFocus ? Colors.blue : null,
              ),
              onPressed: _ptzControlStore.toggleFocus,
            ),
            SizedBox(width: 10),
            Text("|", style: TextStyle(color: Colors.white)),
            SizedBox(width: 10),
            IconButton(
              icon: IconAssets(
                name: "ptz_zoom",
                width: 16,
                color: _ptzControlStore.isZoom ? Colors.blue : Colors.white,
              ),
              onPressed: _ptzControlStore.toggleZoom,
            ),
          ],
        ),
      );
    });
  }
}
