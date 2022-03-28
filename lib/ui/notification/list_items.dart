import 'package:boilerplate/ui/home/home.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationList extends HomeScreen {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends HomeScreenState<NotificationList>
    with HomeScreenPage {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget body() {
    return Center(
        child: Container(
      child: Text(
        Translate.getString("notification.no_data", context),
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  @override
  Widget action() {
    return IconButton(
      icon: const IconAssets(name: "add", width: 20),
      onPressed: () {},
    );
  }

  @override
  PreferredSize bottom() {
    return PreferredSize(
      preferredSize: Size(0, 0),
      child: Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
