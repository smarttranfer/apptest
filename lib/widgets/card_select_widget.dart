import 'package:boilerplate/constants/colors.dart';
import 'package:flutter/material.dart';

class CardSelectWidget extends StatelessWidget {
  final IconData icon;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final Color iconColor;
  final ValueChanged onChanged;
  final String value;
  final List<String> items;

  const CardSelectWidget({
    Key key,
    this.icon,
    this.margin = const EdgeInsets.only(left: 30, right: 30, top: 10),
    this.iconColor = Colors.black26,
    this.onChanged,
    this.elevation = 11,
    this.value,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      color: AppColors.buttonBackground1Color,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.white),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                value: value,
                isDense: true,
                onChanged: onChanged,
                items: items.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
