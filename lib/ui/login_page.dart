import 'package:xmpp_sdk/base/logger/Log.dart';
import 'package:xmpp_sdk/core/xmpp_stone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:xmpp_sdk/core/xmpp_utils.dart';
import 'package:xmpp_sdk/db/database_helper.dart';

class LoginPage extends StatelessWidget {
  final String TAG = 'LoginPage';
  final dbHelper = DatabaseHelper.instance;
  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'XMPP Loin',
      hideForgotPasswordButton: true,
      hideSignUpButton: true,
      onLogin: (LoginData data){
        connectXMPP(data,context);
        return null;
      },

      emailValidator: (String arg) {
        if (arg.length < 8)
          return 'Username must be more than 8 charater';
        else
          return null;
      },

      messages: LoginMessages(
        usernameHint: 'Username',
        passwordHint: 'Password',
        confirmPasswordHint: 'Confirm',
        loginButton: 'LOG IN',
        signupButton: 'REGISTER',
        forgotPasswordButton: 'Forgot password?',
        recoverPasswordButton: 'HELP ME',
        goBackButton: 'GO BACK',
        confirmPasswordError: 'Not match!',
        recoverPasswordDescription:
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
        recoverPasswordSuccess: 'Password rescued successfully',
      ),
    );
  }


  Future<void> connectXMPP(LoginData data, BuildContext context) async {
    Log.logLevel = LogLevel.DEBUG;
    Log.logXmpp = true;

    final allRows = await dbHelper.queryAllRows(DatabaseHelper.account_table);
    if(allRows.length == 0) {
      var host = "192.168.29.9";
      var port = 5222;
      var username = data.name;
      var domain = "localhost";
      var password = data.password;
      var resource = 'scrambleapps';
      print('connecting...');
      Map<String, dynamic> row = {
        DatabaseHelper.username: username,
        DatabaseHelper.password: password,
        DatabaseHelper.domain: domain,
        DatabaseHelper.host: host,
        DatabaseHelper.port: port.toString(),
        DatabaseHelper.resource: resource
      };
      dbHelper.insert(DatabaseHelper.account_table, row);
      login(
          host,
          port,
          username,
          domain,
          password,
          resource,
          context);
    }else{
      alreadyFilled(allRows, context);
    }
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

}