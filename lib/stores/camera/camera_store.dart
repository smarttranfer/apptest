import 'dart:async';
import 'package:boilerplate/data/repository/camera_repository.dart';
import 'package:boilerplate/data/repository/device_repository.dart';
import 'package:boilerplate/data/repository/gateway_repository.dart';
import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/models/device/device.dart';
import 'package:mobx/mobx.dart';

part 'camera_store.g.dart';

class CameraStore = _CameraStore with _$CameraStore;

// dùng để quản lý các cam xem trực tiếp
abstract class _CameraStore with Store {
  final CameraRepository cameraRepository;
  final DeviceRepository deviceRepository;
  final GatewayRepository gatewayRepository;

  _CameraStore(
    this.cameraRepository,
    this.deviceRepository,
    this.gatewayRepository,
  );

  @observable
  List<Camera> listCamera = [];

  @observable
  List<Camera> listCameraSelected = [];

  // camera selected
  @observable
  Camera camera;

  @observable
  String cameraNameFilter = '';

  @action
  setDeviceNameFilter(String value) {
    cameraNameFilter = value;
  }

  @action
  Future findAll() async {
    List<Camera> list = await cameraRepository.findAll();
    this.listCameraSelected =
        List<Camera>.from(list).map((e) => Camera.fromMap(e.toMap())).toList();
    if (list.length > 0) {
      list.sort((a, b) => a.position - b.position);
      if (camera == null) camera = list[0];
      Camera lastCamera = list.lastWhere((element) => element != null);
      if (lastCamera != null) {
        for (int i = 0; i < lastCamera.position; i++) {
          if (list[i].position != i) list.insert(i, null);
        }
      }
    }
    while (list.length < 4 || list.length % 4 != 0) {
      list.add(null);
    }
    this.listCamera = list;
  }

  @action
  setCamera(Camera camera) {
    print("select cam ${camera?.position}");
    this.camera = camera;
  }

  @action
  addCameraToDB(Device device, [int position]) async {
    if (position == null) {
      try {
        position = this.listCamera.indexOf(null);
        if (position == -1) position = this.listCamera.length;
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
    await cameraRepository.insert(camera);
    findAll();
  }

  @action
  addCameraToListSelected(Device device, [int position]) async {
    if (position == null) {
      try {
        position = this.listCameraSelected.indexOf(null);
        if (position == -1) position = this.listCameraSelected.length;
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
    this.listCameraSelected.add(camera);
  }

  @action
  addAllCamera(int gatewayId) async {
    removeCameraByGatewayId(gatewayId);
    int position = 0;
    List<Device> listDevice =
        await deviceRepository.getAllByGatewayId(gatewayId);
    listDevice = listDevice
        .where((element) =>
            element.name.toLowerCase().contains(cameraNameFilter.toLowerCase()))
        .toList();
    List<Camera> listCamera = [];
    for (int i = 0; i < listDevice.length; i++) {
      listCamera.add(Camera(
        id: listDevice[i].id,
        name: listDevice[i].name,
        gatewayId: gatewayId,
        position: i + position,
        status: listDevice[i].status,
        function: listDevice[i].function,
        links: listDevice[i].links,
        controllable: listDevice[i].controllable,
      ));
    }
    this.listCameraSelected.addAll(listCamera);
    this.listCameraSelected = this.listCameraSelected;
  }

  @action
  insertAllCamera(List<Camera> listCameraAdded) async {
    await cameraRepository.insertMulti(listCameraAdded);
    findAll();
  }

  @action
  removeCamera(Device device) async {
    await cameraRepository.deleteById(device.id);
    findAll();
  }

  @action
  removeCameraFromListSelected(Device device) {
    this.listCameraSelected.removeWhere((element) => element.id == device.id);
  }

  @action
  removeCameraFromDB(int gatewayId) async {
    await cameraRepository.deleteByGatewayId(gatewayId);
    findAll();
  }

  @action
  removeCameraByGatewayId(int gatewayId) {
    this.listCameraSelected.removeWhere((element) =>
        element.gatewayId == gatewayId &&
        element.name.toLowerCase().contains(cameraNameFilter.toLowerCase()));
  }

  @action
  Future showListCameraSelected() async {
    List<Camera> listCameraOrigin =
        this.listCamera.where((element) => element != null).toList();
    List<Camera> listCameraNeedInsert = this
        .listCameraSelected
        .where((element) => !listCameraOrigin.contains(element))
        .toList();
    List<Camera> listCameraNeedRemove = listCameraOrigin
        .where((element) => !this.listCameraSelected.contains(element))
        .toList();
    await cameraRepository.insertMulti(listCameraNeedInsert);
    await removeListCameras(listCameraNeedRemove);
    for (Camera camera in this.listCameraSelected) {
      camera.position = this.listCameraSelected.indexOf(camera);
      await cameraRepository.update(camera);
    }
    this.listCamera = [];
    findAll();
  }

  Future removeListCameras(List<Camera> list) async {
    for (Camera camera in list) await cameraRepository.delete(camera);
  }

  @action
  Future delete() async {
    this.listCameraSelected.removeWhere((element) => element.id == camera.id);
    await cameraRepository.delete(camera);
    listCamera[camera.position] = null;
    camera = null;
    this.listCamera = this.listCamera;
    this.listCameraSelected = this.listCameraSelected;
  }

  @action
  Future deleteAll() async {
    listCamera = [null, null, null, null];
    listCameraSelected = [];
    camera = null;
    await cameraRepository.deleteAll();
  }

  @action
  Future update(Camera camera) async {
    await cameraRepository.update(camera);
  }

  @action
  dispose() {
    camera = null;
    listCamera = [null, null, null, null];
    listCameraSelected = [];
    cameraNameFilter = "";
  }
}
