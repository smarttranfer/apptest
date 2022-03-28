import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:boilerplate/Notification/service/notification_service.dart';
import 'package:boilerplate/ui/event/Event_main.dart';
import 'package:boilerplate/constants/strings.dart';
import 'package:boilerplate/main.dart';
import 'package:boilerplate/models/device/device.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/device/device_store.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/live_camera/grid_camera_store.dart';
import 'package:boilerplate/stores/roll_camera/roll_camera_store.dart';
import 'package:boilerplate/ui/setup_app/verify_app.dart';
import 'package:boilerplate/utils/lifecycle/lifecycle_watcher_state.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/home_appbar.dart';
import 'package:boilerplate/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/widgets/side_bar_menu.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:boilerplate/StoredataScurety/StoreSercurity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:boilerplate/widgets/icon_assets.dart';

import '../../routes.dart';

abstract class HomeScreen extends StatefulWidget {}

abstract class HomeScreenState<Page extends HomeScreen>
    extends LifecycleWatcherState<Page> {
  NotificationService notificationService = NotificationService();
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  GatewayStore _gatewayStore;
  FavoriteStore _favoriteStore;
  GridCameraStore _gridCameraStore;
  RollCameraStore _rollCameraStore;
  CameraStore _cameraStore;
  HomeStore _homeStore;
  DeviceStore _deviceStore;
  Timer _timerLoginAgain;
  Timer _timerUpdateAccessToken;


  DateTime eventDate;
  TimeOfDay eventTime;

  @override
  void dispose() {
    super.dispose();
    _timerLoginAgain?.cancel();
    _timerUpdateAccessToken?.cancel();
  }

  void fcmMessageHandler(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => event_main()),
    );
  }

  void _showMessage(String Tile, String message) {
    if (!mounted) return;
    showFlash(
        context: context,
        duration: Duration(seconds: 3),
        builder: (_, controller) {
          return Flash(
            controller: controller,
            position: FlashPosition.top,
            borderRadius: BorderRadius.circular(20.0),
            child: InkWell(
              onTap: (){
                _homeStore.setActiveScreen('event');
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.event, (Route<dynamic> route) => false);
              },
              child:Container(
              height: MediaQuery.of(context).size.height / 7,
              width: MediaQuery.of(context).size.width / 1.1,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white.withOpacity(0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(left: 27, top: 7, bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                  height: 20,
                                  width: 20,
                                  child: IconAssets(
                                    name: "launcher",
                                    width: 20,
                                  )),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "BKAV Camera",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 10,
                                color: Colors.grey,
                              ),
                              Text(
                                "Bây giờ",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Icon(
                                Icons.add_alert_outlined,
                                size: 10,
                                color: Colors.grey,
                              ),
                            ],
                          )),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                Tile,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                message+"    ",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ));
        });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _homeStore = Provider.of(context);
    _favoriteStore = Provider.of(context);
    _gridCameraStore = Provider.of(context);
    _rollCameraStore = Provider.of(context);
    _gatewayStore = Provider.of(context);
    _cameraStore = Provider.of(context);
    _deviceStore = Provider.of(context);
    if (_homeStore.navigateFromLogin) {
      await _fetchVmsAndCameras();
      tokenExpiredCountdown();
      _homeStore.navigateFromLogin = false;
      _homeStore.firstTimeOpenApp = true;
    } else {
      Gateway rootGateway = await _gatewayStore.findRootGateway();
      _gatewayStore.gateway = rootGateway;
      if (!_homeStore.firstTimeOpenApp) {
        await _loginVmsAgain();
        if (_gatewayStore.loginSuccess) {
          await _fetchVmsAndCameras();
          tokenExpiredCountdown();
        }
        _homeStore.firstTimeOpenApp = true;
      }
    }
  }

  void tokenExpiredCountdown() {
    _timerUpdateAccessToken = Timer.periodic(
        Duration(
            seconds: _gatewayStore.gateway.accessTokenExpiredTime -
                Strings.timeCountdownRefreshToken), (timer) {
      _updateTokenVMSRoot();
    });
    _timerLoginAgain = Timer.periodic(
        Duration(
            seconds: _gatewayStore.gateway.refreshTokenExpiredTime -
                Strings.timeCountdownRefreshToken), (timer) {
      _loginVmsAgain();
    });
  }

  Future _updateTokenVMSRoot() async {
    final response = await _gatewayStore.getAccessToken(_gatewayStore.gateway);
    _gatewayStore.gateway.accessTokenExpiredTime =
        response["access_token_expires"];
    _gatewayStore.gateway.token = response["access_token"];
    _gatewayStore.updateVmsToken(_gatewayStore.gateway);
  }

  final SecureStorage secureStorages = SecureStorage();
  final _storagess = FlutterSecureStorage();
  void readSecureDatas(String key) async {
    String readData = await _storagess.read(key: key);
  }

  @override
  void onPaused() {
    super.onPaused();
    _homeStore.isAuthenticateApp = false;
  }

  @override
  void onResumed() async {
    super.onResumed();
    if (_homeStore.isAuthenticateApp) return;
    if (await appComponent.getSharedPreferenceHelper().isExistedPinCode) {
      if (!_homeStore.isHavePhotoPermission &&
          ModalRoute.of(context).settings.name == "/videoAndPhoto") return;
      showMaterialModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: false,
        expand: true,
        builder: (_) {
          return VerifyApp();
        },
      );
    }
  }

  Future _fetchVmsAndCameras() async {
    _gatewayStore.isShowLoading = true;
    Loader.show(context, progressIndicator: CustomProgressIndicatorWidget());
    List<Device> listDevicesFromApi = [];
    try {
      final response =
          await _deviceStore.fetchData(_gatewayStore.gateway, context);
      if (_deviceStore.success) {
        for (var item in response) {
          if(item["data"]!=null){
            Gateway gateway = Gateway.fromApi(item["target"]);
            List<Device> listDevices = item["data"]
                .map<Device>((list) => Device.fromJson(list))
                .toList();
            gateway.totalCamera = listDevices.length;
            if (gateway.root)
              gateway.token = _gatewayStore.gateway.token;
            // else
            //   gateway.token = item["target"]["auth"]["access_token"];
            // Find existed gateway in DB
            Gateway existedGateway = _gatewayStore.listGateway.firstWhere(
                    (element) =>
                element.domainName == gateway.domainName &&
                    element.port == gateway.port,
                orElse: () => null);
            int gatewayId;
            if (existedGateway == null)
              gatewayId = await _gatewayStore.addOrUpdate(gateway);
            else {
              existedGateway.totalCamera = gateway.totalCamera;
              existedGateway.token = gateway.token;
              existedGateway.name = gateway.name;
              gatewayId = await _gatewayStore.addOrUpdate(existedGateway);
            }
            listDevices.forEach((device) {
              print(device.name);
              device.gatewayId = gatewayId;
            });
            listDevicesFromApi.addAll(listDevices);
            print(listDevicesFromApi.length);

            await _handleSyncDevices(listDevicesFromApi);
          }

        }
      } else
        _showErrorMessage(_deviceStore.errorStore.errorMessage, true);
    } catch (e) {
      print(e);
    }
    Loader.hide();
    _gatewayStore.isShowLoading = false;
  }

  Future _loginVmsAgain() async {
    _gatewayStore.isShowLoading = true;
    Loader.show(context, progressIndicator: CustomProgressIndicatorWidget());
    try {
      final response = await _gatewayStore.loginToVms(_gatewayStore.gateway);
      if (_gatewayStore.loginSuccess) {
        _gatewayStore.gateway.token = response["access_token"];
        _gatewayStore.gateway.accessTokenExpiredTime =
            response["access_token_expires"];
        _gatewayStore.gateway.refreshToken = response["refresh_token"];
        _gatewayStore.gateway.refreshTokenExpiredTime =
            response["refresh_token_expires"];
        _gatewayStore.gateway.root = true;
        await _gatewayStore.addOrUpdate(_gatewayStore.gateway);
      } else
        _showErrorMessage(_gatewayStore.errorStore.errorMessage, true);
    } catch (e) {
      print(e.toString());
    }
    Loader.hide();
    _gatewayStore.isShowLoading = false;
  }

  _showErrorMessage(String message, bool loginError) {
    showCupertinoDialog(
        context: context,
        builder: (context) => Theme(
              data: ThemeData.dark(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: CupertinoAlertDialog(
                    title: Text(
                        Translate.getString("manage_device.warning", context)),
                    content: Text(Translate.getString(message, context)),
                    actions: [
                      CupertinoDialogAction(
                          child:
                              Text(Translate.getString("home.cancel", context)),
                          onPressed: () async {
                            _resetStore();
                            await Future.wait([
                              appComponent.getCameraRepository().deleteAll(),
                              appComponent.getDeviceRepository().deleteAll(),
                              appComponent.getFavoriteRepository().deleteAll(),
                            ]);
                            Navigator.pop(context);
                          }),
                      CupertinoDialogAction(
                          child: Text(
                              Translate.getString("home.try_again", context)),
                          onPressed: () async {
                            Navigator.pop(context);
                            if (!loginError) {
                              await _fetchVmsAndCameras();
                              tokenExpiredCountdown();
                            } else {
                              await _loginVmsAgain();
                              if (_gatewayStore.loginSuccess) {
                                await _fetchVmsAndCameras();
                                tokenExpiredCountdown();
                              }
                            }
                          })
                    ]),
              ),
            ));
  }

  _resetStore() {
    _rollCameraStore.dispose();
    _gridCameraStore.dispose();
    _favoriteStore.dispose();
    _cameraStore.dispose();
    _deviceStore.dispose();
  }

  Future _handleSyncDevices(List<Device> listDevicesFromApi) async {
    List<Device> listDeviceInsert = listDevicesFromApi
        .where((element) => !_deviceStore.listDevice.contains(element))
        .toList();
    List<Device> listDeviceRemove = _deviceStore.listDevice
        .where((element) => !listDevicesFromApi.contains(element))
        .toList();
    listDeviceRemove.forEach(
            (Device device) async => await _deviceStore.deleteByFilter(device));
    await _deviceStore.insertListDevicesToDB(listDeviceInsert);
  }
}

mixin HomeScreenPage<Page extends HomeScreen> on HomeScreenState<Page> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_gatewayStore.isShowLoading) return false;
        if (_homeStore.currentScreen == "favoritesList" &&
            _favoriteStore.isNavigateFromLiveCam) {
          _homeStore.setActiveScreen('liveCamera');
          return true;
        }
        showCupertinoDialog(
          context: context,
          builder: (context) => Theme(
            data: ThemeData.dark(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: CupertinoAlertDialog(
                  title: Text(Translate.getString("home.warning", context)),
                  content:
                      Text(Translate.getString("home.confirm_exit", context)),
                  actions: [
                    CupertinoDialogAction(
                        child: Text(
                          Translate.getString("home.yes", context),
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          SystemNavigator.pop();
                        }),
                    CupertinoDialogAction(
                      child: Text(
                        Translate.getString("home.no", context),
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ]),
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: MediaQuery.of(context).orientation == Orientation.portrait
            ? HomeAppbar(bottom(), [action()])
            : null,
        body: body(),
        drawer: SidebarMenu(),
      ),
    );
  }

  Widget body();

  Widget action();

  PreferredSize bottom();
}
