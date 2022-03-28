import 'dart:convert';

import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/constants/strings.dart';
import 'package:boilerplate/di/components/app_component.dart';
import 'package:boilerplate/di/modules/local_module.dart';
import 'package:boilerplate/di/modules/netwok_module.dart';
import 'package:boilerplate/di/modules/preference_module.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/camera_preview/camera_preview_store.dart';
import 'package:boilerplate/stores/device/device_store.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/stores/gateway/gateway_store.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/language/language_store.dart';
import 'package:boilerplate/stores/live_camera/grid_camera_store.dart';
import 'package:boilerplate/stores/login/login_store.dart';
import 'package:boilerplate/stores/profile/profile_store.dart';
import 'package:boilerplate/stores/ptz_control/ptz_control_store.dart';
import 'package:boilerplate/stores/record_camera/record_camera_store.dart';
import 'package:boilerplate/stores/roll_camera/roll_camera_store.dart';
import 'package:boilerplate/stores/theme/theme_store.dart';
import 'package:boilerplate/stores/video_photo/video_photo_store.dart';
import 'package:boilerplate/ui/home/home.dart';
import 'package:boilerplate/ui/splash/splash.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:inject/inject.dart';
import 'package:provider/provider.dart';
import 'Notification/service/notification_service.dart';

// global instance for app component
AppComponent appComponent;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) async {
    appComponent = await AppComponent.create(
      NetworkModule(),
      LocalModule(),
      PreferenceModule(),
    );
    // NotificationService notificationService = NotificationService();
    // await notificationService.init();
    // await notificationService.requestIOSPermissions();
    // await notificationService.scheduleNotification(
    //   1,
    //   "1213",
    //   "Reminder for your scheduled event at body",
    //   jsonEncode({
    //     "title": "121313",
    //     "eventDate": "noi dung",
    //     "eventTime": "1213",
    //   }),
    //   // getDateTimeComponents(),
    // );
    runApp(appComponent.app);
  });
}
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
@provide
class MyApp extends StatelessWidget {
  final ThemeStore _themeStore = ThemeStore(appComponent.getRepository());
  final LanguageStore _languageStore =
      LanguageStore(appComponent.getRepository());
  final ProfileStore _profileStore =
      ProfileStore(appComponent.getUserRepository());
  final LoginStore _loginStore = LoginStore(appComponent.getUserRepository());
  final GridCameraStore _gridCameraStore = GridCameraStore();
  final HomeStore _homeStore = HomeStore();
  final GatewayStore _gatewayStore = GatewayStore(
      appComponent.getGatewayRepository(),
      appComponent.getSharedPreferenceHelper());
  final DeviceStore _deviceStore =
      DeviceStore(appComponent.getDeviceRepository());
  final CameraStore _cameraStore = CameraStore(
    appComponent.getCameraRepository(),
    appComponent.getDeviceRepository(),
    appComponent.getGatewayRepository(),
  );
  final CameraPreviewStore _cameraPreviewStore = CameraPreviewStore();
  final PtzControlStore _ptzControlStore = PtzControlStore(
    appComponent.getVmsRepository(),
    appComponent.getGatewayRepository(),
  );
  final RecordCameraStore _recordCameraStore = RecordCameraStore(
    appComponent.getVmsRepository(),
    appComponent.getGatewayRepository(),
  );
  final VideoPhotoStore _videoPhotoStore = VideoPhotoStore();
  final FavoriteStore _favoriteStore = FavoriteStore(
      appComponent.getFavoriteRepository(),
      appComponent.getGatewayRepository(),
      appComponent.getDeviceRepository());
  final RollCameraStore _rollCameraStore = RollCameraStore(
      appComponent.getGatewayRepository(), appComponent.getVmsRepository());

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _themeStore),
        Provider.value(value: _languageStore),
        Provider.value(value: _profileStore),
        Provider.value(value: _loginStore),
        Provider.value(value: _gridCameraStore),
        Provider.value(value: _homeStore),
        Provider.value(value: _gatewayStore),
        Provider.value(value: _deviceStore),
        Provider.value(value: _cameraStore),
        Provider.value(value: _cameraPreviewStore),
        Provider.value(value: _ptzControlStore),
        Provider.value(value: _recordCameraStore),
        Provider.value(value: _videoPhotoStore),
        Provider.value(value: _favoriteStore),
        Provider.value(value: _rollCameraStore),
      ],
      child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            SystemChrome.setEnabledSystemUIOverlays([]);
          } else {
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
          }
          return Observer(
            builder: (context) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: Strings.appName,
                theme: themeDataDark,
                navigatorKey: key,
                routes: Routes.routes,
                locale: Locale(_languageStore.locale),
                supportedLocales: _languageStore.supportedLanguages
                    .map((language) => Locale(language.locale, language.code))
                    .toList(),
                localizationsDelegates: [
                  // A class which loads the translations from JSON files
                  AppLocalizations.delegate,
                  // Built-in localization of basic text for Material widgets
                  GlobalMaterialLocalizations.delegate,
                  // Built-in localization for text direction LTR/RTL
                  GlobalWidgetsLocalizations.delegate,
                  // Built-in localization of basic text for Cupertino widgets
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
