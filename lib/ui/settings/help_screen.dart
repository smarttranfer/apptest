import 'package:boilerplate/constants/setting_menu.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translate.getString("setting.help", context),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            for (final menu in helpMenuList)
              GestureDetector(
                onTap: () {
                  // Navigator.pushNamed(context, menu.path);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromRGBO(37, 38, 43, 1),
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
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.white, size: 25)
                    ],
                  ),
                ),
              )
          ]),
    );
  }
}
