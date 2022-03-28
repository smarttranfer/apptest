import 'package:boilerplate/constants/colors.dart';
import 'package:flutter/material.dart';

class CardTextFieldWidget extends StatelessWidget {
  final IconData icon;
  final String hint;
  final String errorText;
  final bool isObscure;
  final TextInputType inputType;
  final ValueChanged onChanged;
  final TextInputAction inputAction;
  final String initialValue;
  final bool enabled;

  const CardTextFieldWidget({
    Key key,
    this.icon,
    this.hint,
    this.errorText,
    this.isObscure = false,
    this.inputType,
    this.onChanged,
    this.inputAction,
    this.initialValue,
    this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          enabled: enabled,
          initialValue: initialValue,
          obscureText: isObscure,
          textInputAction: inputAction,
          keyboardType: inputType,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white),
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.hintColor),
            filled: true,
            fillColor: AppColors.buttonBackground1Color,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            errorText ?? "",
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        )
      ],
    );
  }
}
