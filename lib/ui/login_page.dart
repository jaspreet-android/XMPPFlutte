import 'package:xmpp_sdk/base/logger/Log.dart';
import 'package:xmpp_sdk/core/constants.dart';
import 'package:xmpp_sdk/core/xmpp_stone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:xmpp_sdk/core/xmpp_connection.dart';
import 'package:xmpp_sdk/db/database_helper.dart';

class LoginPage extends StatelessWidget {
  final String TAG = 'LoginPage';
  final dbHelper = DatabaseHelper.instance;
  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'XMPP Loin',
      hideForgotPasswordButton: true,
      hideSignUpButton: false,
      loginAfterSignUp: false,

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
        signUpSuccess: 'Please Wait ... ',
        flushbarTitleSuccess : ' ...',
        forgotPasswordButton: 'Forgot password?',
        recoverPasswordButton: 'HELP ME',
        goBackButton: 'GO BACK',
        confirmPasswordError: 'Not match!',
        recoverPasswordDescription:
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
        recoverPasswordSuccess: 'Password rescued successfully',
      // ignore: missing_return
      ), onRecoverPassword: (String ) {
      // ignore: missing_return
    }, onSignup: (LoginData data ) {
      registerUser(data, context);
      return null;
    },
    );
  }


  Future<void> registerUser(LoginData data, BuildContext context) async {
    Log.logLevel = LogLevel.DEBUG;
    Log.logXmpp = true;
    var host = Constants.HOST;
    var port = Constants.PORT;
    var username = data.name;
    var domain = Constants.DOMAIN;
    var password = data.password;
    var resource = Constants.RESOURCE;
    print('connecting...');
    XMPPConnection.instance.register(host, port, username, domain, password, resource, context);
  }

  Future<void> connectXMPP(LoginData data, BuildContext context) async {
    Log.logLevel = LogLevel.DEBUG;
    Log.logXmpp = true;
    var host = Constants.HOST;
    var port = Constants.PORT;
    var username = data.name;
    var domain = Constants.DOMAIN;
    var password = data.password;
    var resource = Constants.RESOURCE;
    print('connecting...');
    XMPPConnection.instance.login(host, port, username, domain, password, resource, context);
  }

}