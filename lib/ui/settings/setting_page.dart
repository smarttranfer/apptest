import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/constants/regions.dart';
import 'package:boilerplate/constants/setting_menu.dart';
import 'package:boilerplate/main.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/language/language_store.dart';
import 'package:boilerplate/stores/profile/profile_store.dart';
import 'package:boilerplate/ui/home/home.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/button_bottom_side.dart';
import 'package:boilerplate/widgets/close_btn_bottom_sheet.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:boilerplate/widgets/language_picker.dart';
import 'package:boilerplate/widgets/list_region_select.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class SettingPage extends HomeScreen {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends HomeScreenState<SettingPage>
    with HomeScreenPage {
  HomeStore _homeStore;
  LanguageStore _languageStore;
  ProfileStore _profileStore;

  @override
  Widget action() {
    return Container();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _homeStore = Provider.of(context);
    _languageStore = Provider.of(context);
    _profileStore = Provider.of(context);
    if (_homeStore.currentRouteName == ModalRoute.of(context).settings.name) {

      _homeStore.setActiveScreen(ModalRoute.of(context).settings.name.replaceAll("/", ""));
    }
    _profileStore.checkPinCodeExist();
    _homeStore.regionCode =
        await appComponent.getSharedPreferenceHelper().currentRegionCode;
  }

  @override
  Widget body() {
    return ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          for (final menu in mainMenuList)
            GestureDetector(
              onTap: () {
                _onTapItem(menu.path);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(37, 38, 43, 1),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                height: 50,
                child: Row(
                  children: <Widget>[
                    IconAssets(name: menu.iconName),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Translate.getString(menu.title, context),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    getTrailingWidget(menu.iconName),
                  ],
                ),
              ),
            )
        ]);
  }

  _onTapItem(String path) {
    switch (path) {
      case '/region':
        _openBSRegion();
        break;
      case '/language':
        _openBSLanguage();
        break;
      case '/tabletMode':
        return;
      default:
        Navigator.pushNamed(context, path);
        break;
    }
  }

  Future<void> _openBSRegion() {
    _profileStore.setRegionFilter("");
    return showModalBottomSheet(
        backgroundColor: Color.fromRGBO(23, 22, 27, 1),
        context: context,
        builder: (context) {
          return Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Translate.getString("setting.select_region", context),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    CloseBtnBottomSheet()
                  ],
                ),
              ),
              ListRegionSelect(),
              ButtonBottomSide(
                  isActive: true,
                  buttonText: Translate.getString("setting.done", context),
                  onTap: () {
                    appComponent
                        .getSharedPreferenceHelper()
                        .changeRegion(_homeStore.regionCode);
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Future<void> _openBSLanguage() {
    return showModalBottomSheet(
        backgroundColor: Color.fromRGBO(23, 22, 27, 1),
        context: context,
        builder: (context) {
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          Translate.getString(
                              "setting.select_language", context),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        CloseBtnBottomSheet()
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: LanguagePicker(),
                  ),
                ],
              ),
              ButtonBottomSide(
                  isActive: true,
                  buttonText: Translate.getString("setting.done", context),
                  onTap: () {
                    appComponent
                        .getSharedPreferenceHelper()
                        .changeLanguage(_languageStore.locale);
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget getTrailingWidget(String name) {
    switch (name) {
      case 'security':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Observer(
              builder: (_) => Text(
                Translate.getString(
                    "setting.${_profileStore.isExistedPinCode ? "on" : "off"}",
                    context),
                style: const TextStyle(color: AppColors.hintColor),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white, size: 25),
          ],
        );
      case 'region':
        return Observer(builder: (_) {
          List<Region> listCountries = _profileStore.listCountries.isEmpty
              ? listCountriesCache.map((e) => Region.fromJson(e)).toList()
              : _profileStore.listCountries;
          String regionName = "";
          for (var item in listCountries) {
            if (item.regionalId.toString() == _homeStore.regionCode) {
              regionName = item.name;
            }
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                regionName,
                style: TextStyle(
                  color: AppColors.hintColor,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 25,
              ),
            ],
          );
        });
      case 'language':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _languageStore.supportedLanguages
                  .firstWhere(
                      (element) => element.locale == _languageStore.locale)
                  .language,
              style: TextStyle(
                color: AppColors.hintColor,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 25),
          ],
        );
      case 'tablet_mode':
        return CupertinoSwitch(
          value: false,
          onChanged: (value) => {},
          trackColor: AppColors.hintColor,
          activeColor: AppColors.accentColor,
        );
      default:
        return Icon(
          Icons.chevron_right,
          color: Colors.white,
          size: 25,
        );
    }
  }

  @override
  PreferredSize bottom() {
    return PreferredSize(
      preferredSize: Size(0, 0),
      child: Container(),
    );
  }
}
