import 'package:flutter/material.dart';

class CircleButton extends StatefulWidget {
  final String text;
  final Function() onTap;
  final Function() onLongPressStart;
  final Function() onLongPressEnd;

  CircleButton({
    Key key,
    this.text,
    @required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  }) : super(key: key);

  @override
  _CircleButtonState createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
  Color color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.onTap != null) widget.onTap();
        await Future.delayed(Duration(milliseconds: 100));
        setState(() {
          color = Colors.white;
        });
      },
      onPanDown: (e) {
        setState(() {
          color = Colors.grey;
        });
      },
      onLongPressStart: (e) {
        if (widget.onLongPressStart != null) widget.onLongPressStart();
      },
      onLongPressEnd: (e) async {
        if (widget.onLongPressEnd != null) widget.onLongPressEnd();
        await Future.delayed(Duration(milliseconds: 100));
        setState(() {
          color = Colors.white;
        });
      },
      child: CircleAvatar(
        backgroundColor: color,
        child: Text(
          widget.text,
          style: TextStyle(fontSize: 22, color: Colors.black),
        ),
      ),
    );
  }
}
