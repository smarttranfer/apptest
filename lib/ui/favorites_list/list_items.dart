import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/models/favorite/favorite.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/ui/home/home.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/button_bottom_side.dart';
import 'package:boilerplate/widgets/camera_thumb.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';

class FavoritesList extends HomeScreen {
  @override
  _FavoritesListState createState() => _FavoritesListState();
}

class _FavoritesListState extends HomeScreenState<FavoritesList>
    with HomeScreenPage {
  FavoriteStore _favoriteStore;
  HomeStore _homeStore;
  CameraStore _cameraStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _favoriteStore = Provider.of(context);
    _homeStore = Provider.of(context);
    _cameraStore = Provider.of(context);
  }

  @override
  Widget body() {
    return Column(
      children: [
        Expanded(
          child: Observer(builder: (context) {
            _favoriteStore.listFavorite
                .sort((a, b) => a.name.compareTo(b.name));
            return _favoriteStore.listFavorite.length > 0
                ? ListView(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    physics: AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    children: [
                        for (Favorite item in _favoriteStore.listFavorite)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(37, 38, 43, 1),
                            ),
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            height: 100,
                            child: Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    if (_favoriteStore.isNavigateFromLiveCam)
                                      return;
                                    if (item.listCamera.isEmpty)
                                      _goToDetailScreen(item);
                                    else {
                                      _cameraStore.deleteAll();
                                      await Future.delayed(
                                          Duration(milliseconds: 200));
                                      await _cameraStore
                                          .insertAllCamera(item.listCamera);
                                      _homeStore.setActiveScreen("liveCamera");
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              Routes.liveCamera,
                                              (Route<dynamic> route) => false);
                                    }
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    child: CameraThumb(
                                      listCamera: item.listCamera,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "${item.listCamera.length.toString()} Camera",
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ),
                                    ],
                                  ),
                                ),
                                _favoriteStore.isNavigateFromLiveCam
                                    ? Theme(
                                        data: Theme.of(context).copyWith(
                                          unselectedWidgetColor: Colors.white,
                                        ),
                                        child: Checkbox(
                                          value: item.listCamera
                                              .contains(_cameraStore.camera),
                                          onChanged: (value) async {
                                            Camera cameraSelect =
                                                _cameraStore.camera;
                                            cameraSelect.position =
                                                item.listCamera.length;
                                            value
                                                ? item.listCamera
                                                    .add(cameraSelect)
                                                : item.listCamera
                                                    .remove(cameraSelect);
                                            setState(() {});
                                            await _favoriteStore
                                                .addOrUpdate(item);
                                          },
                                        ),
                                      )
                                    : IconButton(
                                        icon: IconAssets(
                                          name: "more_option",
                                          height: 20,
                                        ),
                                        onPressed: () {
                                          _goToDetailScreen(item);
                                        },
                                      ),
                              ],
                            ),
                          )
                      ])
                : Center(
                    child: Text(
                      Translate.getString("favorite.no_data", context),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
          }),
        ),
        Visibility(
          visible: _favoriteStore.isNavigateFromLiveCam,
          child: ButtonBottomSide(
            buttonText: Translate.getString("favorite.done", context),
            onTap: () {
              _homeStore.setActiveScreen('liveCamera');
              Navigator.of(context).pop();
            },
          ),
        )
      ],
    );
  }

  @override
  Widget action() {
    return IconButton(
      icon: const IconAssets(name: "add", width: 20),
      onPressed: () {
        _favoriteStore.setFavorite(
          Favorite(
            name: "",
            listCamera: [],
          ),
        );
        _favoriteStore.setActionControl("add");
        Navigator.pushNamed(context, Routes.addFavorite);
      },
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

  _goToDetailScreen(Favorite item) {
    _favoriteStore.setFavorite(item);
    _favoriteStore.setActionControl("view");
    Navigator.pushNamed(context, Routes.addFavorite);
  }
}
