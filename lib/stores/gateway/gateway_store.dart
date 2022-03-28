import 'dart:async';

import 'package:boilerplate/data/repository/gateway_repository.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/models/gateway/gateway.dart';
import 'package:boilerplate/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';

part 'gateway_store.g.dart';

class GatewayStore = _GatewayStore with _$GatewayStore;

abstract class _GatewayStore with Store {
  final GatewayRepository gatewayRepository;
  StreamSubscription _streamSubscription;
  final SharedPreferenceHelper _sharedPreferenceHelper;

  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();

  // disposers
  List<ReactionDisposer> _disposers;

  _GatewayStore(this.gatewayRepository, this._sharedPreferenceHelper) {
    gateway = new Gateway(
      protocol: "https",
      domainName: "",
      username: "",
      port: "",
      password: "",
    );
    _disposers = [
      reaction((_) => loginSuccess, resetLoginSuccess, delay: 500),
    ];
  }

  @observable
  List<Gateway> listGateway = [];

  @observable
  Gateway gateway;

  @observable
  bool loginSuccess = true;

  @observable
  bool isShowLoading = false;

  @computed
  bool get isInvalidForm =>
      gateway.domainName.isEmpty ||
      gateway.username.isEmpty ||
      gateway.password.isEmpty;

  @action
  void resetLoginSuccess(bool value) {
    print('calling reset');
    loginSuccess = true;
  }

  @action
  findAll() async {
    final stream = await gatewayRepository.findAll();
    _streamSubscription = stream.listen((event) {
      for(var i  in event){
        print(i);
      }
      listGateway = event;
    });
  }

  @action
  addOrUpdate(Gateway gateway) async {
    return await gatewayRepository.createOrUpdate(gateway);
  }

  @action
  validateForm() {
    if (gateway.domainName.isEmpty) {
      errorStore.errorMessage = "manage_device.not_input_domain";
    } else if (gateway.username.isEmpty) {
      errorStore.errorMessage = "manage_device.not_input_username";
    } else if (gateway.password.isEmpty) {
      errorStore.errorMessage = "manage_device.not_input_password";
    }
  }

  @action
  Future<List<Gateway>> getAll() async {
    return await gatewayRepository.getAll();
  }

  @action
  Future<Gateway> findById(int id) async {
    return await gatewayRepository.findById(id);
  }

  @action
  Future<Gateway> findRootGateway() async {
    return await gatewayRepository.findRootGateway();
  }

  @action
  updateVmsToken(Gateway gateway) async {
    await gatewayRepository.updateVmsToken(gateway);
  }

  @action
  Future delete() async {
    await gatewayRepository.delete(gateway);
  }

  @action
  Future loginToVms(Gateway gateway) async {
    try {
      Map<String, dynamic> response =
          await gatewayRepository.loginToVms(gateway);
      loginSuccess = true;
      _sharedPreferenceHelper.saveUUID(response["uuid"]);
      return response;
    } catch (e) {
      print(e.toString());
      loginSuccess = false;
      errorStore.errorMessage = "manage_device.can_not_connect_vms";
    }
  }

  @action
  Future getAccessToken(Gateway gateway) async {
    Map<String, dynamic> response =
        await gatewayRepository.getAccessToken(gateway);
    return response;
  }

  @action
  dispose() {
    gateway = new Gateway(
      protocol: "https",
      domainName: "",
      username: "",
      port: "",
      password: "",
    );
    listGateway = [];
    if (_streamSubscription != null) _streamSubscription.cancel();
    for (final d in _disposers) {
      d();
    }
  }
}
