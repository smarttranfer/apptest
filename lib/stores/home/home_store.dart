import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

class HomeStore = _HomeStore with _$HomeStore;

abstract class _HomeStore with Store {
  // store variables:-----------------------------------------------------------
  @observable
  String currentScreen = "liveCamera";

  @observable
  String regionCode = "";

  @observable
  String currentRouteName = "";

  @observable
  bool firstTimeOpenApp = false;

  @observable
  bool navigateFromLogin = false;

  @observable
  bool isHavePhotoPermission = false;

  @observable
  bool isAuthenticateApp = false;

  // actions:-------------------------------------------------------------------
  @action
  setActiveScreen(String screen) {
    currentScreen = screen;
  }

  @action
  setCurrentRoute(String data) {
    currentRouteName = data;
  }

  @action
  dispose() {
    currentScreen = "liveCamera";
    firstTimeOpenApp = false;
  }
}
