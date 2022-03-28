import 'dart:async';

import 'package:boilerplate/data/local/datasources/camera/camera_datasource.dart';
import 'package:boilerplate/models/camera/camera.dart';

class CameraRepository {
  final CameraDataSource _dataSource;

  CameraRepository(this._dataSource);

  Future<List<Camera>> findAll() async {
    return await _dataSource.findAll();
  }

  insert(Camera camera) async {
    await _dataSource.insert(camera);
  }

  Future insertMulti(List<Camera> list) async {
    await _dataSource.insertMulti(list);
  }

  update(Camera camera) async {
    await _dataSource.update(camera);
  }

  updateToken(String token, int gatewayId) async {
    await _dataSource.updateToken(token, gatewayId);
  }

  delete(Camera camera) async {
    await _dataSource.delete(camera);
  }

  deleteById(String id) async {
    await _dataSource.deleteById(id);
  }

  deleteByGatewayId(int id) async {
    await _dataSource.deleteByGatewayId(id);
  }

  Future deleteAll() => _dataSource
      .deleteAll()
      .then((value) => print("------ Remove Camera"))
      .catchError((error) => throw error);
}
