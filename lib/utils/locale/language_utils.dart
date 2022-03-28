import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/cupertino.dart';

class Translate {
  static String getString(
    String key,
    BuildContext context,
  ) {
    if (AppLocalizations.of(context) != null) {
      return AppLocalizations.of(context).translate(key);
    } else {
      return "e:" + key;
    }
  }
}
