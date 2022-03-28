import 'dart:async';
import 'dart:convert';

import 'package:boilerplate/constants/endpoints.dart';
import 'package:boilerplate/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:dio/dio.dart';

class GatewayApi {
  // dio instance
  final DioClient _dioClient;
  final SharedPreferenceHelper _sharedPreferenceHelper;

  // injecting dio instance
  GatewayApi(this._dioClient, this._sharedPreferenceHelper);

  Future<Map<String, dynamic>> loginToVms(Gateway gateway) async {
    String uUID = await _sharedPreferenceHelper.uUID;
    final urlLoginToVms =
        "${gateway.protocol}://${gateway.domainName}:${gateway.port}/vms/api/host/login";
    String basicAuth = 'Basic ' +
        base64Encode(utf8.encode('${Endpoints.user}:${Endpoints.pass}'));
    Map<String, String> bodyReq = {};
    if (uUID == null)
      bodyReq = {
        "user": gateway.username,
        "pass": gateway.password,
      };
    else
      bodyReq = {
        "user": gateway.username,
        "pass": gateway.password,
        "uuid": uUID
      };
    try {
      final resFromLogin = await _dioClient.post(urlLoginToVms,
          data: bodyReq,
          options: Options(headers: {"authorization": basicAuth}));
      return resFromLogin;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<Map<String, dynamic>> getAccessToken(Gateway gateway) async {
    String basicAuth = 'Basic ' +
        base64Encode(utf8.encode('${Endpoints.user}:${Endpoints.pass}'));
    final resFromLogin = await _dioClient.post(
        "${gateway.protocol}://${gateway.domainName}:${gateway.port}/vms/api/host/login",
        data: {"token": gateway.refreshToken},
        options: Options(headers: {"authorization": basicAuth}));
    return resFromLogin;
  }
}
