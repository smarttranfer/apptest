import 'dart:io';

import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/video_photo/video_photo_store.dart';
import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:boilerplate/widgets/dropdown_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class PhotoDetail extends StatefulWidget {
  PhotoDetail({Key key}) : super(key: key);

  @override
  _PhotoDetailState createState() => _PhotoDetailState();
}

class _PhotoDetailState extends State<PhotoDetail> {
  VideoPhotoStore _videoPhotoStore;
  String path = "";
  int index = 0;
  final PhotoViewController _controller = PhotoViewController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _videoPhotoStore = Provider.of(context);
    await _videoPhotoStore.findAll();
    index = _videoPhotoStore.listMedium.indexOf(_videoPhotoStore.medium);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    index = _videoPhotoStore.listMedium.indexOf(_videoPhotoStore.medium);
    return Scaffold(
      appBar: _isPortrait()
          ? AppBar(
              title: Text(
                Translate.getString("video_photo.photo_detail", context),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              actions: [_buildMenuGroup()],
            )
          : null,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FutureBuilder<File>(
            future: _videoPhotoStore.medium.getFile(),
            builder: (context, snapshot) {
              if (snapshot.data == null) return Container();
              path = snapshot.data.path;
              if (_isPortrait()) {
                return Stack(
                  children: [
                    PhotoView.customChild(
                      controller: _controller,
                      minScale: 1.0,
                      initialScale: 1.0,
                      child: Image.file(snapshot.data),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 20 + MediaQuery.of(context).padding.top,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data.uri.pathSegments.last,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            DateFormat('HH:mm dd-MM-yyyy')
                                .format(_videoPhotoStore.medium.modifiedDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Stack(
                children: [
                  PhotoView.customChild(
                    minScale: 1.0,
                    controller: _controller,
                    initialScale: 2.0,
                    child: Image.file(snapshot.data),
                  ),
                  Container(
                    color: const Color.fromARGB(150, 42, 43, 49),
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        snapshot.data.uri.pathSegments.last,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  Align(alignment: Alignment.topRight, child: _buildMenuGroup())
                ],
              );
            },
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: index > 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _controller.scale = _isPortrait() ? 1 : 2;
                      _videoPhotoStore
                          .setMedium(_videoPhotoStore.listMedium[index - 1]);
                      setState(() {});
                    },
                  ),
                ),
                Visibility(
                  visible: index < _videoPhotoStore.listMedium.length - 1,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _controller.scale = _isPortrait() ? 1 : 2;
                      _videoPhotoStore
                          .setMedium(_videoPhotoStore.listMedium[index + 1]);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup() {
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

  _onPopupMenuSelected(int index) {
    if (index == 0) {
      Share.shareFiles([path],
          text: Translate.getString("video_photo.share", context));
    } else {
      _onDelete();
    }
  }

  _onDelete() {
    showCupertinoDialog(
        context: context,
        builder: (context) => Theme(
              data: ThemeData.dark(),
              child: CupertinoAlertDialog(
                  title: Text(
                      Translate.getString("video_photo.delete_photo", context)),
                  content: Text(Translate.getString(
                      "video_photo.delete_photo_confirm", context)),
                  actions: [
                    CupertinoDialogAction(
                        child: Text(
                            Translate.getString("video_photo.yes", context),
                            style: TextStyle(color: Colors.red)),
                        onPressed: () async {
                          await _videoPhotoStore.deleteMedium();
                          Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.videoAndPhoto,
                              (Route<dynamic> route) => false);
                        }),
                    CupertinoDialogAction(
                        child: Text(
                            Translate.getString("video_photo.no", context),
                            style: TextStyle(color: Colors.blue)),
                        onPressed: () => Navigator.pop(context)),
                  ]),
            ));
  }

  bool _isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}
