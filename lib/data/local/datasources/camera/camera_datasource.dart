import 'package:boilerplate/constants/db_constants.dart';
import 'package:boilerplate/models/camera/camera.dart';
import 'package:sembast/sembast.dart';

class CameraDataSource {
  final _store = stringMapStoreFactory.store(DBConstants.CAMERA_STORE_NAME);

  final Future<Database> _db;

  CameraDataSource(this._db);

  Future insert(Camera camera) async {
    await _store.record(camera.id).put(await _db, camera.toMap());
  }

  Future insertMulti(List<Camera> list) async {
    await _store
        .records(list.map((e) => e.id))
        .put(await _db, list.map((e) => e.toMap()).toList());
  }

  Future<List<Camera>> findAll() async {
    final list = await _store.find(await _db);
    return list.map((e) {
      final camera = Camera.fromMap(e.value);
      camera.id = e.key;
      return camera;
    }).toList();
  }

  Future<int> update(Camera camera) async {
    final finder = Finder(filter: Filter.byKey(camera.id));
    return await _store.update(await _db, camera.toMap(), finder: finder);
  }

  Future<int> updateToken(String token, int gatewayId) async {
    final finder = Finder(filter: Filter.equals("gatewayId", gatewayId));
    return await _store.update(await _db, {"token": token}, finder: finder);
  }

  Future<int> delete(Camera camera) async {
    final finder = Finder(filter: Filter.byKey(camera.id));
    return await _store.delete(await _db, finder: finder);
  }

  Future<int> deleteById(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    return await _store.delete(await _db, finder: finder);
  }

  Future<int> deleteByGatewayId(int id) async {
    final finder = Finder(filter: Filter.equals("gatewayId", id));
    return await _store.delete(await _db, finder: finder);
  }

  Future deleteAll() async {
    await _store.drop(await _db);
  }
}
