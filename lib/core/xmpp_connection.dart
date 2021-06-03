import 'package:flutter/material.dart';
import 'package:xmpp_sdk/base/roster/Buddy.dart';
import 'package:xmpp_sdk/base/roster/RosterManager.dart';
import 'package:xmpp_sdk/core/sdk_connection_listener.dart';
import 'package:xmpp_sdk/base/Connection.dart';
import 'package:xmpp_sdk/base/account/XmppAccountSettings.dart';
import 'package:xmpp_sdk/core/sdk_messages_listener.dart';
import 'package:xmpp_sdk/core/xmpp_stone.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/home_page.dart';

final String TAG = 'XmppConnection';


class XMPPConnection {

  static var connection;
  static SdkMessagesListener messageListener;

  Future<void> login(String host, int port, String username, String domain,
      String password, String resource, BuildContext context) async {
    Log.logLevel = LogLevel.DEBUG;
    Log.logXmpp = true;
    var userAtDomain = username + "@" + domain;
    Log.d(TAG, userAtDomain);
    var jid = Jid.fromFullJid(userAtDomain);
    print('connecting...');
    var account = XmppAccountSettings(
        userAtDomain, jid.local, domain, password, port, resource: resource,
        host: host);
    connection = Connection(account);
    connection.connect();
    messageListener = SdkMessagesListener();
    SdkConnectionStateChangedListener();
    var rosterManager = RosterManager.getInstance(connection);
    rosterManager.rosterStream.listen((List<Buddy> buddies) {
      buddies.forEach((Buddy buddy) {
        Map<String, dynamic> row = {
          DatabaseHelper.presence_name: buddy.name,
          DatabaseHelper.username: buddy.jid.local
        };
        dbHelper.insert(DatabaseHelper.contact_table, row);
      });
      if (context != null) {
        doRoute(context);
      }
    });
  }

  void doRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_context) => MyHomePage()),
    );
  }
}