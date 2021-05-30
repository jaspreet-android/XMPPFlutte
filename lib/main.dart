// @dart=2.9
import 'package:xmpp_sdk/xmpp/SdkConnectionStateChangedListener.dart';
import 'package:xmpp_sdk/src/Connection.dart';
import 'package:xmpp_sdk/src/account/XmppAccountSettings.dart';
import 'package:xmpp_sdk/src/logger/Log.dart';
import 'package:xmpp_sdk/xmpp/SdkMessagesListener.dart';
import 'package:xmpp_sdk/xmpp/xmpp_stone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:xmpp_sdk/ui/chat_list.dart';
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
      onLogin: (LoginData data){
        connectXMPP(data,context);
      },

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


  Future<String> connectXMPP(LoginData data, BuildContext context) async {
    Log.logLevel = LogLevel.DEBUG;
    Log.logXmpp = true;
    var host = "192.168.29.7";
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
    return "connected";
  }

}

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('LOG: Let\'s write a new message');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pink, // or use Color(0xfffe64cf)
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, top: 60, bottom: 20),
            child: Text(
              'Settings',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, top: 0, bottom: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Show activity',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Choose whether you would like to show other users when you are online',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  height: 1.1),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: true,
                        onChanged: (bool newValue) {},
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Use WiFi only',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Choose whether you use WiFi explicity',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  height: 1.1),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: true,
                        onChanged: (bool newValue) {},
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Beta',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Join the beta program to test out the latest version of the app before release ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  height: 1.1),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: true,
                        onChanged: (bool newValue) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 20, top: 60, bottom: 20),
        child: Text(
          'Profile',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Tabs with bottom navigation courtesy of https://github.com/pedromassango/flutter-bottomAppBar/blob/master/lib/tabs_sample.dart
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  List<Widget> _tabList = [
    MessagesPage(),
    ProfilePage(),
    SettingsPage(),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabList.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: _tabList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[400],
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: (currentIndex) {
          setState(() {
            _currentIndex = currentIndex;
          });

          _tabController.animateTo(_currentIndex);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text('', style: TextStyle(height: 0)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            title: Text('', style: TextStyle(height: 0)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('', style: TextStyle(height: 0)),
          ),
        ],
      ),
    );
  }
}