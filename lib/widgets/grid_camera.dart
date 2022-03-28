import 'dart:math';

import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/live_camera/grid_camera_store.dart';
import 'package:boilerplate/widgets/live_camera_view.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class GridCamera extends StatefulWidget {
  final List<Camera> cameras;

  GridCamera({Key key, this.cameras}) : super(key: key);

  @override
  _GridCameraState createState() => _GridCameraState();
}

class _GridCameraState extends State<GridCamera> {
  GridCameraStore _gridCameraStore;
  CameraStore _cameraStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gridCameraStore = Provider.of(context);
    _cameraStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: sqrt(_gridCameraStore.numberCameraOfGrid).floor(),
      childAspectRatio: _getChildAspectRatio(),
      children: [
        for (int i = 0; i < widget.cameras.length; i++)
          GestureDetector(
            key: widget.cameras[i]?.globalKey ?? GlobalKey(),
            onTap: () {
              if (MediaQuery.of(context).orientation == Orientation.landscape) {
                _gridCameraStore.toggleShowControlBar();
              }
              if (widget.cameras[i] == null) return;
              setState(() {
                _cameraStore.setCamera(widget.cameras[i]);
              });
            },
            onDoubleTap: () async {
              if (_gridCameraStore.isSingleMode) return;
              if (widget.cameras[i] == null) return;
              _cameraStore.setCamera(widget.cameras[i]);
              _gridCameraStore.toggleFullGrid();
              int page = widget.cameras[i].position ~/
                  _gridCameraStore.numberCameraOfGrid;
              _gridCameraStore.setPage(page);
            },
            child: LiveCameraView(camera: widget.cameras[i], position: i),
          )
      ],
    );
  }

  double _getChildAspectRatio() {
    final size = MediaQuery.of(context).size;
    if (size.width <= size.height) return 1;
    return size.width / size.height;
  }
}
