import 'package:boilerplate/data/repository/camera_repository.dart';
import 'package:boilerplate/data/repository/device_repository.dart';
import 'package:boilerplate/data/repository/favorite_repository.dart';
import 'package:boilerplate/data/repository/gateway_repository.dart';
import 'package:boilerplate/data/repository/repository.dart';
import 'package:boilerplate/data/repository/user_repository.dart';
import 'package:boilerplate/data/repository/vms_repository.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/modules/local_module.dart';
import 'package:boilerplate/di/modules/netwok_module.dart';
import 'package:boilerplate/di/modules/preference_module.dart';
import 'package:boilerplate/main.dart';
import 'package:inject/inject.dart';

import 'app_component.inject.dart' as g;

/// The top level injector that stitches together multiple app features into
/// a complete app.
@Injector(const [NetworkModule, LocalModule, PreferenceModule])
abstract class AppComponent {
  @provide
  MyApp get app;

  static Future<AppComponent> create(
    NetworkModule networkModule,
    LocalModule localModule,
    PreferenceModule preferenceModule,
  ) async {
    return await g.AppComponent$Injector.create(
      networkModule,
      localModule,
      preferenceModule,
    );
  }

  /// An accessor to RestClient object that an application may use.
  @provide
  Repository getRepository();

  @provide
  UserRepository getUserRepository();

  @provide
  SharedPreferenceHelper getSharedPreferenceHelper();

  @provide
  GatewayRepository getGatewayRepository();

  @provide
  DeviceRepository getDeviceRepository();

  @provide
  CameraRepository getCameraRepository();

  @provide
  FavoriteRepository getFavoriteRepository();

  @provide
  VmsRepository getVmsRepository();
}
