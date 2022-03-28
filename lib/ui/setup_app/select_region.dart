import 'package:boilerplate/main.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/profile/profile_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/button_bottom_side.dart';
import 'package:boilerplate/widgets/list_region_select.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class SelectRegion extends StatefulWidget {
  @override
  _SelectRegionState createState() => _SelectRegionState();
}

class _SelectRegionState extends State<SelectRegion> {
  HomeStore _homeStore;
  ProfileStore _profileStore;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _homeStore = Provider.of(context);
    _profileStore = Provider.of(context);
    _homeStore.regionCode =
        await appComponent.getSharedPreferenceHelper().currentRegionCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      toolbarHeight: 100.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Translate.getString("start.select_region", context),
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
                color: Color.fromRGBO(37, 38, 43, 1),
                borderRadius: BorderRadius.circular(10)),
            child: CupertinoTextField(
              cursorColor: Colors.blue,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                _profileStore.setRegionFilter(value);
              },
              placeholder:
                  Translate.getString("start.select_region_hint", context),
              placeholderStyle: TextStyle(
                  color: Color.fromRGBO(104, 113, 122, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              prefix: const Padding(
                padding: EdgeInsets.fromLTRB(9.0, 6.0, 9.0, 6.0),
                child: Icon(CupertinoIcons.search, color: Color(0xffC4C6CC)),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Color.fromRGBO(37, 38, 43, 1),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Observer(
        builder: (_) => Column(
              children: [
                ListRegionSelect(),
                ButtonBottomSide(
                    isActive: _homeStore.regionCode != null,
                    buttonText: Translate.getString("start.continue", context),
                    onTap: () {
                      if (_homeStore.regionCode != null) {
                        appComponent
                            .getSharedPreferenceHelper()
                            .changeRegion(_homeStore.regionCode.toString());
                        Navigator.pushNamed(context, Routes.selectLanguage);
                      }
                    })
              ],
            ));
  }
}
