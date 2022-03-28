import 'package:boilerplate/utils/locale/language_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

extension DateTimeExtensions on DioError {
  String toErrorMessage(BuildContext context) {
    if (this.response != null)
      switch (this.response.statusCode) {
        case 500:
          return Translate.getString("error.500", context);
        case 401:
          return Translate.getString("error.500", context);
        case 400:
          return Translate.getString("error.400", context);
        case 403:
          return Translate.getString("error.403", context);
        case 300:
          return Translate.getString("error.300", context);
        case 301:
          return Translate.getString("error.301", context);
        case 410:
          return Translate.getString("error.410", context);
        case 204:
          return Translate.getString("error.204", context);
      }
    return "error.default";
  }
}
