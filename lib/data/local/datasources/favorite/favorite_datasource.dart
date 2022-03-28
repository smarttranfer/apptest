import 'package:boilerplate/constants/db_constants.dart';
import 'package:boilerplate/models/favorite/favorite.dart';
import 'package:sembast/sembast.dart';

class FavoriteDataSource {
  final _store = intMapStoreFactory.store(DBConstants.FAVORITE_STORE_NAME);

  final Future<Database> _db;

  FavoriteDataSource(this._db);

  // DB functions:--------------------------------------------------------------
  Future insert(Favorite favorite) async {
    await _store.add(await _db, favorite.toMap());
  }

  Future<List<Favorite>> findAll() async {
    final list = await _store.find(await _db);
    return list.map((e) {
      final favorite = Favorite.fromMap(e.value);
      favorite.id = e.key;
      return favorite;
    }).toList();
  }

  Future<Favorite> findByName(String name) async {
    final finder = Finder(filter: Filter.equals("name", name));
    final data = await _store.findFirst(await _db, finder: finder);
    if (data == null) return null;
    final favorite = Favorite.fromMap(data.value);
    favorite.id = data.key;
    return favorite;
  }

  Future<int> update(Favorite favorite) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(favorite.id));
    return await _store.update(await _db, favorite.toMap(), finder: finder);
  }

  Future<int> delete(Favorite favorite) async {
    final finder = Finder(filter: Filter.byKey(favorite.id));
    return await _store.delete(await _db, finder: finder);
  }

  Future deleteAll() async {
    await _store.drop(await _db);
  }
}
