import 'dart:ui';

import 'package:boilerplate/stores/home/home_store.dart';
import 'package:boilerplate/stores/video_photo/video_photo_store.dart';
import 'package:boilerplate/ui/home/home.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/dropdown_menu.dart';
import 'package:boilerplate/widgets/gallery_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share/share.dart';

class VideoPhoto extends HomeScreen {
  @override
  _VideoPhotoState createState() => _VideoPhotoState();
}

class _VideoPhotoState extends HomeScreenState<VideoPhoto> with HomeScreenPage {
  VideoPhotoStore _videoPhotoStore;
  HomeStore _homeStore;

  @override
  void initState() {
    super.initState();
    _homeStore = HomeStore();
    _videoPhotoStore = VideoPhotoStore();
    requestPermission();
  }

  requestPermission() async {
    // _homeStore.isHavePhotoPermission = await PhotoManager.requestPermission();
    if (_homeStore.isHavePhotoPermission) _videoPhotoStore.findAll();
  }

  @override
  Widget body() {
    return Column(
      children: [
        Observer(builder: (context) {
          return Visibility(
            visible: _videoPhotoStore.isEditing,
            child: Row(
              children: [
                Theme(
                    data: Theme.of(context)
                        .copyWith(unselectedWidgetColor: Colors.white),
                    child: Checkbox(
                        value: _videoPhotoStore.listMediumSelected.length ==
                            _videoPhotoStore.listMedium.length,
                        onChanged: (value) {
                          _videoPhotoStore.selectAllMedium();
                        })),
                Text(
                  _getSelectAllText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    _videoPhotoStore.setEditing(false);
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text(
                      Translate.getString("video_photo.cancel", context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Expanded(
          child: Observer(
            builder: (context) {
              Map<String, List<Medium>> list = _videoPhotoStore.listMedium
                  .groupBy((item) => _getTimeString(item.modifiedDate));
              List<String> items = list.keys.toList();
              return _videoPhotoStore.listMedium.isNotEmpty
                  ? ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: const BouncingScrollPhysics()),
                      itemCount: items.length,
                      itemBuilder: (context, int index) {
                        return GalleryGroup(
                          listMedium: list[items[index]],
                          time: items[index],
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        Translate.getString("video_photo.no_data", context),
                        style: TextStyle(color: Colors.white),
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget action() {
    return Observer(builder: (context) {
      if (!_videoPhotoStore.isEditing) {
        return IconButton(
          icon: Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            _videoPhotoStore.setEditing(true);
          },
        );
      }
      if (_videoPhotoStore.listMediumSelected.isNotEmpty) {
        return DropdownMenu(
            onChange: _onPopupMenuSelected,
            child: const Icon(Icons.more_vert, color: Colors.white),
            items: [
              _buildMenuItem("share", Icons.share, Colors.white,
                  Translate.getString("video_photo.share", context)),
              _buildMenuItem("delete", Icons.delete, Colors.red,
                  Translate.getString("video_photo.delete", context)),
            ]);
      }
      return Container();
    });
  }

  @override
  PreferredSize bottom() {
    return PreferredSize(
      preferredSize: Size(0, 0),
      child: Container(),
    );
  }

  String _getTimeString(DateTime time) {
    if (time == null)
      return Translate.getString("video_photo.unknown", context);
    DateTime now = DateTime.now();
    final elapsed = now.millisecondsSinceEpoch - time.millisecondsSinceEpoch;
    final days = (elapsed / 1000 / 60 / 60 / 24).round();
    if (days < 1) return Translate.getString("video_photo.today", context);
    if (days < 2) return Translate.getString("video_photo.yesterday", context);
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    return dateFormat.format(time);
  }

  String _getSelectAllText() {
    int selected = _videoPhotoStore.listMediumSelected.length;
    if (selected == 0) return Translate.getString("video_photo.all", context);
    return "${Translate.getString("video_photo.all", context)} (${_videoPhotoStore.listMediumSelected.length})";
  }

  Widget _buildMenuItem(
      String value, IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(color: Colors.white))
      ],
    );
  }

  _onPopupMenuSelected(index) async {
    if (index == 0) {
      List<String> files = [];
      for (Medium medium in _videoPhotoStore.listMediumSelected) {
        final file = await medium.getFile();
        files.add(file.path);
      }
      Share.shareFiles(files,
          text: Translate.getString("video_photo.share", context));
    } else if (index == 1) {
      _onDelete();
    }
  }

  _onDelete() {
    showCupertinoDialog(
        context: context,
        builder: (context) => Theme(
              data: ThemeData.dark(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: CupertinoAlertDialog(
                    title: Text(Translate.getString(
                        "video_photo.delete_photo_video", context)),
                    content: Text(Translate.getString(
                        "video_photo.delete_confirm", context)),
                    actions: [
                      CupertinoDialogAction(
                          child: Text(
                              Translate.getString("video_photo.yes", context),
                              style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _videoPhotoStore.deleteMediumSelected();
                            await _videoPhotoStore.findAll();
                            await _videoPhotoStore.setEditing(false);
                          }),
                      CupertinoDialogAction(
                          child: Text(
                              Translate.getString("video_photo.no", context),
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () => Navigator.pop(context)),
                    ]),
              ),
            ));
  }
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}
