import 'dart:async';

import 'package:boilerplate/data/network/dio/dio_client.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:dio/dio.dart';

class DeviceApi {
  // dio instance
  final DioClient _dioClient;

  // injecting dio instance
  DeviceApi(this._dioClient);

  Future fetchData(Gateway gateway) async {
    final urlGetCam =
        "${gateway.protocol}://${gateway.domainName}:${gateway.port}/vms/api/vmsmanager/monitors";
    try {
      final res = await _dioClient.get(urlGetCam,
          options:
              Options(headers: {"authorization": "Bearer ${gateway.token}}"}));
      return res;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
