import 'icon_assets.dart';
import 'package:flutter/material.dart';

class MainControlButton extends StatelessWidget {
  final Function onPressed;
  final Color color;
  final Color iconColor;
  final String icon;
  final double height;
  final double width;
  final double maxRadius;

  const MainControlButton({
    Key key,
    this.onPressed,
    this.color = Colors.white,
    this.iconColor,
    this.icon,
    this.height = 20,
    this.width = 20,
    this.maxRadius = 25,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      maxRadius: maxRadius,
      child: IconButton(
        color: color,
        icon: IconAssets(name: icon, color: iconColor, height: height, width: width),
        onPressed: onPressed,
      ),
    );
  }
}
