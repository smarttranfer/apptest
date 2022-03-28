import 'package:boilerplate/data/repository/gateway_repository.dart';
import 'package:boilerplate/data/repository/vms_repository.dart';
import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/utils/dio/dio_error_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'ptz_control_store.g.dart';

class PtzControlStore = _PtzControlStore with _$PtzControlStore;

abstract class _PtzControlStore with Store {
  final VmsRepository vmsRepository;
  final GatewayRepository gatewayRepository;

  _PtzControlStore(this.vmsRepository, this.gatewayRepository);

  @observable
  bool isZoom = false;

  @observable
  bool isFocus = false;

  @observable
  bool isRotating = false;

  @observable
  String actionControl = "";

  @action
  Future ptzControl(Camera camera, String action, BuildContext context) async {
    try {
      actionControl = action;
      Gateway gateway = await gatewayRepository.findById(camera.gatewayId);
      return await vmsRepository.controlCamera(
          gateway, camera.id.split("_").first, action);
    } on DioError catch (e) {
      showDioError(e, context);
    }
  }

  @action
  Future focus(Camera camera, String action, BuildContext context) async {
    try {
      Gateway gateway = await gatewayRepository.findById(camera.gatewayId);
      return await vmsRepository.focus(
          gateway, camera.id.split("_").first, action);
    } on DioError catch (e) {
      showDioError(e, context);
    }
  }

  @action
  Future moveStop(Camera camera, BuildContext context) async {
    try {
      actionControl = "";
      Gateway gateway = await gatewayRepository.findById(camera.gatewayId);
      return await vmsRepository.controlCamera(
          gateway, camera.id.split("_").first, "moveStop");
    } on DioError catch (e) {
      showDioError(e, context);
    }
  }

  @action
  void setControlAction(String controlAction) {
    actionControl = controlAction;
  }

  @action
  Future rotate(Camera camera, BuildContext context) async {
    isRotating = !isRotating;
    Gateway gateway = await gatewayRepository.findById(camera.gatewayId);
    try {
      if (!isRotating) {
        await vmsRepository.controlCamera(
            gateway, camera.id.split("_").first, "moveStop");
      } else {
        await vmsRepository.controlCamera(
            gateway, camera.id.split("_").first, "moveConLeft");
      }
    } on DioError catch (e) {
      showDioError(e, context);
    }
  }

  @action
  void toggleZoom() {
    isZoom = !isZoom;
    isFocus = false;
  }

  @action
  void toggleFocus() {
    isFocus = !isFocus;
    isZoom = false;
  }

  @action
  void cancelPtz() {
    isFocus = false;
    isZoom = false;
  }
}
