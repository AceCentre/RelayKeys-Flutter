import 'package:flutter/material.dart';

class Const {
  static const int LANGING_PAGE_ID = 0;
  static const int SENSORS_PAGE_ID = 1;
  static const int READINGS_PAGE_ID = 2;

  static const int READINGS_BUF_LEN = 64;

  static const String devBleName = 'capled';

  static const primaryColor = Color(0xff6a9dc7);
  static const accentColor = Color(0xffabcc59);

  Const._();

  static const connectTimeout = 5;
}

class Glob {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
