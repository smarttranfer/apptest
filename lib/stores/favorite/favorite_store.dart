import 'dart:async';

import 'package:boilerplate/data/repository/device_repository.dart';
import 'package:boilerplate/data/repository/favorite_repository.dart';
import 'package:boilerplate/data/repository/gateway_repository.dart';
import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/models/device/device.dart';
import 'package:boilerplate/models/favorite/favorite.dart';
import 'package:boilerplate/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';

part 'favorite_store.g.dart';

class FavoriteStore = _FavoriteStore with _$FavoriteStore;

abstract class _FavoriteStore with Store {
  final FavoriteRepository favoriteRepository;
  final GatewayRepository gatewayRepository;
  final DeviceRepository deviceRepository;

  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();

  // disposers
  List<ReactionDisposer> _disposers;

  _FavoriteStore(
      this.favoriteRepository, this.gatewayRepository, this.deviceRepository) {
    _disposers = [
      reaction((_) => isNotExistedInDb, resetNotExistedInDb, delay: 500),
    ];
  }

  @observable
  List<Favorite> listFavorite = [];

  @observable
  Favorite favorite;

  @observable
  List<Camera> listCamera = [];

  @observable
  bool isNotExistedInDb = true;

  @observable
  bool isNavigateFromLiveCam = false;

  @observable
  String actionControl = "add";

  @computed
  bool get isInvalidForm => favorite.name.isEmpty;

  @action
  void resetNotExistedInDb(bool value) {
    print('calling reset');
    isNotExistedInDb = true;
  }

  @action
  setActionControl(String action) {
    this.actionControl = action;
  }

  @action
  setNavigateValue(bool value) {
    this.isNavigateFromLiveCam = value;
  }

  @action
  findAll() async {
    this.listFavorite = await favoriteRepository.findAll();
  }

  @action
  addOrUpdate([Favorite data]) async {
    listCamera.forEach((element) {
      element.position = listCamera.indexOf(element);
    });
    await favoriteRepository.createOrUpdate(data ?? favorite);
    findAll();
  }

  @action
  validateForm() {
    if (favorite.name.isEmpty)
      errorStore.errorMessage = "favorite.input_group_name";
  }

  @action
  checkVmsExistedInDb() async {
    Favorite favoriteFoundByName =
        await favoriteRepository.findByName(this.favorite.name);
    if (favoriteFoundByName != null && favorite.id != favoriteFoundByName.id) {
      errorStore.errorMessage = "favorite.group_exist";
      isNotExistedInDb = false;
      return;
    }
    isNotExistedInDb = true;
  }

  @action
  dispose() {
    listCamera = [];
    listFavorite = [];
    favorite = null;
    for (final d in _disposers) {
      d();
    }
  }

  @action
  setFavorite(Favorite favorite) {
    this.favorite = favorite;
    if (favorite.id == null) {
      this.listCamera = [];
    }
    for (var item in favorite.listCamera) {
      this.listCamera.add(item);
    }
    setListCamera();
  }

  @action
  addCamera(Device device, [int position]) async {
    if (position == null) {
      try {
        position =
            this.listCamera.lastWhere((element) => element != null).position +
                1;
      } catch (e) {
        position = 0;
      }
    }
    Camera camera = Camera(
      id: device.id,
      name: device.name,
      gatewayId: device.gatewayId,
      position: position,
      status: device.status,
      function: device.function,
      controllable: device.controllable,
      links: device.links,
    );
    this.listCamera.add(camera);
    setListCamera();
  }

  @action
  setListCamera() {
    List<Camera> list = this.listCamera;
    if (list.length > 0) {
      list.sort((a, b) => a.position - b.position);
    }
    this.listCamera = getDistinctList(list);
  }

  @action
  addAllCamera(int gatewayId) async {
    int position;
    try {
      position =
          this.listCamera.lastWhere((element) => element != null).position;
    } catch (e) {
      position = 0;
    }
    List<Device> listDevice =
        await deviceRepository.getAllByGatewayId(gatewayId);
    List<Camera> listCamera = [];
    for (int i = 0; i < listDevice.length; i++) {
      listCamera.add(Camera(
        id: listDevice[i].id,
        name: listDevice[i].name,
        gatewayId: gatewayId,
        position: i + position,
        status: listDevice[i].status,
        function: listDevice[i].function,
        controllable: listDevice[i].controllable,
        links: listDevice[i].links,
      ));
    }
    this.listCamera.addAll(listCamera);
    setListCamera();
  }

  @action
  removeCamera(String deviceId) {
    this.listCamera.removeWhere((element) => element.id == deviceId);
    setListCamera();
  }

  @action
  removeCameraByGatewayId(int gatewayId) {
    this.listCamera.removeWhere((element) => element.gatewayId == gatewayId);
    setListCamera();
  }

  @action
  Future delete() async {
    await favoriteRepository.delete(favorite);
    findAll();
  }

  @action
  reorderCamera(int oldIndex, int newIndex) {
    Camera item = listCamera.removeAt(oldIndex);
    listCamera.insert(newIndex, item);
  }

  List<Camera> getDistinctList(List<Camera> list) {
    List<Camera> cams = new List();
    for (Camera cam in list) {
      if (!cams.contains(cam)) {
        cams.add(cam);
      }
    }
    return cams;
  }
}
