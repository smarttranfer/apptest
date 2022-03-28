import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/preferences.dart';

class SharedPreferenceHelper {
  // shared pref instance
  final Future<SharedPreferences> _sharedPreference;

  // constructor
  SharedPreferenceHelper(this._sharedPreference);

  // General Methods: ----------------------------------------------------------

  Future<bool> get isUsedFingerPrint async {
    return _sharedPreference.then((preference) {
      return preference.getBool(Preferences.is_used_finger_print);
    });
  }

  Future<String> get pinCode async {
    return _sharedPreference.then((preference) {
      return preference.getString(Preferences.pin_code);
    });
  }

  Future<String> get uUID async {
    return _sharedPreference.then((preference) {
      return preference.getString(Preferences.UUID);
    });
  }

  Future<bool> get isExistedPinCode async {
    return _sharedPreference.then((preference) {
      return preference.getString(Preferences.pin_code) != null;
    });
  }

  Future<bool> get currentRegion async {
    return _sharedPreference.then((preference) {
      return preference.getString(Preferences.current_region) != null;
    });
  }

  Future<void> savePinCode(String pinCode) async {
    return _sharedPreference.then((preference) {
      preference.setString(Preferences.pin_code, pinCode);
    });
  }

  Future<void> saveUUID(String uUID) async {
    return _sharedPreference.then((preference) {
      preference.setString(Preferences.UUID, uUID);
    });
  }

  Future<void> removeUUID() async {
    return _sharedPreference.then((preference) {
      preference.remove(Preferences.UUID);
    });
  }

  Future<bool> get isLoggedIn async {
    return _sharedPreference.then((preference) {
      return preference.getString(Preferences.UUID) != null;
    });
  }

  Future<void> removePinCode() async {
    return _sharedPreference.then((preference) {
      preference.remove(Preferences.pin_code);
    });
  }

  Future<void> usedFingerPrint(bool value) async {
    return _sharedPreference.then((preference) {
      preference.setBool(Preferences.is_used_finger_print, value);
    });
  }

  Future<void> unUsedFingerPrint() async {
    return _sharedPreference.then((preference) {
      preference.remove(Preferences.is_used_finger_print);
    });
  }

  // Theme:------------------------------------------------------
  Future<bool> get isDarkMode {
    return _sharedPreference.then((prefs) {
      return prefs.getBool(Preferences.is_dark_mode) ?? false;
    });
  }

  Future<void> changeBrightnessToDark(bool value) {
    return _sharedPreference.then((prefs) {
      return prefs.setBool(Preferences.is_dark_mode, value);
    });
  }

  // Language:---------------------------------------------------
  Future<String> get currentLanguage {
    return _sharedPreference.then((prefs) {
      return prefs.getString(Preferences.current_language);
    });
  }

  Future<String> get currentRegionCode {
    return _sharedPreference.then((prefs) {
      return prefs.getString(Preferences.current_region);
    });
  }

  Future<void> changeLanguage(String language) {
    return _sharedPreference.then((prefs) {
      return prefs.setString(Preferences.current_language, language);
    });
  }

  Future<void> changeRegion(String regionCode) {
    return _sharedPreference.then((prefs) {
      return prefs.setString(Preferences.current_region, regionCode);
    });
  }

  Future<void> setPage(int page) {
    return _sharedPreference.then((prefs) {
      return prefs.setInt(Preferences.page, page);
    });
  }

  Future<int> get page {
    return _sharedPreference.then((prefs) {
      return prefs.getInt(Preferences.page) ?? 0;
    });
  }

  Future<void> setNumberOfPage(int numberOfPage) {
    return _sharedPreference.then((prefs) {
      return prefs.setInt(Preferences.number_of_page, numberOfPage);
    });
  }

  Future<int> get numberOfPage {
    return _sharedPreference.then((prefs) {
      return prefs.getInt(Preferences.number_of_page) ?? 4;
    });
  }
}
