import 'package:boilerplate/constants/db_constants.dart';
import 'package:boilerplate/models/device/device.dart';
import 'package:sembast/sembast.dart';

class DeviceDataSource {
  final _store = stringMapStoreFactory.store(DBConstants.DEVICE_STORE_NAME);

  final Future<Database> _db;

  DeviceDataSource(this._db);

  // DB functions:--------------------------------------------------------------
  Future insert(Device device) async {
    await _store.record(device.id).put(await _db, device.toJson());

  }

  Future insertMulti(List<Device> list) async {
    await _store
        .records(list.map((e) => "${e.id}_${e.gatewayId}"))
        .put(await _db, list.map((e) => e.toJson()).toList());

  }

  Future<List<Device>> getAll() async {
    final list = await _store.find(await _db);
    return list.map((e) {
      final device = Device.fromDB(e.value);
      device.id = e.key;
      return device;
    }).toList();
  }

  Future<List<Device>> getAllByGatewayId(int gatewayId) async {
    final finder = Finder(filter: Filter.equals("gatewayId", gatewayId));
    final list = await _store.find(await _db, finder: finder);
    return list.map((e) {
      final device = Device.fromDB(e.value);
      device.id = e.key;
      return device;
    }).toList();
  }

  Future<List<Device>> findAll() async {
    final list = await _store.find(await _db);
    return list.map((e) {
      final device = Device.fromDB(e.value);
      device.id = e.key;
      return device;
    }).toList();
  }

  Future<int> delete(Device device) async {
    final finder = Finder(filter: Filter.byKey(device.id));
    return await _store.delete(await _db, finder: finder);
  }

  Future<int> deleteByGatewayId(int gatewayId) async {
    final finder = Finder(filter: Filter.equals("gatewayId", gatewayId));
    return await _store.delete(await _db, finder: finder);
  }

  Future<int> deleteByFilter({List<Filter> filters}) async {
    final finder = Finder(filter: Filter.and(filters));
    return await _store.delete(await _db, finder: finder);
  }

  Future deleteAll() async {
    await _store.drop(await _db);
  }
}
