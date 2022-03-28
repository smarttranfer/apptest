import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  FormLabel({@required this.text, this.isRequired = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: [
          Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(width: 5),
          Visibility(
              visible: isRequired,
              child:
                  Text("*", style: TextStyle(color: Colors.red, fontSize: 18)))
        ],
      ),
    );
  }
}
