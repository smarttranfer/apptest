import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/live_camera/grid_camera_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/grid_camera.dart';
import 'package:boilerplate/widgets/main_control_bar_2.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListGridCamera extends StatefulWidget {
  ListGridCamera({Key key}) : super(key: key);

  @override
  _ListGridCameraState createState() => _ListGridCameraState();
}

class _ListGridCameraState extends State<ListGridCamera> {
  GridCameraStore _gridCameraStore;
  CameraStore _cameraStore;

  List<Camera> cameras = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gridCameraStore = Provider.of(context);
    _cameraStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Observer(
          builder: (context) {
            int perPage = _gridCameraStore.numberCameraOfGrid;
            int first = _gridCameraStore.currentPage * perPage;
            int last = (_gridCameraStore.currentPage + 1) * perPage;
            cameras = _cameraStore.listCamera.sublist(first, last);
            int pageCount = _cameraStore.listCamera.length ~/ perPage;
            _selectFirstCam();

            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onHorizontalDragEnd: _gridCameraStore.isSingleMode
                          ? null
                          : (e) {
                              if (e.primaryVelocity > 0) {
                                if (_gridCameraStore.currentPage > 0) {
                                  setState(() {
                                    _gridCameraStore.currentPage--;
                                  });
                                }
                              } else if (e.primaryVelocity < 0) {
                                if (_gridCameraStore.currentPage <
                                    _cameraStore.listCamera.length ~/ perPage -
                                        1) {
                                  setState(() {
                                    _gridCameraStore.currentPage++;
                                  });
                                }
                              }
                            },
                      child: GridCamera(cameras: cameras),
                    ),
                    if (MediaQuery.of(context).orientation ==
                        Orientation.portrait)
                      Container(
                        height: 60,
                        child: Observer(
                          builder: (context) {
                            return MainControlBar2(
                              currentPage: _getCurrentPage(pageCount),
                              pageCount: pageCount,
                            );
                          },
                        ),
                      ),
                  ],
                ),
                if (MediaQuery.of(context).orientation ==
                    Orientation.landscape) ...[
                  Observer(builder: (context) {
                    return Stack(
                      children: [
                        if (_gridCameraStore.isShowBar)
                          Container(
                            color: const Color.fromARGB(150, 42, 43, 49),
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    Translate.getString(
                                        "live_view.title", context),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                                if (!_gridCameraStore.isSingleMode)
                                  Center(
                                    child: Text(
                                      "${_getCurrentPage(pageCount)}/$pageCount",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),
                ]
              ],
            );
          },
        );
      },
    );
  }

  _selectFirstCam() {
    if (!cameras.contains(_cameraStore.camera)) {
      final camera = cameras.firstWhere((e) => e != null, orElse: () => null);
      _cameraStore.setCamera(camera);
    }
  }

  int _getCurrentPage(int pageCount) {
    int currentPage = _gridCameraStore.currentPage + 1;
    if (currentPage > pageCount) {
      return pageCount;
    }
    return currentPage;
  }
}
