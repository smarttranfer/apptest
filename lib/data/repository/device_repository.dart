import 'dart:async';

import 'package:boilerplate/data/local/datasources/device/device_datasource.dart';
import 'package:boilerplate/data/network/apis/device/device.dart';
import 'package:boilerplate/models/device/device.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:sembast/sembast.dart';

class DeviceRepository {
  final DeviceDataSource _dataSource;
  final DeviceApi _deviceApi;

  DeviceRepository(this._dataSource, this._deviceApi);

  Future fetchData(Gateway gateway) async {
    return await _deviceApi.fetchData(gateway);
  }

  Future insertListDevicesToDB(list) async {
    return await _dataSource.insertMulti(list);
  }

  Future<List<Device>> findAll() async {
    return await _dataSource.findAll();
  }

  Future<List<Device>> getAll() async {
    return await _dataSource.getAll();
  }

  Future<List<Device>> getAllByGatewayId(int gatewayId) async {
    return await _dataSource.getAllByGatewayId(gatewayId);
  }

  deleteByGatewayId(int gatewayId) async {
    await _dataSource.deleteByGatewayId(gatewayId);
  }

  delete(Device device) {
    _dataSource.delete(device);
  }

  deleteByFilter(Device device) async {
    final List<Filter> filters = [];
    filters.add(Filter.equals("id", device.id.split("_")[0]));
    filters.add(Filter.equals("gatewayId", device.gatewayId));
    await _dataSource.deleteByFilter(filters: filters);
  }

  Future deleteAll() => _dataSource
      .deleteAll()
      .then((value) => print("------ Remove Device"))
      .catchError((error) => throw error);
}
