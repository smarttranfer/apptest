import 'dart:async';

import 'package:boilerplate/data/network/dio/dio_client.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:dio/dio.dart';

class VmsApi {
  // dio instance
  final DioClient _dioClient;

  // injecting dio instance
  VmsApi(this._dioClient);

  Future controlCamera(Gateway gateway, String cameraId, String control) async {
    final String url =
        "${gateway.protocol}://${gateway.domainName}:${gateway.port}/vms/api/monitors/ptz/$cameraId";
    try {
      await _dioClient.post(url,
          queryParameters: {"control": control},
          options: Options(
            headers: {"authorization": "Bearer ${gateway.token}"},
          ));
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future focus(Gateway gateway, String cameraId, String control) async {
    final String url =
        "${gateway.protocol}://${gateway.domainName}:${gateway.port}/vms/api/monitors/focus/$cameraId";
    try {
      await _dioClient.post(url,
          queryParameters: {"control": control},
          options: Options(
            headers: {"authorization": "Bearer ${gateway.token}"},
          ));
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future monitorEventsByTime(Gateway gateway, String cameraId, String startTime,
      String endTime, int page) async {
    final String url =
        "${gateway.protocol}://${gateway.domainName}:${gateway.port}/vms/api/monitor_events/page/$cameraId";
    try {
      final res = await _dioClient.get(
        url,
        options: Options(
          headers: {"authorization": "Bearer ${gateway.token}"},
        ),
        queryParameters: {
          'starttime': startTime,
          'endtime': endTime,
          'page': page
        },
      );
      return res;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<String> merge(Gateway gateway, String cameraId, String startTime,
      String endTime) async {
    final String url =
        "${gateway.protocol}://${gateway.domainName}:${gateway.port}/vms/api/monitor_events/merge/$cameraId";
    try {
      final res = await _dioClient.get(url,
          queryParameters: {
            "starttime": startTime,
            "endtime": endTime,
          },
          options: Options(
            headers: {"authorization": "Bearer ${gateway.token}"},
          ));
      return res["videoDownloadUrl"];
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
