import 'package:boilerplate/constants/endpoints.dart';
import 'package:boilerplate/data/network/apis/device/device.dart';
import 'package:boilerplate/data/network/apis/gateway/gateway.dart';
import 'package:boilerplate/data/network/apis/user/user_api.dart';
import 'package:boilerplate/data/network/apis/vms/vms.dart';
import 'package:boilerplate/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/modules/preference_module.dart';
import 'package:dio/dio.dart';
import 'package:inject/inject.dart';

@module
class NetworkModule extends PreferenceModule {
  // ignore: non_constant_identifier_names
  final String TAG = "NetworkModule";

  // DI Providers:--------------------------------------------------------------
  /// A singleton dio provider.
  ///
  /// Calling it multiple times will return the same instance.
  @provide
  @singleton
  Dio provideDio(SharedPreferenceHelper sharedPrefHelper) {
    final dio = Dio();

    dio
      ..options.baseUrl = Endpoints.baseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.headers = {'Content-Type': 'application/json; charset=utf-8'}
      ..interceptors.add(LogInterceptor(
        request: false,
        responseBody: false,
        requestBody: false,
        requestHeader: false,
      ));

    return dio;
  }

  /// A singleton dio_client provider.
  ///
  /// Calling it multiple times will return the same instance.
  @provide
  @singleton
  DioClient provideDioClient(Dio dio) => DioClient(dio);

  @provide
  @singleton
  UserApi provideUserApi(DioClient client) => UserApi(client);

  @provide
  @singleton
  GatewayApi provideGatewayApi(
          DioClient client, SharedPreferenceHelper sharedPreferenceHelper) =>
      GatewayApi(client, sharedPreferenceHelper);

  @provide
  @singleton
  DeviceApi provideDeviceApi(DioClient client) => DeviceApi(client);

  @provide
  @singleton
  VmsApi provideVmsApi(DioClient client) => VmsApi(client);
}
