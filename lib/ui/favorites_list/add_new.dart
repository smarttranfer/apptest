import 'dart:ui';

import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/models/camera/camera.dart';
import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/camera/camera_store.dart';
import 'package:boilerplate/stores/favorite/favorite_store.dart';
import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/button_bottom_side.dart';
import 'package:boilerplate/widgets/form_label.dart';
import 'package:boilerplate/widgets/form_textfield_widget.dart';
import 'package:boilerplate/widgets/icon_assets.dart';
import 'package:boilerplate/widgets/my_camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class AddFavorite extends StatefulWidget {
  @override
  _AddFavoriteState createState() => _AddFavoriteState();
}

class _AddFavoriteState extends State<AddFavorite> {
  FavoriteStore _favoriteStore;
  HomeStore _homeStore;
  CameraStore _cameraStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeStore = Provider.of(context);
    _favoriteStore = Provider.of(context);
    _cameraStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        String pageTitle = "";
        bool enableForm = true;
        switch (_favoriteStore.actionControl) {
          case "edit":
            pageTitle = Translate.getString("favorite.edit_group", context);
            break;
          case "view":
            pageTitle = Translate.getString("favorite.detail_group", context);
            enableForm = false;
            break;
          default:
            pageTitle = Translate.getString("favorite.add_group", context);
            break;
        }

        return Scaffold(
          appBar: AppBar(
            leadingWidth: 90,
            centerTitle: true,
            leading: FlatButton(
              splashColor: Colors.transparent,
              shape: CircleBorder(),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                Translate.getString("favorite.cancel", context),
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            title: Text(
              pageTitle,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              Visibility(
                visible: _favoriteStore.actionControl == "view",
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _favoriteStore.setActionControl("edit");
                  },
                ),
              ),
              Visibility(
                visible: _favoriteStore.actionControl == "edit",
                child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: _onDelete),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    FormLabel(
                        text: Translate.getString(
                            "favorite.group_name", context)),
                    FormTextFieldWidget(
                      initialValue: _favoriteStore.favorite.name,
                      onChanged: (value) =>
                          _favoriteStore.favorite.name = value,
                      enabled: enableForm,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Translate.getString("favorite.my_camera", context),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Visibility(
                      visible: _favoriteStore.actionControl != "view",
                      child: IconButton(
                        onPressed: _showPUSelectCam,
                        icon: IconAssets(
                          name: "add",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _favoriteStore.actionControl == "edit"
                  ? Expanded(
                      child: ReorderableListView(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        children: [
                          ..._favoriteStore.listCamera
                              .map(
                                (item) => _buildCameraItem(item, context),
                              )
                              .toList()
                        ],
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            _favoriteStore.reorderCamera(oldIndex, newIndex);
                          });
                        },
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final item in _favoriteStore.listCamera)
                              _buildCameraItem(item, context),
                          ],
                        ),
                      ),
                    ),
              ButtonBottomSide(
                buttonText: enableForm
                    ? Translate.getString("favorite.save", context)
                    : Translate.getString("favorite.start_live_view", context),
                onTap: _onChangeAction,
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraItem(Camera item, BuildContext context) {
    return Container(
      key: Key('${item.position}'),
      height: 40,
      color: Color.fromRGBO(23, 22, 27, 1),
      child: GestureDetector(
        onTap: () {
          if (_favoriteStore.actionControl == "edit") _onDeleteCamera(item.id);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 4.0, right: 4.0),
                  child: IconAssets(
                    name: item.controllable == "1" ? "camera_ptz" : "camera",
                    width: 30,
                    color: item.status == "Connected"
                        ? Colors.blue
                        : AppColors.hintColor,
                  ),
                ),
                Visibility(
                  visible: item.function == "Record",
                  child: Positioned(
                    top: 0,
                    right: 0,
                    child: Image(
                      image: AssetImage('assets/icons/ic_record.png'),
                      width: 10,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.only(top: 4.0),
              width: DeviceUtils.getScaledWidth(context, 0.55),
              child: Text(
                item.name,
                style: TextStyle(
                  color: item.status == "Connected"
                      ? Colors.white
                      : AppColors.hintColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  _showPUSelectCam() {
    return showCupertinoModalBottomSheet(
        expand: true, context: context, builder: (context) => MyCamera());
  }

  _onChangeAction() async {
    DeviceUtils.hideKeyboard(context);
    _favoriteStore.validateForm();
    if (_favoriteStore.isInvalidForm) {
      _showErrorMessage(_favoriteStore.errorStore.errorMessage);
      return;
    }
    if (_favoriteStore.actionControl == "view") {
      _cameraStore.deleteAll();
      await Future.delayed(Duration(milliseconds: 200));
      await _cameraStore.insertAllCamera(_favoriteStore.favorite.listCamera);
      _homeStore.setActiveScreen('liveCamera');
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.liveCamera, (Route<dynamic> route) => false);
    } else {
      await _favoriteStore.checkVmsExistedInDb();
      if (!_favoriteStore.isNotExistedInDb) {
        _showErrorMessage(_favoriteStore.errorStore.errorMessage);
        return;
      }
      for (Camera camera in _favoriteStore.listCamera) {
        camera.position = _favoriteStore.listCamera.indexOf(camera);
      }
      _favoriteStore.favorite.listCamera = _favoriteStore.listCamera;
      await _favoriteStore.addOrUpdate();
      if (_favoriteStore.favorite.id != null)
        _favoriteStore.actionControl = "view";
      else
        Navigator.of(context).pop();
    }
  }

  _showErrorMessage(String message) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (message != null && message.isNotEmpty) {
        showCupertinoDialog(
            context: context,
            builder: (context) => Theme(
                  data: ThemeData.dark(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: CupertinoAlertDialog(
                        title: Text(
                            Translate.getString("favorite.warning", context)),
                        content: Text(Translate.getString(message, context)),
                        actions: [
                          CupertinoDialogAction(
                              child: Text(Translate.getString(
                                  "favorite.close", context)),
                              onPressed: () => Navigator.pop(context))
                        ]),
                  ),
                ));
      }
    });
    return SizedBox.shrink();
  }

  _onDelete() {
    showCupertinoDialog(
        context: context,
        builder: (context) => Theme(
              data: ThemeData.dark(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: CupertinoAlertDialog(
                    title:
                        Text(Translate.getString("favorite.warning", context)),
                    content: Text(Translate.getString(
                        "favorite.confirm_delete_group", context)),
                    actions: [
                      CupertinoDialogAction(
                          child: Text(
                            Translate.getString("favorite.yes", context),
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            _favoriteStore.delete();
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                Routes.favoritesList,
                                (Route<dynamic> route) => false);
                          }),
                      CupertinoDialogAction(
                          child: Text(
                              Translate.getString("favorite.no", context),
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () => Navigator.pop(context)),
                    ]),
              ),
            ));
  }

  _onDeleteCamera(String cameraId) {
    showCupertinoDialog(
        context: context,
        builder: (context) => Theme(
              data: ThemeData.dark(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: CupertinoAlertDialog(
                    title:
                        Text(Translate.getString("favorite.warning", context)),
                    content: Text(Translate.getString(
                        "favorite.confirm_delete_camera", context)),
                    actions: [
                      CupertinoDialogAction(
                          child: Text(
                            Translate.getString("favorite.yes", context),
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            _favoriteStore.removeCamera(cameraId);
                            Navigator.pop(context);
                          }),
                      CupertinoDialogAction(
                          child: Text(
                              Translate.getString("favorite.no", context),
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () => Navigator.pop(context)),
                    ]),
              ),
            ));
  }

  @override
  void dispose() {
    super.dispose();
    _favoriteStore.listCamera = [];
  }
}
