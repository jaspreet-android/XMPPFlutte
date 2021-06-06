import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xmpp_sdk/base/elements/XmppAttribute.dart';
import 'package:xmpp_sdk/base/roster/Buddy.dart';
import 'package:xmpp_sdk/base/roster/RosterManager.dart';
import 'package:xmpp_sdk/core/constants.dart';
import 'package:xmpp_sdk/core/sdk_connection_listener.dart';
import 'package:xmpp_sdk/base/Connection.dart';
import 'package:xmpp_sdk/base/account/XmppAccountSettings.dart';
import 'package:xmpp_sdk/core/sdk_packet_listener.dart';
import 'package:xmpp_sdk/core/xmpp_stone.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/home_page.dart';
import 'package:xmpp_sdk/ui/listeners/message_listener.dart';
final String TAG = 'XmppConnection';


class XMPPConnection {

  static Connection connection;
  static SdkPacketListener messageListener;
  static String currentChat;
  static String atHost ;

  XMPPConnection._privateConstructor();
  static final XMPPConnection instance = XMPPConnection._privateConstructor();

  Future<void> login(String host, int port, String username, String domain,
      String password, String resource, BuildContext context) async {
    Log.logLevel = LogLevel.DEBUG;
    Log.logXmpp = true;
    atHost = "@" + domain;
    var userAtDomain = username + atHost;
    Log.d(TAG, userAtDomain);
    var jid = Jid.fromFullJid(userAtDomain);
    print('connecting...');
    var account = XmppAccountSettings(
        userAtDomain, jid.local, domain, password, port, resource: resource,
        host: host);
    connection = Connection(account);
    connection.connect();
    messageListener = SdkPacketListener();
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

  void sendMessageToCurrentChat(String content, UIMessageListener listener) async{
    String messageId = AbstractStanza.getRandomId();
    Map<String, dynamic> row = {
      DatabaseHelper.message_id : messageId,
      DatabaseHelper.content : content,
      DatabaseHelper.sender_username  : connection.account.username,
      DatabaseHelper.receiver_username  : currentChat,
      DatabaseHelper.chat_username  : currentChat,
      DatabaseHelper.received_time  : DateTime.now().millisecondsSinceEpoch,
      DatabaseHelper.is_sent  : 1,
      DatabaseHelper.is_delivered  : 0,
      DatabaseHelper.is_displayed  : 1
    };
    var inserted = await dbHelper.insert(DatabaseHelper.messages_table,row);
    if(inserted ==1){
      listener.refresh();
    }
    var stanza = MessageStanza(messageId, MessageStanzaType.CHAT);
    stanza.toJid = Jid.fromFullJid(XMPPConnection.currentChat+ XMPPConnection.atHost);
    XmppElement requestDelivery = XmppElement();
    requestDelivery.name = Constants.REQUEST;
    requestDelivery.addAttribute(XmppAttribute('xmlns', Constants.RECEIPTS_XMLNS));
    stanza.addChild(requestDelivery);
    XmppElement active = XmppElement();
    active.name = Constants.ACTIVE;
    active.addAttribute(XmppAttribute('xmlns', Constants.CHAT_STATES_XMLNS));
    stanza.addChild(active);
    stanza.body = content;
    XMPPConnection.connection.writeStanza(stanza);
  }

  //xep 0085
  void sendStateToCurrentChat(String chatState) async{
    String messageId = AbstractStanza.getRandomId();
    var stanza = MessageStanza(messageId, MessageStanzaType.CHAT);
    stanza.toJid = Jid.fromFullJid(XMPPConnection.currentChat+ XMPPConnection.atHost);
    XmppElement requestChatStates = XmppElement();
    requestChatStates.name = chatState;
    requestChatStates.addAttribute(XmppAttribute('xmlns', Constants.CHAT_STATES_XMLNS));
    stanza.addChild(requestChatStates);
    XMPPConnection.connection.writeStanza(stanza);
  }

}