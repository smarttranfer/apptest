import 'package:flutter/material.dart';

class IconAssets extends StatelessWidget {
  final String name;
  final double width;
  final double height;
  final Color color;

  const IconAssets(
      {Key key, this.name, this.width = 20, this.height, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('assets/icons/ic_$name.png'),
      width: width,
      height: height,
      color: color,
    );
  }
}
