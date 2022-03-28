import 'dart:async';

import 'package:boilerplate/data/network/apis/user/user_api.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';

class UserRepository {
  // api objects
  final UserApi _userApi;

  // shared pref object
  final SharedPreferenceHelper _sharedPrefsHelper;

  // constructor
  UserRepository(this._userApi, this._sharedPrefsHelper);

  Future<String> get pinCode => _sharedPrefsHelper.pinCode;

  Future<bool> get isUsedFingerPrint => _sharedPrefsHelper.isUsedFingerPrint;

  Future getAllContinents() async {
    return await _userApi.getAllContinents();
  }

  Future getAllCountries() async {
    return await _userApi.getAllCountries();
  }
}
