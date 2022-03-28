import 'package:boilerplate/models/device/device.dart';
import 'package:mobx/mobx.dart';

part 'camera_preview_store.g.dart';

class CameraPreviewStore = _CameraPreviewStore with _$CameraPreviewStore;

// dùng để quản lý các cam xem trực tiếp
abstract class _CameraPreviewStore with Store {
  _CameraPreviewStore();

  // device selected
  @observable
  Device device;

  @action
  setDevice(Device device) {
    this.device = device;
  }
}
