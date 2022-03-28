import 'package:boilerplate/constants/mode_type.dart';
import 'package:mobx/mobx.dart';

part 'grid_camera_store.g.dart';

class GridCameraStore = _GridCameraStore with _$GridCameraStore;

abstract class _GridCameraStore with Store {
  _GridCameraStore();

  @observable
  int numberCameraOfGrid = 4;

  @observable
  int currentPage = 0;

  @observable
  int _page = 0;

  @computed
  int get page => _page;

  @observable
  ModeType mode = ModeType.GRID_MODE;

  @observable
  bool isShowBar = true;

  @computed
  bool get isSingleMode =>
      mode == ModeType.PTZ_MODE || mode == ModeType.ZOOM_MODE;

  @computed
  bool get isPtzMode => mode == ModeType.PTZ_MODE;

  @computed
  bool get isZoomMode => mode == ModeType.ZOOM_MODE;

  @action
  void setCurrentPage(int number) {
    currentPage = number;
  }

  @action
  void setNumberCameraOfGrid(int number) {
    numberCameraOfGrid = number;
  }

  @action
  void toggleFullGrid() {
    mode = ModeType.GRID_MODE;
    if (numberCameraOfGrid == 1) {
      numberCameraOfGrid = 4;
    } else {
      numberCameraOfGrid = 1;
    }
  }

  @action
  void togglePtzMode() {
    mode = mode == ModeType.PTZ_MODE ? ModeType.GRID_MODE : ModeType.PTZ_MODE;
  }

  @action
  void toggleZoomMode() {
    mode = mode == ModeType.ZOOM_MODE ? ModeType.GRID_MODE : ModeType.ZOOM_MODE;
  }

  @action
  void setPage(int page) {
    this._page = page;
    currentPage = page;
  }

  @action
  void toggleShowControlBar() {
    isShowBar = !isShowBar;
  }

  @action
  void reset() {
    mode = ModeType.GRID_MODE;
  }

  @action
  dispose() {
    currentPage = 0;
    numberCameraOfGrid = 4;
  }
}
