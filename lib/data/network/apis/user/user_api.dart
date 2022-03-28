import 'dart:async';

import 'package:boilerplate/constants/endpoints.dart';
import 'package:boilerplate/data/network/dio/dio_client.dart';
import 'package:boilerplate/widgets/list_region_select.dart';

class UserApi {
  // dio instance
  final DioClient _dioClient;

  // injecting dio instance
  UserApi(this._dioClient);

  Future getAllContinents() async {
    final response = await _dioClient.get(Endpoints.continentsUrl);
    return response.map<Region>((list) => Region.fromJson(list)).toList();
  }

  Future getAllCountries() async {
    final response = await _dioClient.get(Endpoints.countriesUrl);
    return response.map<Region>((list) => Region.fromJson(list)).toList();
  }
}
