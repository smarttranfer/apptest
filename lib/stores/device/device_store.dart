import 'dart:async';

import 'package:boilerplate/data/repository/device_repository.dart';
import 'package:boilerplate/models/device/device.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/stores/error/error_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:boilerplate/utils/dio/dio_error_util.dart';

part 'device_store.g.dart';

class DeviceStore = _DeviceStore with _$DeviceStore;

abstract class _DeviceStore with Store {
  final DeviceRepository deviceRepository;

  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();

  _DeviceStore(this.deviceRepository);

  @observable
  List<Device> listDevice = [];

  @observable
  bool success = false;

  @action
  findAll() async {
    listDevice = await deviceRepository.findAll();
  }

  @action
  Future fetchData(Gateway gateway, BuildContext context) async {
    try {
      success = true;
      return await deviceRepository.fetchData(gateway);
    } on DioError catch (e) {
      showDioError(e, context);
      success = false;
      errorStore.errorMessage = "manage_device.can_not_get_list_camera";
    }
  }

  @action
  insertListDevicesToDB(List<Device> listCam) async {
    await deviceRepository.insertListDevicesToDB(listCam);
    findAll();
  }

  @action
  Future delete(Device device) async {
    await deviceRepository.delete(device);
  }

  @action
  Future deleteByFilter(Device device) async {
    await deviceRepository.deleteByFilter(device);
  }

  @action
  Future deleteByGatewayId(int gatewayId) async {
    await deviceRepository.deleteByGatewayId(gatewayId);
    findAll();
  }

  @action
  dispose() {
    listDevice = [];
  }
}
