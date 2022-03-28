import 'package:boilerplate/widgets/gallery_item.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';

class GalleryGroup extends StatelessWidget {
  final List<Medium> listMedium;
  final String time;

  const GalleryGroup({Key key, this.listMedium, this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 10),
          child: Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listMedium.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (BuildContext context, int index) {
            return GalleryItem(medium: listMedium[index]);
          },
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}
