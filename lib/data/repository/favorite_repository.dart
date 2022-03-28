import 'dart:async';

import 'package:boilerplate/data/local/datasources/favorite/favorite_datasource.dart';
import 'package:boilerplate/models/favorite/favorite.dart';

class FavoriteRepository {
  final FavoriteDataSource _dataSource;

  FavoriteRepository(this._dataSource);

  Future<List<Favorite>> findAll() async {
    return await _dataSource.findAll();
  }

  Future<Favorite> findByName(String name) async {
    return await _dataSource.findByName(name);
  }

  Future createOrUpdate(Favorite favorite) async {
    if (favorite.id == null) {
      return await _dataSource.insert(favorite);
    }
    return await _dataSource.update(favorite);
  }

  delete(Favorite favorite) async {
    await _dataSource.delete(favorite);
  }

  Future deleteAll() => _dataSource
      .deleteAll()
      .then((value) => print("------ Remove Favorite"))
      .catchError((error) => throw error);
}
