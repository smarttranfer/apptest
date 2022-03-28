import 'package:boilerplate/constants/mode_type.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/live_camera/grid_camera_store.dart';
import 'package:boilerplate/stores/record_camera/record_camera_store.dart';
import 'package:boilerplate/ui/home/home.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:boilerplate/widgets/list_grid_camera.dart';
import 'package:boilerplate/widgets/main_control_bar.dart';
import 'package:boilerplate/widgets/ptz_control_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class LiveCamera extends HomeScreen {
  @override
  _LiveCameraState createState() => _LiveCameraState();
}

class _LiveCameraState extends HomeScreenState<LiveCamera> with HomeScreenPage {
  GridCameraStore _gridCameraStore;
  RecordCameraStore _recordCameraStore;
  CameraStore _cameraStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gridCameraStore = Provider.of(context);
    _recordCameraStore = Provider.of(context);
    _cameraStore = Provider.of(context);
  }

  @override
  Widget body() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(child: ListGridCamera()),
            if (MediaQuery.of(context).orientation == Orientation.portrait) ...[
              Observer(builder: (context) {
                return _gridCameraStore.mode == ModeType.PTZ_MODE
                    ? PtzControlBar()
                    : Container(
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 10),
                      );
              }),
              MainControlBar(),
              const SizedBox(height: 15),
            ],
          ],
        ),
        if (MediaQuery.of(context).orientation == Orientation.landscape)
          Observer(builder: (context) {
            return Visibility(
              visible: _gridCameraStore.isShowBar,
              child: Container(
                child: MainControlBar(),
                alignment: Alignment.bottomCenter,
              ),
            );
          }),
        Observer(
          builder: (context) {
            return Visibility(
              visible: _recordCameraStore.isTakingPicture,
              child: Positioned(
                  bottom: 12,
                  left: 8,
                  child: Container(
                    height: 100,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.black,
                      image: _recordCameraStore.imageBytes != null
                          ? DecorationImage(
                              image: MemoryImage(_recordCameraStore.imageBytes),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _recordCameraStore.imageBytes == null
                        ? SpinKitCircle(color: Colors.white, size: 40)
                        : Container(),
                  )),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget action() {
    return IconButton(
      onPressed: () {
        Navigator.pushNamed(context, Routes.devices);
      },
      icon: const IconAssets(name: "dual_video", height: 20),
    );
  }

  @override
  PreferredSize bottom() {
    return PreferredSize(
      preferredSize: Size(0, 0),
      child: Container(),
    );
  }

  @override
  void onPaused() {
    _cameraStore.dispose();
    super.onPaused();
  }

  @override
  void onResumed() {
    _cameraStore.findAll();
    Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.liveCamera, (Route<dynamic> route) => false);
    super.onResumed();
  }
}
