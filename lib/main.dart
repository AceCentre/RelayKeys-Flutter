import 'package:relay_keys/consts/Const.dart';
import 'package:relay_keys/pages/hid_page.dart';
import 'package:flutter/material.dart';
import 'package:relay_keys/pages/main_page.dart';

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Relay Keys',
      color: Const.primaryColor,
      theme: ThemeData(
        // primarySwatch: Const.primaryColor,
        primaryColor: Const.primaryColor,
        accentColor: Const.accentColor,
      ),
      // home: HIDPage(),
      routes: {
        '/': (context) => MainPage(),
        '/hid': (context) => HIDPage(),
      },
      // navigatorKey: Glob.navigatorKey,
    ),
  );
}
