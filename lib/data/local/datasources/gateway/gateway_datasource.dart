import 'package:boilerplate/constants/db_constants.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:sembast/sembast.dart';

class GatewayDataSource {
  final _store = intMapStoreFactory.store(DBConstants.GATEWAY_STORE_NAME);

  final Future<Database> _db;

  GatewayDataSource(this._db);

  // DB functions:--------------------------------------------------------------
  Future insert(Gateway gateway) async {
    return await _store.add(await _db, gateway.toJson());
  }

  Future insertMulti(List<Gateway> list) async {
    await _store
        .records(list.map((e) => e.id))
        .put(await _db, list.map((e) => e.toJson()).toList());
  }

  Future<Gateway> findByFilter({List<Filter> filters}) async {
    final finder = Finder(filter: Filter.and(filters));
    final recordSnapshots = await _store.findFirst(await _db, finder: finder);
    if (recordSnapshots == null) return null;
    final gateway = Gateway.fromJson(recordSnapshots.value);
    gateway.id = recordSnapshots.key;
    return gateway;
  }

  Future<Gateway> findByName(String name) async {
    final finder = Finder(filter: Filter.equals("name", name));
    final data = await _store.findFirst(await _db, finder: finder);
    if (data == null) return null;
    final gateway = Gateway.fromJson(data.value);
    gateway.id = data.key;
    return gateway;
  }

  Future<List<Gateway>> getAll() async {
    final list = await _store.find(await _db);
    return list.map((e) {
      final device = Gateway.fromJson(e.value);
      device.id = e.key;
      return device;
    }).toList();
  }

  Future<Stream<List<Gateway>>> findAll() async {
    return _store.query().onSnapshots(await _db).map((snapshots) {
      return snapshots.map((snapshot) {
        final device = Gateway.fromJson(snapshot.value);
        device.id = snapshot.key;
        return device;
      }).toList();
    });
  }

  Future<int> update(Gateway gateway) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(gateway.id));
    return await _store.update(await _db, gateway.toJson(), finder: finder);
  }

  Future<int> updateVmsToken(Gateway gateway) async {
    final finder = Finder(filter: Filter.equals("root", true));
    return await _store.update(await _db, gateway.toJson(), finder: finder);
  }

  Future<int> delete(Gateway gateway) async {
    final finder = Finder(filter: Filter.byKey(gateway.id));
    return await _store.delete(await _db, finder: finder);
  }

  Future deleteAll() async {
    await _store.drop(await _db);
  }
}
