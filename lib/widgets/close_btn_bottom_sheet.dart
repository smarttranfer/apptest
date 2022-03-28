import 'package:flutter/material.dart';

class CloseBtnBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 25,
        height: 25,
        child: Icon(Icons.close, color: Colors.black, size: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          border: Border.all(width: 0.6, color: Colors.grey[300]),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
