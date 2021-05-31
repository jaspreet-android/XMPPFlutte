// @dart=2.9
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:xmpp_sdk/ui/login_page.dart';
void main() {
  runApp(XMPPSdk());
}

class XMPPSdk extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XMPP SDK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}