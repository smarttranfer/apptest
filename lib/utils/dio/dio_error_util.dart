import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:boilerplate/utils/extensions/dio_error.dart';

showDioError(DioError e, BuildContext context) {
  Toast.show(
    Translate.getString(e.toErrorMessage(context), context),
    context,
    duration: 3,
    gravity: Toast.BOTTOM,
    backgroundColor: e.response != null ? Colors.orangeAccent : Colors.red,
  );
}
