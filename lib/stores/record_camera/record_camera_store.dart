import 'dart:typed_data';

import 'package:boilerplate/constants/strings.dart';
import 'package:boilerplate/data/repository/gateway_repository.dart';
import 'package:boilerplate/data/repository/vms_repository.dart';
import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:save_in_gallery/save_in_gallery.dart';
import 'package:toast/toast.dart';

part 'record_camera_store.g.dart';

class RecordCameraStore = _RecordCameraStore with _$RecordCameraStore;

abstract class _RecordCameraStore with Store {
  // final _imageSaver = ImageSaver();
  final VmsRepository vmsRepository;
  final GatewayRepository gatewayRepository;

  _RecordCameraStore(this.vmsRepository, this.gatewayRepository);

  @observable
  bool isTakingPicture = false;

  @observable
  Uint8List imageBytes;

  @action
  Future savePicture(
      Camera camera, Uint8List snapshot, BuildContext context) async {
    try {
      if (await Permission.storage.request().isGranted) {
        isTakingPicture = true;
        String name =
            "${DateFormat("yyyyMMdd-HHmmSS").format(DateTime.now())}_${camera.name.replaceAll(" ", "_")}";
        imageBytes = snapshot;
        // await _imageSaver.saveImage(
        //   imageBytes: imageBytes,
        //   imageName: name,
        //   directoryName: Strings.appName,
        // );
        // Toast.show(
        //     Translate.getString("live_view.save_success", context), context,
        //     duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        await Future.delayed(Duration(seconds: 2));
      }
    } catch (e) {
      Toast.show(Translate.getString("live_view.save_fail", context), context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
    isTakingPicture = false;
    imageBytes = null;
  }

  @action
  Future recordVideo(Camera camera, BuildContext context,
      [DateTime timeSelected]) async {}
}

class Execution {
  final int id;
  final Camera camera;
  final String path;
  final DateTime startTime;
  final DateTime position;

  Execution(this.id, this.camera, this.path, this.startTime, [this.position]);
}
