// @dart=2.9
import 'package:flutter/material.dart';
import 'package:xmpp_sdk/core/xmpp_utils.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/home_page.dart';
import 'package:xmpp_sdk/ui/login_page.dart';

final dbHelper = DatabaseHelper.instance;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final allRows = await dbHelper.queryAllRows(DatabaseHelper.account_table);
  print("all rows =" + allRows.toString());
  if(allRows.length > 0){
    alreadyFilled(allRows, null);
  }
  runApp(
  MaterialApp( home: allRows.length == 0 ? LoginPage() : MyHomePage()),
  );
}

Future<void> alreadyFilled(final allRows , BuildContext context) async{
  allRows.forEach((element) {
    var host = element['host'];
    var port = int.parse(element['port']);
    var username = element['username'];
    var domain = element['domain'];
    var password = element['password'];
    var resource = element['resource'];
    login(host,port,username,domain,password,resource,context);
  });
}

// class XMPPSdk extends StatelessWidget {
//   // This widget is the root of your application.
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'XMPP SDK',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//
//       home: LoginPage(),
//     );
//   }
//
// }