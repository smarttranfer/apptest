import 'package:boilerplate/data/repository/user_repository.dart';
import 'package:boilerplate/models/user/user_info.dart';
import 'package:boilerplate/stores/error/error_store.dart';
import 'package:boilerplate/widgets/list_region_select.dart';
import 'package:mobx/mobx.dart';

part 'profile_store.g.dart';

class ProfileStore = _ProfileStore with _$ProfileStore;

abstract class _ProfileStore with Store {
  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();

  final UserRepository _userRepository;

  _ProfileStore(this._userRepository);

  @observable
  UserInfo userInfo;

  @observable
  String pinCode = "";

  @observable
  String oldPinCode = "";

  @observable
  String newPinCode = "";

  @observable
  String rePinCode = "";

  @observable
  String regionFilter = "";

  @observable
  bool isExistedPinCode = false;

  @observable
  bool isUsedFingerPrint = false;

  @observable
  String actionControl = "activePin";

  @observable
  List<Region> listContinents = [];

  @observable
  List<Region> listCountries = [];

  @action
  Future checkPinCodeExist() async {
    String pinCode = await _userRepository.pinCode;
    isExistedPinCode = pinCode != null;
  }

  @action
  Future checkUsedFingerPrint() async {
    bool value = await _userRepository.isUsedFingerPrint;
    isUsedFingerPrint = value == true;
  }

  @action
  setActionControl(String data) {
    actionControl = data;
  }

  @action
  getAllContinents() async {
    listContinents = await _userRepository.getAllContinents();
  }

  @action
  getAllCountries() async {
    listCountries = await _userRepository.getAllCountries();
  }

  @action
  setRegionFilter(value) {
    regionFilter = value;
  }

  void dispose() {
    actionControl = "activePin";
    pinCode = "";
    oldPinCode = "";
    newPinCode = "";
    rePinCode = "";
  }
}
