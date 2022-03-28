import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/live_camera/grid_camera_store.dart';
import 'package:boilerplate/stores/ptz_control/ptz_control_store.dart';
import 'package:boilerplate/widgets/icon_assets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class MainControlBar2 extends StatefulWidget {
  final int pageCount;
  final int currentPage;

  MainControlBar2({Key key, this.pageCount, this.currentPage})
      : super(key: key);

  @override
  _MainControlBarState createState() => _MainControlBarState();
}

class _MainControlBarState extends State<MainControlBar2> {
  GridCameraStore _gridCameraStore;
  CameraStore _cameraStore;
  PtzControlStore _ptzControlStore;
  FavoriteStore _favoriteStore;
  HomeStore _homeStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gridCameraStore = Provider.of(context);
    _cameraStore = Provider.of(context);
    _ptzControlStore = Provider.of(context);
    _favoriteStore = Provider.of(context);
    _homeStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 60,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const IconAssets(
                    name: "delete_one_cam",
                    color: Colors.white,
                    width: 26,
                  ),
                  onPressed: _cameraStore.delete,
                ),
                IconButton(
                  icon: const IconAssets(
                      name: "delete_four_cam", color: Colors.white),
                  onPressed: _cameraStore.deleteAll,
                ),
                IconButton(
                  icon: const IconAssets(name: "favorite", color: Colors.white),
                  onPressed: () {
                    _favoriteStore.setNavigateValue(true);
                    _homeStore.setActiveScreen('favoritesList');
                    Navigator.of(context).pushNamed(Routes.favoritesList);
                  },
                ),
                IconButton(
                  onPressed: () {
                    _gridCameraStore.toggleFullGrid();
                    if (_cameraStore.camera == null) return;
                    _ptzControlStore.cancelPtz();
                    int page = _cameraStore.camera.position ~/
                        _gridCameraStore.numberCameraOfGrid;
                    _gridCameraStore.setPage(page);
                  },
                  icon: IconAssets(
                    name: "${_gridCameraStore.numberCameraOfGrid == 4 ? 1 : 4}",
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Observer(
                builder: (_) {
                  return Text(
                    "${widget.currentPage}/${widget.pageCount}",
                    style: TextStyle(
                      color: _gridCameraStore.isSingleMode
                          ? Colors.grey[700]
                          : Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
