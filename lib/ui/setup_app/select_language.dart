import 'package:boilerplate/main.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/language/language_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/button_bottom_side.dart';
import 'package:boilerplate/widgets/language_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectLanguage extends StatefulWidget {
  @override
  _SelectLanguageState createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  LanguageStore _languageStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: DeviceUtils.getScaledHeight(context, 0.15)),
            Center(
              child: Image.asset('assets/images/ai_cms.png', height: 50),
            ),
            SizedBox(height: 60),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translate.getString("start.select_language", context),
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  LanguagePicker()
                ],
              ),
            )
          ],
        ),
        ButtonBottomSide(
            buttonText: Translate.getString("start.continue", context),
            onTap: () async {
              appComponent
                  .getSharedPreferenceHelper()
                  .changeLanguage(_languageStore.locale);
              if (await appComponent.getSharedPreferenceHelper().isLoggedIn)
                Navigator.of(context).pushReplacementNamed(Routes.liveCamera);
              else
                Navigator.of(context).pushReplacementNamed(Routes.login);
            })
      ],
    );
  }
}
