import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/chat_list.dart';
import 'package:flutter/material.dart';
final dbHelper = DatabaseHelper.instance;

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, top: 60, bottom: 0),
            child: Text(
              'Messages',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          new Expanded(child:  ChatList(),
          ),
        ],
      ),
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