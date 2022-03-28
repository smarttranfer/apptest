import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeAppbar extends PreferredSize {
  final PreferredSize bottom;
  final List<Widget> actions;

  HomeAppbar(this.bottom, this.actions);

  @override
  Size get preferredSize =>
      Size.fromHeight(bottom.preferredSize.height + kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return _HomeAppbar(bottom: bottom, actions: actions);
  }
}

class _HomeAppbar extends StatefulWidget {
  final PreferredSize bottom;
  final List<Widget> actions;

  const _HomeAppbar({Key key, this.bottom, this.actions}) : super(key: key);

  @override
  _HomeAppbarState createState() => _HomeAppbarState();
}

class _HomeAppbarState extends State<_HomeAppbar> {
  HomeStore _homeStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(builder: (context) {
        return IconButton(
          icon: IconAssets(name: "menu_left"),
          onPressed: () => Scaffold.of(context).openDrawer(),
        );
      }),
      title: Text(
        _getScreenName(),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
      ),
      centerTitle: true,
      bottom: widget.bottom,
      actions: widget.actions,
    );
  }

  String _getScreenName() {
    switch (_homeStore.currentScreen) {
      case "liveCamera":
        return Translate.getString("home.live_view", context);
      case "rollCamera":
        return Translate.getString("home.playback", context);
      case "notification":
        return Translate.getString("home.manage_notification", context);
      case "manageDevice":
        return Translate.getString("home.manage_device", context);
      case "favoritesList":
        return Translate.getString("home.list_favorite", context);
      case "videoAndPhoto":
        return Translate.getString("home.video_photo", context);
      case "setting":
        return Translate.getString("home.setting", context);
    }
    return "";
  }
}
