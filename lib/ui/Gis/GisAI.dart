import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:boilerplate/StoredataScurety/StoreSercurity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:boilerplate/widgets/side_bar_menu.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'StoreUrlGis.dart' as stores;
import 'package:http/http.dart' as http;

class urlview extends StatefulWidget {
  @override
  _urlState createState() => _urlState();
}

class _urlState extends State<urlview> {
  String urls;
  num position = 1;
  @override
  void initState() {
    super.initState();
    getGis();
  }

  void getGis() async {
    final prefs = await SharedPreferences.getInstance();
    String url = await prefs.getString("vms.gis");
    setState(() {
      urls = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "AI GIS",
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          leading: Builder(builder: (context) {
            return IconButton(
              icon: IconAssets(name: "menu_left"),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          }),
        ),
        drawer: SidebarMenu(),
        body: urls == null
            ? Container(
                child: Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 18, 147, 246),)),
              )
            : IndexedStack(
                index: position,
                children: [
                  WebView(
                    initialUrl: urls,
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageStarted: (value) {
                      setState(() {
                        position = 1;
                      });
                    },
                    onPageFinished: (value) {
                      setState(() {
                        position = 0;
                      });
                    },
                  ),
                  Container(
                    child: Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 18, 147, 246))),
                  ),
                ],
              )
        );
  }
}
