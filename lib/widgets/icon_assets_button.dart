import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/ptz_control/ptz_control_store.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class IconAssetsButton extends StatefulWidget {
  final String name;
  final double width;
  final double height;
  final String controlAction;

  IconAssetsButton({
    Key key,
    this.name,
    this.width,
    this.height,
    this.controlAction,
  }) : super(key: key);

  @override
  _IconAssetsButtonState createState() => _IconAssetsButtonState();
}

class _IconAssetsButtonState extends State<IconAssetsButton> {
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
    return GestureDetector(
      onTap: () async {
        await _ptzControl(widget.controlAction);
        await _moveStop();
      },
      onPanDown: (e) {
        _ptzControlStore.setControlAction(widget.controlAction);
      },
      onLongPressStart: (e) {
        _ptzControl(widget.controlAction);
      },
      onLongPressEnd: (e) async {
        _moveStop();
      },
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        minRadius: 25,
        child: Observer(
          builder: (context) {
            return IconAssets(
              name: widget.name,
              width: widget.width,
              height: widget.height,
              color: _ptzControlStore.actionControl == widget.controlAction
                  ? Colors.blue
                  : Colors.white70,
            );
          },
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
    try {
      await _ptzControlStore.ptzControl(_cameraStore.camera, action, context);
    } catch (e) {}
  }
}
