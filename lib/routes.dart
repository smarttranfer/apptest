import 'package:boilerplate/ui/Gis/GisAI.dart';
import 'package:boilerplate/ui/devices/devices.dart';
import 'package:boilerplate/ui/favorites_list/add_new.dart';
import 'package:boilerplate/ui/favorites_list/list_items.dart';
import 'package:boilerplate/ui/livecamera/live_camera.dart';
import 'package:boilerplate/ui/playback_camera/playback_camera.dart';
import 'package:boilerplate/ui/settings/app_info.dart';
import 'package:boilerplate/ui/settings/change_pin.dart';
import 'package:boilerplate/ui/settings/help_screen.dart';
import 'package:boilerplate/ui/settings/security.dart';
import 'package:boilerplate/ui/settings/setting_page.dart';
import 'package:boilerplate/ui/settings/setup_pin_code.dart';
import 'package:boilerplate/ui/setup_app/select_language.dart';
import 'package:boilerplate/ui/setup_app/select_region.dart';
import 'package:boilerplate/ui/video_photo/photo_detail.dart';
import 'package:boilerplate/ui/video_photo/video_detail.dart';
import 'package:boilerplate/ui/video_photo/video_photo.dart';
import 'package:boilerplate/ui/event/Event_main.dart';
import 'package:flutter/material.dart';

import 'ui/splash/splash.dart';

import 'ui/login/login.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String gis = "/Gis";
  static const String event = "/event";
  static const String login = '/login';

  static const String selectLanguage = '/selectLanguage';
  static const String selectRegion = '/selectRegion';

  // main page
  static const String liveCamera = '/liveCamera';
  static const String rollCamera = '/rollCamera';
  static const String setting = '/setting';
  static const String favoritesList = '/favoritesList';

  // manage device
  static const String manualAdd = '/manualAdd';
  static const String onlineAdd = '/onlineAdd';
  static const String addVms = '/addVms';
  static const String addBkav = '/addBkav';

  // control page
  static const String devices = '/devices';
  static const String videoAndPhoto = '/videoAndPhoto';
  static const String photoDetail = '/photoDetail';
  static const String videoDetail = '/videoDetail';

  // setting page
  static const String appInfo = '/appInfo';
  static const String helpScreen = '/helpScreen';
  static const String securityScreen = '/securityScreen';
  static const String setupPin = '/setupPin';
  static const String changePin = '/changePin';

  // favorite page
  static const String addFavorite = '/addFavorite';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    event:(BuildContext context)=> event_main(),
    liveCamera: (BuildContext context) => LiveCamera(),
    rollCamera: (BuildContext context) => PlayBackCameraScreen(),
    login: (BuildContext context) => LoginScreen(),
    devices: (BuildContext context) => DevicesScreen(),
    selectLanguage: (BuildContext context) => SelectLanguage(),
    selectRegion: (BuildContext context) => SelectRegion(),
    setting: (BuildContext context) => SettingPage(),
    appInfo: (BuildContext context) => AppInfo(),
    helpScreen: (BuildContext context) => HelpScreen(),
    videoAndPhoto: (BuildContext context) => VideoPhoto(),
    photoDetail: (BuildContext context) => PhotoDetail(),
    videoDetail: (BuildContext context) => VideoDetail(),
    favoritesList: (BuildContext context) => FavoritesList(),
    addFavorite: (BuildContext context) => AddFavorite(),
    securityScreen: (BuildContext context) => SecurityScreen(),
    setupPin: (BuildContext context) => SetupPinCode(),
    changePin: (BuildContext context) => ChangePinCode(),
    gis: (BuildContext context) => urlview(),
  };
}
