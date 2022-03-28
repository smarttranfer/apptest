import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ButtonBottomSide extends StatelessWidget {
  final String buttonText;
  final Function onTap;
  final bool isActive;

  const ButtonBottomSide(
      {@required this.buttonText, this.onTap, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 25, top: 15),
        width: MediaQuery.of(context).size.width,
        height: 90,
        child: FloatingActionButton.extended(
          onPressed: isActive ? onTap : null,
          backgroundColor:
              isActive ? Colors.blue : Color.fromRGBO(106, 119, 127, 1),
          label: Text(
            buttonText,
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
        ),
      ),
    );
  }
}
