import 'dart:ui';

import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/main.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/profile/profile_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class SecurityScreen extends StatefulWidget {
  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  ProfileStore _profileStore;
  HomeStore _homeStore;
  List<BiometricType> listOfBiometrics = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileStore = Provider.of(context);
    _homeStore = Provider.of(context);
    _profileStore.checkPinCodeExist();
    _profileStore.checkUsedFingerPrint();
    _getListOfBiometricTypes();
  }

  Future<void> _getListOfBiometricTypes() async {
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
  }

  Future _authenticateUser() async {
    _homeStore.isAuthenticateApp = true;
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason:
            Translate.getString("security.biometric_to_use", context),
        useErrorDialogs: false,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      if (e.code == "NotEnrolled")
        _showErrorMessage(
            Translate.getString("security.security_to_use", context));

      if (e.code == "PasscodeNotSet")
        _showErrorMessage(Translate.getString("security.pin_to_use", context));

      if (e.code == "NotAvailable")
        _showErrorMessage(
            Translate.getString("security.permit_to_use", context));
      print(e);
    }

    if (!mounted) return;

    return isAuthenticated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translate.getString("security.title", context),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Observer(
        builder: (_) => Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(37, 38, 43, 1),
                ),
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: 50,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.lock_outlined,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Translate.getString("security.pin", context),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    CupertinoSwitch(
                      value: _profileStore.isExistedPinCode,
                      onChanged: (value) {
                        if (value)
                          _profileStore.setActionControl("activePin");
                        else
                          _profileStore.setActionControl("inActivePin");
                        Navigator.pushNamed(context, Routes.setupPin);
                      },
                      trackColor: AppColors.hintColor,
                      activeColor: AppColors.accentColor,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _profileStore.isExistedPinCode,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromRGBO(37, 38, 43, 1),
                  ),
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.changePin);
                    },
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            Translate.getString("security.change_pin", context),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(37, 38, 43, 1),
                ),
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: 50,
                child: Row(
                  children: <Widget>[
                    IconAssets(
                      name: "finger_print",
                      color: _isAvailableBiometric(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Translate.getString(
                            "security.authentication_biometric", context),
                        style: TextStyle(color: _isAvailableBiometric()),
                      ),
                    ),
                    CupertinoSwitch(
                      value: _profileStore.isUsedFingerPrint,
                      onChanged: (value) async {
                        if (!_profileStore.isExistedPinCode) return;
                        bool isAuthenticate = await _authenticateUser();
                        if (listOfBiometrics
                                .contains(BiometricType.fingerprint) ||
                            listOfBiometrics.contains(BiometricType.face) ||
                            isAuthenticate) {
                          if (!isAuthenticate) return;
                          if (value) {
                            await appComponent
                                .getSharedPreferenceHelper()
                                .usedFingerPrint(value);
                          } else
                            await appComponent
                                .getSharedPreferenceHelper()
                                .unUsedFingerPrint();
                        } else
                          _showErrorMessage(Translate.getString(
                              "security.function_not_support", context));
                        _profileStore.checkUsedFingerPrint();
                      },
                      trackColor: AppColors.hintColor,
                      activeColor: AppColors.accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _isAvailableBiometric() {
    if (_profileStore.isExistedPinCode) return Colors.white;
    return AppColors.hintColor;
  }

  _showErrorMessage(String message) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (message != null && message.isNotEmpty) {
        showCupertinoDialog(
          context: context,
          builder: (context) => Theme(
            data: ThemeData.dark(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: CupertinoAlertDialog(
                title: Text(Translate.getString("security.warning", context)),
                content: Text(message),
                actions: [
                  CupertinoDialogAction(
                    child: Text(
                        Translate.getString("security.understand", context)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }
}
