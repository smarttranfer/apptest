import 'dart:ui';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/device/device_store.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/live_camera/grid_camera_store.dart';
import 'package:boilerplate/stores/roll_camera/roll_camera_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boilerplate/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/device/device_utils.dart';
import 'icon_assets.dart';
import 'package:http/http.dart' as http;
import 'package:boilerplate/StoredataScurety/StoreSercurity.dart';

class SidebarMenu extends StatefulWidget {
  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  HomeStore _homeStore;
  FavoriteStore _favoriteStore;
  GridCameraStore _gridCameraStore;
  RollCameraStore _rollCameraStore;
  GatewayStore _gatewayStore;
  CameraStore _cameraStore;
  DeviceStore _deviceStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeStore = Provider.of(context);
    _favoriteStore = Provider.of(context);
    _gridCameraStore = Provider.of(context);
    _rollCameraStore = Provider.of(context);
    _gatewayStore = Provider.of(context);
    _cameraStore = Provider.of(context);
    _deviceStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DeviceUtils.getScaledWidth(context, 0.75),
      child: Drawer(
        child: Container(
          color: Color.fromRGBO(23, 22, 27, 1),
          child: ListView(children: [
            Container(
              height: 125.0,
              padding: EdgeInsets.only(left: 12, right: 12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(23, 22, 27, 1),
              ),
              child: DrawerHeader(
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0xffE5E5E5)))),
                child: Column(
                  children: [
                    CircleAvatar(
                      child: Icon(Icons.person),
                      radius: 25,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _gatewayStore.gateway.username,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text(
                Translate.getString("home.live_view", context),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _homeStore.currentScreen == "liveCamera"
                      ? Colors.blueAccent
                      : Colors.white,
                ),
              ),
              leading: IconAssets(
                name: "camera",
                width: 35,
                color: _homeStore.currentScreen == "liveCamera"
                    ? Colors.blueAccent
                    : Colors.white,
              ),
              onTap: () {
                if (_homeStore.currentScreen == 'liveCamera') {
                  Navigator.pop(context);
                  return;
                }
                _homeStore.setActiveScreen('liveCamera');
                _gridCameraStore.setPage(0);
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.liveCamera, (Route<dynamic> route) => false);
              },
            ),
            ListTile(
              title: Text(
                Translate.getString("home.playback", context),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _homeStore.currentScreen == "rollCamera"
                      ? Colors.blueAccent
                      : Colors.white,
                ),
              ),
              leading: IconAssets(
                name: "rewatch",
                width: 30,
                color: _homeStore.currentScreen == "rollCamera"
                    ? Colors.blueAccent
                    : Colors.white,
              ),
              onTap: () {
                if (_homeStore.currentScreen == 'rollCamera') {
                  Navigator.pop(context);
                  return;
                }
                _homeStore.setActiveScreen('rollCamera');
                _gridCameraStore.reset();
                _rollCameraStore.setTimeSelected(
                    DateTime.now().subtract(Duration(days: 1)));
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.rollCamera, (Route<dynamic> route) => false);
              },
            ),
            ListTile(
              title: Text(
                Translate.getString("home.list_favorite", context),
                style: TextStyle(
                    color: _homeStore.currentScreen == "favoritesList"
                        ? Colors.blueAccent
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              leading: IconAssets(
                name: "favorite",
                width: 25,
                color: _homeStore.currentScreen == "favoritesList"
                    ? Colors.blueAccent
                    : Colors.white,
              ),
              onTap: () {
                _favoriteStore.setNavigateValue(false);
                _homeStore.setActiveScreen('favoritesList');
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.favoritesList, (Route<dynamic> route) => false);
              },
            ),
            ListTile(
              title: Text(
                Translate.getString("home.video_photo", context),
                style: TextStyle(
                    color: _homeStore.currentScreen == "videoAndPhoto"
                        ? Colors.blueAccent
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              leading: IconAssets(
                name: "video_photo",
                width: 25,
                color: _homeStore.currentScreen == "videoAndPhoto"
                    ? Colors.blueAccent
                    : Colors.white,
              ),
              onTap: () {
                _homeStore.setActiveScreen('videoAndPhoto');
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.videoAndPhoto, (Route<dynamic> route) => false);
              },
            ),
            ListTile(
              title: Text(
                Translate.getString("Danh sách sự kiện", context),
                style: TextStyle(
                    color: _homeStore.currentScreen == "event"
                        ? Colors.blueAccent
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              leading: IconAssets(
                name: "event",
                width: 25,
                color: _homeStore.currentScreen == "event"
                    ? Colors.blueAccent
                    : Colors.white,
              ),
              onTap: () {
                _homeStore.setActiveScreen('event');
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.event, (Route<dynamic> route) => false);

              },
            ),
            ListTile(
              title: Text(
                Translate.getString("AI GIS", context),
                style: TextStyle(
                    color: _homeStore.currentScreen == "URL"
                        ? Colors.blueAccent
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              leading: IconAssets(
                name: "url",
                width: 25,
                color: _homeStore.currentScreen == "URL"
                    ? Colors.blueAccent
                    : Colors.white,
              ),
              onTap: () {
                _homeStore.setActiveScreen('URL');
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.gis, (Route<dynamic> route) => false);

              },
            ),
            ListTile(
              title: Text(
                Translate.getString("home.setting", context),
                style: TextStyle(
                    color: _homeStore.currentScreen == "setting"
                        ? Colors.blueAccent
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              leading: IconAssets(
                name: "settings",
                width: 25,
                color: _homeStore.currentScreen == "setting"
                    ? Colors.blueAccent
                    : Colors.white,
              ),
              onTap: () {
                _homeStore.setActiveScreen('setting');
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.setting, (Route<dynamic> route) => false);
              },
            ),
            ListTile(
              title: Text(Translate.getString("home.logout", context),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              leading: IconAssets(
                name: "logout",
                width: 25,
                color: Colors.white,
              ),
              onTap: () {
                _showPopupConfirmLogout();
              },
            ),
          ]),
        ),
      ),
    );
  }
  Future<void> DeleteTokenVMS(String token , String user) async{
    var headers = {
      'Authorization': 'Bearer ${_gatewayStore.gateway.token}',
      'Content-Type': 'application/json'
    };
    var sendToken =
    http.Request('POST', Uri.parse('${_gatewayStore.gateway.protocol}://${_gatewayStore.gateway.domainName}:${_gatewayStore.gateway.port}/vms/api/notification/delete_token?token=${token}&user=${user}'));
    sendToken.headers.addAll(headers);
    http.StreamedResponse maptoken = await sendToken.send();
    print(await maptoken.stream.bytesToString());

  }
  _showPopupConfirmLogout() {
    return showCupertinoDialog(
      context: context,
      builder: (context) => Theme(
        data: ThemeData.dark(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: CupertinoAlertDialog(
              title: Text(Translate.getString("home.warning", context)),
              content:
                  Text(Translate.getString("home.confirm_logout", context)),
              actions: [
                CupertinoDialogAction(
                    child: Text(
                      Translate.getString("home.yes", context),
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                     await DeleteTokenVMS(SecureStorage.token,_gatewayStore.gateway.username);
                      _resetStore();
                      await prefs.remove('vms.token');
                      await prefs.remove('vms.protocol');
                      await prefs.remove('vms.domain');
                      await prefs.remove('vms.port');
                      await Future.wait([
                        appComponent.getSharedPreferenceHelper().removeUUID(),
                        appComponent
                            .getSharedPreferenceHelper()
                            .removePinCode(),
                        appComponent
                            .getSharedPreferenceHelper()
                            .unUsedFingerPrint(),
                        appComponent.getCameraRepository().deleteAll(),
                        appComponent.getDeviceRepository().deleteAll(),
                        appComponent.getGatewayRepository().deleteAll(),
                        appComponent.getFavoriteRepository().deleteAll(),


                      ]);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.login, (Route<dynamic> route) => false);
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
  }

  _resetStore() {
    _homeStore.dispose();
    _gatewayStore.dispose();
    _rollCameraStore.dispose();
    _gridCameraStore.dispose();
    _favoriteStore.dispose();
    _cameraStore.dispose();
    _deviceStore.dispose();
  }
}
