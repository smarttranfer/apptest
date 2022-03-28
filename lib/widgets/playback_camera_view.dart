import 'dart:ui';

import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/models/event/event.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/widgets/playback_camera_player.dart';
import 'package:flutter/cupertino.dart';

import 'icon_assets.dart';
import 'package:flutter/material.dart';

class PlayBackCameraView extends StatefulWidget {
  final Camera camera;
  final Event event;
  final Function onCompleteEvent;

  PlayBackCameraView({Key key, this.camera, this.event, this.onCompleteEvent})
      : super(key: key);

  @override
  _PlayBackCameraViewState createState() => _PlayBackCameraViewState();
}

class _PlayBackCameraViewState extends State<PlayBackCameraView> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: _getColor(),
              border: Border.all(
                color: Colors.blueAccent,
                width: 1,
              ),
            ),
          ),
          if (widget.camera != null)
            Container(
              padding: const EdgeInsets.all(1),
              child: PlayBackCameraPlayer(
                camera: widget.camera,
                onComplete: widget.onCompleteEvent,
                url: widget.event?.videoViewUrl,
                key: widget.camera.globalKey,
              ),
            ),
          if (widget.camera == null)
            Center(
              child: IconButton(
                onPressed: () => Navigator.pushNamed(context, Routes.devices,
                    arguments: "roll_camera"),
                icon: const IconAssets(name: "add"),
              ),
            ),
        ],
      ),
    );
  }

  _getColor() {
    if (widget.camera == null) return Color.fromARGB(255, 42, 43, 49);
  }
}
