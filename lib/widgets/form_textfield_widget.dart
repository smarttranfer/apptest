import 'package:boilerplate/constants/colors.dart';
import 'package:flutter/material.dart';

class FormTextFieldWidget extends StatelessWidget {
  final Widget prefixWidget;
  final Widget suffixWidget;
  final Widget suffixIcon;
  final String hint;
  final bool isObscure;
  final ValueChanged onChanged;
  final Function onEditingComplete;
  final String initialValue;
  final bool enabled;
  final String placeholder;
  final int maxLength;
  final TextEditingController controller;
  final Function onTap;

  const FormTextFieldWidget({
    Key key,
    this.prefixWidget,
    this.suffixWidget,
    this.suffixIcon,
    this.hint,
    this.isObscure = false,
    this.onChanged,
    this.onEditingComplete,
    this.initialValue,
    this.placeholder,
    this.enabled = true,
    this.maxLength = 200,
    this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      initialValue: initialValue,
      cursorColor: Colors.blue,
      obscureText: isObscure,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      readOnly: !enabled,
      onTap: onTap,
      buildCounter: (BuildContext context,
              {int currentLength, int maxLength, bool isFocused}) =>
          null,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(
          color: AppColors.hintColor,
          fontSize: 18,
          fontWeight: FontWeight.w100,
        ),
        suffix: suffixWidget,
        suffixIcon: suffixIcon,
        prefixIcon: prefixWidget,
        fillColor: Color.fromRGBO(37, 38, 43, 1),
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(10.0),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
      ),
      style: TextStyle(
        color: enabled ? Colors.white : Color.fromRGBO(104, 113, 122, 1),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
