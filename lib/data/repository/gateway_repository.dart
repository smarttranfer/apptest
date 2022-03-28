import 'dart:async';

import 'package:boilerplate/data/local/datasources/gateway/gateway_datasource.dart';
import 'package:boilerplate/data/network/apis/gateway/gateway.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:sembast/sembast.dart';

class GatewayRepository {
  // data source object
  final GatewayDataSource _dataSource;
  final GatewayApi _gatewayApi;

  // constructor
  GatewayRepository(this._dataSource, this._gatewayApi);

  // Gateway: ---------------------------------------------------------------------

  Future<Gateway> findById(int id) async {
    final List<Filter> filters = [];
    filters.add(Filter.byKey(id));
    return await _dataSource.findByFilter(filters: filters);
  }

  Future<Gateway> findRootGateway() async {
    final List<Filter> filters = [];
    filters.add(Filter.equals("root", true));
    return await _dataSource.findByFilter(filters: filters);
  }

  Future<Gateway> findByFilter(Gateway gateway) async {
    final List<Filter> filters = [];
    filters.add(Filter.equals("domainName", gateway.domainName));
    filters.add(Filter.equals("port", gateway.port));
    filters.add(Filter.equals("username", gateway.username));
    return await _dataSource.findByFilter(filters: filters);
  }

  Future<Gateway> findByName(String name) async {
    return await _dataSource.findByName(name);
  }

  Future<Map<String, dynamic>> loginToVms(Gateway gateway) async {
    return await _gatewayApi.loginToVms(gateway);
  }

  Future<Map<String, dynamic>> getAccessToken(Gateway gateway) async {
    return await _gatewayApi.getAccessToken(gateway);
  }

  Future<Stream<List<Gateway>>> findAll() async {
    return await _dataSource.findAll();
  }

  Future<List<Gateway>> getAll() async {
    return await _dataSource.getAll();
  }

  Future createOrUpdate(Gateway gateway) async {
    if (gateway.id == null) {
      return await _dataSource.insert(gateway);
    }
    await _dataSource.update(gateway);
    Gateway gatewayFound = await findById(gateway.id);
    return gatewayFound.id;
  }

  Future updateVmsToken(Gateway gateway) async {
    await _dataSource.updateVmsToken(gateway);
  }

  Future<int> delete(Gateway gateway) async {
    return await _dataSource
        .delete(gateway)
        .then((id) => id)
        .catchError((error) => throw error);
  }

  Future deleteAll() => _dataSource
      .deleteAll()
      .then((value) => print("------ Remove Gateway"))
      .catchError((error) => throw error);
}
