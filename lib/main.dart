// @dart=2.9
import 'package:flutter/material.dart';
import 'package:xmpp_sdk/core/xmpp_connection.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/home_page.dart';
import 'package:xmpp_sdk/ui/login_page.dart';

final dbHelper = DatabaseHelper.instance;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final allRows = await dbHelper.queryAllRows(DatabaseHelper.account_table);
  print("all rows =" + allRows.toString());
  if(allRows.length > 0){
    alreadyFilled(allRows);
  }
  runApp(
  MaterialApp( home: allRows.length == 0 ? LoginPage() : MyHomePage()),
  );
}

Future<void> alreadyFilled(final allRows ) async{
  allRows.forEach((element) {
    var host = element['host'];
    var port = int.parse(element['port']);
    var username = element['username'];
    var domain = element['domain'];
    var password = element['password'];
    var resource = element['resource'];
    XMPPConnection().login(host,port,username,domain,password,resource,null);
  });
}