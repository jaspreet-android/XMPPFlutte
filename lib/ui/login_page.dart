import 'package:xmpp_sdk/core/SdkConnectionStateChangedListener.dart';
import 'package:xmpp_sdk/base/Connection.dart';
import 'package:xmpp_sdk/base/account/XmppAccountSettings.dart';
import 'package:xmpp_sdk/base/logger/Log.dart';
import 'package:xmpp_sdk/core/SdkMessagesListener.dart';
import 'package:xmpp_sdk/core/xmpp_stone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/home_page.dart';

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
    var host = "192.168.29.8";
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
    SdkConnectionStateChangedListener(connection, messagesListener, context);
    var rosterManager = RosterManager.getInstance(connection);
    rosterManager.rosterStream.listen((List<Buddy> buddies) {
      buddies.forEach((Buddy buddy) {
        Map<String, dynamic> row = {
          DatabaseHelper.presenceName : buddy.name,
          DatabaseHelper.username  : buddy.jid.local
        };
        dbHelper.insert(row);
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_context) => MyHomePage()),
      );
    });
  }

}