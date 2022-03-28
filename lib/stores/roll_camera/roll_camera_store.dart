import 'package:boilerplate/constants/strings.dart';
import 'package:boilerplate/data/repository/gateway_repository.dart';
import 'package:boilerplate/data/repository/vms_repository.dart';
import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/models/device/device.dart';
import 'package:boilerplate/models/event/event.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/utils/dio/dio_error_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:mobx/mobx.dart';

part 'roll_camera_store.g.dart';

class RollCameraStore = _RollCameraStore with _$RollCameraStore;

abstract class _RollCameraStore with Store {
  final GatewayRepository gatewayRepository;
  final VmsRepository _vmsRepository;

  _RollCameraStore(this.gatewayRepository, this._vmsRepository);

  @observable
  Camera camera;

  @observable
  Camera cameraSelected;

  @observable
  DateTime timeSelected = DateTime.now().subtract(const Duration(days: 1));

  @observable
  bool isShowBar = true;

  @observable
  bool isShowSpeed = false;

  @observable
  List<Event> events = [];

  @observable
  Event event;

  @observable
  VlcPlayerController controller;

  @action
  setCamera(Camera camera) {
    this.camera = camera;
  }

  @action
  setEvent(Event event) {
    this.event = event;
  }

  @action
  setTimeSelected(DateTime timeSelected) {
    this.timeSelected = timeSelected;
  }

  @action
  setController(VlcPlayerController controller) {
    this.controller = controller;
  }

  @action
  toggleShowSpeed() {
    isShowSpeed = !isShowSpeed;
  }

  @action
  addCamera(Device device) async {
    Camera camera = Camera(
      id: device.id,
      name: device.name,
      gatewayId: device.gatewayId,
    );
    this.cameraSelected = Camera.clone(camera);
  }

  @action
  getEventsPLayBack(BuildContext context) async {
    this.camera = this.cameraSelected;
    Gateway gateway = await gatewayRepository.findById(camera.gatewayId);
    try {
      final response = await _vmsRepository.monitorEventsByTime(
          gateway,
          camera.id.split("_").first,
          timeSelected.subtract(Duration(days: 1)).toUtc().toIso8601String(),
          timeSelected
              .add(Duration(hours: Strings.timeValueRollCamera))
              .toUtc()
              .toIso8601String(),
          1);
      events =
          response["data"].map<Event>((item) => Event.fromJson(item)).toList();
      if (response['currentPage'] < response['pageCount']) {
        for (var i = 2; i <= response['pageCount']; i++) {
          final responseCallBack = await _vmsRepository.monitorEventsByTime(
              gateway,
              camera.id.split("_").first,
              timeSelected
                  .subtract(const Duration(days: 1))
                  .toUtc()
                  .toIso8601String(),
              timeSelected
                  .add(Duration(hours: Strings.timeValueRollCamera))
                  .toUtc()
                  .toIso8601String(),
              i);
          events.addAll(responseCallBack["data"]
              .map<Event>((item) => Event.fromJson(item))
              .toList());
        }
      }

      if (events.isNotEmpty) {
        event = events.last;
        timeSelected = DateTime.parse(event.startTime).toLocal();
      }
    } on DioError catch (e) {
      showDioError(e, context);
    }
  }

  bool isTimeBetween(String start, String end, DateTime dateTime) {
    try {
      DateTime startTime = DateTime.parse(start);
      DateTime endTime = DateTime.parse(end);
      return startTime.difference(dateTime).inSeconds <= 0 &&
          endTime.difference(dateTime).inSeconds >= 0;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  @action
  delete() {
    camera = null;
  }

  @action
  void toggleShowControlBar() {
    isShowBar = !isShowBar;
  }

  @action
  void reset() {
    isShowBar = true;
    isShowSpeed = false;
  }

  @action
  setNextEvent() {
    try {
      int curPosition = events.indexOf(event);
      event = events[curPosition + 1];
    } catch (e) {
      event = null;
    }
  }

  @action
  dispose() {
    camera = null;
    events = [];
    event = null;
    cameraSelected = null;
  }
}
