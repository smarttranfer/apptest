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

class SetupPinCode extends StatefulWidget {
  @override
  _SetupPinCodeState createState() => _SetupPinCodeState();
}

class _SetupPinCodeState extends State<SetupPinCode> {
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
          Translate.getString(
              "pin.${_profileStore.actionControl == "activePin" ? "new_pin" : "remove_pin"}",
              context),
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
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                children: [
                  FormLabel(text: Translate.getString("pin.pin", context)),
                  FormTextFieldWidget(
                    isObscure: true,
                    maxLength: 10,
                    initialValue: _profileStore.pinCode,
                    onChanged: (value) => _profileStore.pinCode = value,
                    placeholder:
                        Translate.getString("pin.pin_validate", context),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: _profileStore.actionControl == "activePin",
                    child: Column(
                      children: [
                        FormLabel(
                            text: Translate.getString(
                                "pin.confirm_pin", context)),
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
                  )
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
    if (_profileStore.pinCode.isEmpty) {
      _showErrorMessage(Translate.getString("pin.pin_empty", context));
      return;
    }
    if (_profileStore.rePinCode != _profileStore.pinCode &&
        _profileStore.actionControl == "activePin") {
      _showErrorMessage(Translate.getString("pin.pin_not_same", context));
      return;
    }
    if (_profileStore.pinCode != realPinCode &&
        _profileStore.actionControl == "inActivePin") {
      _showErrorMessage(Translate.getString("pin.pin_wrong", context));
      return;
    }
    if (_profileStore.actionControl == "activePin")
      await appComponent
          .getSharedPreferenceHelper()
          .savePinCode(_profileStore.pinCode);
    else
      await appComponent.getSharedPreferenceHelper().removePinCode();
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
