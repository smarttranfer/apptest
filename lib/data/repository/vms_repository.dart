import 'dart:async';

import 'package:boilerplate/data/network/apis/vms/vms.dart';
import 'package:boilerplate/models/gateway/gateway.dart';

class VmsRepository {
  final VmsApi _api;

  VmsRepository(this._api);

  Future controlCamera(Gateway gateway, String cameraId, String control) async {
    return _api.controlCamera(gateway, cameraId, control);
  }

  Future focus(Gateway gateway, String cameraId, String control) async {
    return _api.focus(gateway, cameraId, control);
  }

  Future monitorEventsByTime(Gateway gateway, String cameraId, String startTime,
      String endTime, int page) async {
    return _api.monitorEventsByTime(
        gateway, cameraId, startTime, endTime, page);
  }

  Future<String> merge(Gateway gateway, String cameraId, String startTime,
      String endTime) async {
    return _api.merge(gateway, cameraId, startTime, endTime);
  }
}
