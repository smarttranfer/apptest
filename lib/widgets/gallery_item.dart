import 'package:boilerplate/routes.dart';
import 'package:boilerplate/stores/video_photo/video_photo_store.dart';
import 'package:boilerplate/widgets/video_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:provider/provider.dart';

class GalleryItem extends StatefulWidget {
  final Medium medium;

  const GalleryItem({
    Key key,
    this.medium,
  }) : super(key: key);

  @override
  _GalleryItemState createState() => _GalleryItemState();
}

class _GalleryItemState extends State<GalleryItem> {
  VideoPhotoStore _videoPhotoStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _videoPhotoStore = Provider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            if (_videoPhotoStore.isEditing) {
              _videoPhotoStore.selectMedium(widget.medium);
            } else {
              _videoPhotoStore.setMedium(widget.medium);
              if (widget.medium.mediumType == MediumType.image) {
                Navigator.pushNamed(context, Routes.photoDetail);
              } else {
                Navigator.pushNamed(context, Routes.videoDetail);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              image: DecorationImage(
                image: widget.medium.mediumType == MediumType.video
                    ? ThumbnailProvider(
                        mediumId: widget.medium.id,
                        mediumType: widget.medium.mediumType,
                        highQuality: true,
                      )
                    : PhotoProvider(mediumId: widget.medium.id),
                fit: BoxFit.cover,
              ),
              color: const Color.fromARGB(255, 44, 52, 62),
            ),
          ),
        ),
        if (widget.medium.mediumType == MediumType.video)
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: VideoDuration(duration: widget.medium.duration),
          ),
        Observer(builder: (context) {
          return Visibility(
            visible: _videoPhotoStore.isEditing,
            child: Positioned(
              right: 0,
              child: Theme(
                  data: Theme.of(context)
                      .copyWith(unselectedWidgetColor: Colors.white),
                  child: Checkbox(
                      value: _videoPhotoStore.listMediumSelected
                          .contains(widget.medium),
                      onChanged: (value) {
                        _videoPhotoStore.selectMedium(widget.medium);
                      })),
            ),
          );
        })
      ],
    );
  }
}
