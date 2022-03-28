import 'dart:ui';

import 'package:boilerplate/main.dart';
import 'package:boilerplate/stores/profile/profile_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/button_bottom_side.dart';
import 'package:boilerplate/widgets/form_label.dart';
import 'package:boilerplate/widgets/form_textfield_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ChangePinCode extends StatefulWidget {
  @override
  _ChangePinCodeState createState() => _ChangePinCodeState();
}

class _ChangePinCodeState extends State<ChangePinCode> {
  ProfileStore _profileStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translate.getString("pin.change_pin", context),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                children: [
                  FormLabel(text: Translate.getString("pin.old_pin", context)),
                  FormTextFieldWidget(
                    isObscure: true,
                    maxLength: 10,
                    initialValue: _profileStore.oldPinCode,
                    onChanged: (value) => _profileStore.oldPinCode = value,
                    placeholder:
                        Translate.getString("pin.pin_validate", context),
                  ),
                  const SizedBox(height: 10),
                  FormLabel(text: Translate.getString("pin.new_pin", context)),
                  FormTextFieldWidget(
                    isObscure: true,
                    maxLength: 10,
                    initialValue: _profileStore.newPinCode,
                    onChanged: (value) => _profileStore.newPinCode = value,
                    placeholder:
                        Translate.getString("pin.pin_validate", context),
                  ),
                  const SizedBox(height: 10),
                  FormLabel(
                      text: Translate.getString("pin.confirm_pin", context)),
                  FormTextFieldWidget(
                    isObscure: true,
                    maxLength: 10,
                    initialValue: _profileStore.rePinCode,
                    onChanged: (value) => _profileStore.rePinCode = value,
                    placeholder:
                        Translate.getString("pin.pin_validate", context),
                  ),
                ],
              ),
            ),
          ),
          ButtonBottomSide(
            buttonText: Translate.getString("pin.save", context),
            onTap: _onSaveForm,
          )
        ],
      ),
    );
  }

  _onSaveForm() async {
    String realPinCode = await appComponent.getSharedPreferenceHelper().pinCode;
    if (_profileStore.oldPinCode.isEmpty) {
      _showErrorMessage(Translate.getString("pin.old_pin_empty", context));
      return;
    }
    if (_profileStore.newPinCode.isEmpty) {
      _showErrorMessage(Translate.getString("pin.new_pin_empty", context));
      return;
    }
    if (_profileStore.rePinCode != _profileStore.newPinCode) {
      _showErrorMessage(Translate.getString("pin.new_pin_not_same", context));
      return;
    }
    if (_profileStore.oldPinCode != realPinCode) {
      _showErrorMessage(Translate.getString("pin.pin_not_same", context));
      return;
    }
    await appComponent
        .getSharedPreferenceHelper()
        .savePinCode(_profileStore.newPinCode);
    _profileStore.checkPinCodeExist();
    Navigator.pop(context);
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

  @override
  void dispose() {
    super.dispose();
    _profileStore.dispose();
  }
}
