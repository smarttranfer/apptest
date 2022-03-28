import 'dart:ui';

import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/main.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/profile/profile_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/form_textfield_widget.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';

class VerifyApp extends StatefulWidget {
  final bool isFirstTimeOpenApp;

  VerifyApp({this.isFirstTimeOpenApp = false});

  @override
  _VerifyAppState createState() => _VerifyAppState();
}

class _VerifyAppState extends State<VerifyApp> {
  ProfileStore _profileStore;
  HomeStore _homeStore;
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileStore = Provider.of(context);
    _homeStore = Provider.of(context);
    _profileStore.checkUsedFingerPrint();
  }

  Future<void> _authenticateUser() async {
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

    if (isAuthenticated) {
      navigate();
    }
  }

  void navigate() {
    DeviceUtils.hideKeyboard(context);
    if (widget.isFirstTimeOpenApp)
      Navigator.of(context).pushReplacementNamed(Routes.liveCamera);
    else
      Navigator.pop(context);
    _profileStore.pinCode = "";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showCupertinoDialog(
          context: context,
          builder: (context) => Theme(
            data: ThemeData.dark(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: CupertinoAlertDialog(
                  title: Text(Translate.getString("home.warning", context)),
                  content:
                      Text(Translate.getString("home.confirm_exit", context)),
                  actions: [
                    CupertinoDialogAction(
                        child: Text(
                          Translate.getString("home.yes", context),
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          SystemNavigator.pop();
                        }),
                    CupertinoDialogAction(
                      child: Text(
                        Translate.getString("home.no", context),
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ]),
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: DeviceUtils.getScaledHeight(context, 0.085)),
            Text(
              Translate.getString("pin.input_pin", context),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            FormTextFieldWidget(
              isObscure: true,
              maxLength: 10,
              initialValue: _profileStore.pinCode,
              onChanged: (value) => _profileStore.pinCode = value,
              onEditingComplete: () async {
                if (_profileStore.pinCode.isEmpty) {
                  DeviceUtils.hideKeyboard(context);
                  return;
                }
                if (_profileStore.pinCode ==
                    await appComponent.getSharedPreferenceHelper().pinCode) {
                  navigate();
                } else
                  _showErrorMessage(
                      Translate.getString("pin.pin_wrong", context));
              },
              placeholder: Translate.getString("pin.pin_validate", context),
            ),
            Observer(builder: (_) {
              return Visibility(
                visible: _profileStore.isUsedFingerPrint,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      Translate.getString("pin.or_use_biometric", context),
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        _authenticateUser();
                      },
                      child: IconAssets(
                        name: "finger_print",
                        width: 40,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
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
                title: Text(Translate.getString("pin.warning", context)),
                content: Text(message),
                actions: [
                  CupertinoDialogAction(
                    child: Text(Translate.getString("pin.close", context)),
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
