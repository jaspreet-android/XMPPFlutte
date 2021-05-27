// @dart=2.9
import 'package:xmpp_sdk/xmpp/SdkConnectionStateChangedListener.dart';
import 'package:xmpp_sdk/src/Connection.dart';
import 'package:xmpp_sdk/src/account/XmppAccountSettings.dart';
import 'package:xmpp_sdk/src/logger/Log.dart';
import 'package:xmpp_sdk/xmpp/SdkMessagesListener.dart';
import 'package:xmpp_sdk/xmpp/xmpp_stone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
void main() {
  runApp(XMPPSdk());
}

final String TAG = 'Main';

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

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'XMPP Loin',
      onSubmitAnimationCompleted: ()  {
      },
      hideForgotPasswordButton: true,
      hideSignUpButton: true,
      onLogin: connectXMPP,

      emailValidator: (String arg) {
        if (arg.length < 8)
          return 'Username must be more than 8 charater';
        else
          return null;
      },

      messages: LoginMessages(
        usernameHint: 'Username',
        passwordHint: 'Pass',
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


  Future<String> connectXMPP(LoginData data) async {
    Log.logLevel = LogLevel.DEBUG;
    Log.logXmpp = true;
    var host = "localhost";
    var port = 5222;
    var username = data.name;
    var domain = "localhost";
    var password = data.password;
    var userAtDomain = username + "@" + domain;
    Log.d(TAG, userAtDomain);
    var jid = Jid.fromFullJid(userAtDomain);
    print('connecting...');
    var account = XmppAccountSettings(userAtDomain, jid.local, domain, password, port, resource: 'scrambleapps',host: host);
    var connection = Connection(account);
    connection.connect();
    MessagesListener messagesListener = SdkMessagesListener();
    SdkConnectionStateChangedListener(connection, messagesListener);

    return "connected";
  }

}