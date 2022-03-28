import 'package:flutter/material.dart';

class CameraInfo extends StatelessWidget {
  final bool selected;
  final String name;
  final int speed;

  const CameraInfo(
      {Key key, this.selected = false, this.name = "Camera", this.speed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: selected
            ? Color.fromARGB(255, 18, 147, 246)
            : Color.fromARGB(255, 44, 52, 62),
        border: Border.all(
          color: selected ? Colors.blueAccent : Colors.white,
          width: selected ? 1 : 0.25,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.clip,
              maxLines: 1,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Visibility(
            visible: speed == null ? false : true,
            child: Text(
              "${speed}kb/s",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
