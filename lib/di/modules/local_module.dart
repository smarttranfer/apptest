import 'dart:async';

import 'package:boilerplate/constants/db_constants.dart';
import 'package:boilerplate/data/local/datasources/camera/camera_datasource.dart';
import 'package:boilerplate/data/local/datasources/device/device_datasource.dart';
import 'package:boilerplate/data/local/datasources/favorite/favorite_datasource.dart';
import 'package:boilerplate/data/local/datasources/gateway/gateway_datasource.dart';
import 'package:boilerplate/data/network/apis/device/device.dart';
import 'package:boilerplate/data/network/apis/gateway/gateway.dart';
import 'package:boilerplate/data/network/apis/user/user_api.dart';
import 'package:boilerplate/data/network/apis/vms/vms.dart';
import 'package:boilerplate/data/repository/camera_repository.dart';
import 'package:boilerplate/data/repository/device_repository.dart';
import 'package:boilerplate/data/repository/favorite_repository.dart';
import 'package:boilerplate/data/repository/gateway_repository.dart';
import 'package:boilerplate/data/repository/repository.dart';
import 'package:boilerplate/data/repository/user_repository.dart';
import 'package:boilerplate/data/repository/vms_repository.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/utils/encryption/xxtea.dart';
import 'package:inject/inject.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'netwok_module.dart';

@module
class LocalModule extends NetworkModule {
  // DI variables:--------------------------------------------------------------
  Future<Database> database;

  // constructor
  // Note: Do not change the order in which providers are called, it might cause
  // some issues
  LocalModule() {
    database = provideDatabase();
  }

  // DI Providers:--------------------------------------------------------------
  /// A singleton database provider.
  ///
  /// Calling it multiple times will return the same instance.
  @provide
  @singleton
  @asynchronous
  Future<Database> provideDatabase() async {
    // Key for encryption
    var encryptionKey = "";

    // Get a platform-specific directory where persistent app data can be stored
    final appDocumentDir = await getApplicationDocumentsDirectory();

    // Path with the form: /platform-specific-directory/demo.db
    final dbPath = join(appDocumentDir.path, DBConstants.DB_NAME);

    // Check to see if encryption is set, then provide codec
    // else init normal db with path
    var database;
    if (encryptionKey.isNotEmpty) {
      // Initialize the encryption codec with a user password
      var codec = getXXTeaCodec(password: encryptionKey);
      database = await databaseFactoryIo.openDatabase(dbPath, codec: codec);
    } else {
      database = await databaseFactoryIo.openDatabase(dbPath);
    }

    // Return database instance
    return database;
  }

  // DataSources:---------------------------------------------------------------
  // Define all your data sources here
  /// A singleton post dataSource provider.
  ///
  /// Calling it multiple times will return the same instance.

  @provide
  @singleton
  FavoriteDataSource provideRoomDataSource() => FavoriteDataSource(database);

  @provide
  @singleton
  GatewayDataSource provideGatewayDataSource() => GatewayDataSource(database);

  @provide
  @singleton
  DeviceDataSource provideDeviceDataSource() => DeviceDataSource(database);

  @provide
  @singleton
  CameraDataSource provideCameraDataSource() => CameraDataSource(database);

  // DataSources End:-----------------------------------------------------------

  /// A singleton repository provider.
  ///
  /// Calling it multiple times will return the same instance.
  @provide
  @singleton
  Repository provideRepository(SharedPreferenceHelper preferenceHelper) =>
      Repository(preferenceHelper);

  @provide
  @singleton
  UserRepository provideUserRepository(
          UserApi userApi, SharedPreferenceHelper preferenceHelper) =>
      UserRepository(userApi, preferenceHelper);

  @provide
  @singleton
  GatewayRepository provideGatewayRepository(
          GatewayDataSource gatewayDataSource, GatewayApi gatewayApi) =>
      GatewayRepository(gatewayDataSource, gatewayApi);

  @provide
  @singleton
  DeviceRepository provideDeviceRepository(
          DeviceDataSource deviceDataSource, DeviceApi deviceApi) =>
      DeviceRepository(deviceDataSource, deviceApi);

  @provide
  @singleton
  CameraRepository provideCameraRepository(CameraDataSource cameraDataSource) =>
      CameraRepository(cameraDataSource);

  @provide
  @singleton
  FavoriteRepository provideFavoriteRepository(
          FavoriteDataSource favoriteDataSource) =>
      FavoriteRepository(favoriteDataSource);

  @provide
  @singleton
  VmsRepository provideVmsRepository(VmsApi vmsApi) => VmsRepository(vmsApi);
}
