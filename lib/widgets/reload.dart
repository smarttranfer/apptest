import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/material.dart';

class Reload extends StatelessWidget {
  final Function onReload;

  const Reload({Key key, this.onReload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: onReload,
        icon: IconAssets(name: "reload"),
      ),
    );
  }
}
