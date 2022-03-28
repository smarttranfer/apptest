import 'package:boilerplate/stores/language/language_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:smart_select/smart_select.dart';

import 'icon_assets.dart';

class LanguagePicker extends StatefulWidget {
  @override
  _LanguagePickerState createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  LanguageStore _languageStore;
  List<S2Choice<String>> options = [
    S2Choice<String>(value: 'vi', title: 'Tiếng việt'),
    S2Choice<String>(value: 'en', title: 'English'),
  ];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _languageStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return SmartSelect<String>.single(
        title: "",
        value: _languageStore.locale,
        choiceItems: options,
        modalHeader: false,
        onChange: (state) => _languageStore.locale = state.value,
        modalType: S2ModalType.popupDialog,
        modalConfig: const S2ModalConfig(
            style: S2ModalStyle(
                backgroundColor: Color.fromRGBO(27, 29, 32, 1),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))))),
        choiceConfig: S2ChoiceConfig(
          style: const S2ChoiceStyle(
            titleStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            color: Colors.white,
          ),
        ),
        tileBuilder: (context, state) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color.fromRGBO(37, 38, 43, 1)),
            child: S2Tile.fromState(state,
                title: Text(
                  state.valueTitle,
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                hideValue: true,
                leading: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0)),
                      color: Color.fromRGBO(27, 29, 32, 1)),
                  child: IconAssets(
                    name:
                        _languageStore.locale == "vi" ? "vn_flag" : "usa_flag",
                    width: 25,
                  ),
                ),
                padding: const EdgeInsets.all(0.0)),
          );
        });
  }
}
