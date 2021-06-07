import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xmpp_sdk/base/elements/XmppAttribute.dart';
import 'package:xmpp_sdk/base/elements/stanzas/IqStanza.dart';
import 'package:xmpp_sdk/base/roster/Buddy.dart';
import 'package:xmpp_sdk/base/roster/RosterManager.dart';
import 'package:xmpp_sdk/core/constants.dart';
import 'package:xmpp_sdk/base/Connection.dart';
import 'package:xmpp_sdk/base/account/XmppAccountSettings.dart';
import 'package:xmpp_sdk/core/sdk_packet_listener.dart';
import 'package:xmpp_sdk/core/xmpp_stone.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/home_page.dart';
import 'package:xmpp_sdk/ui/listeners/message_listener.dart';
import 'package:xmpp_sdk/ui/login_page.dart';
final String TAG = 'XmppConnection';


class XMPPConnection implements ConnectionStateChangedListener{


  static final HOST = "192.168.29.16";
  static final PORT = 5222;
  static final DOMAIN =  "localhost";
  static final RESOURCE = 'scrambleapps';

  static Connection connection;
  static SdkPacketListener messageListener;
  static String currentChat;
  static String atHost ;

  XMPPConnection._privateConstructor();
  static final XMPPConnection instance = XMPPConnection._privateConstructor();

  BuildContext _context;

  Future<void> loginWithAccount(XmppAccountSettings account, BuildContext context) async {
    connection = Connection(account);
    connection.connectionStateStream.listen(onConnectionStateChanged);
    messageListener = SdkPacketListener();
    connection.connect();
    var rosterManager = RosterManager.getInstance(connection);
    rosterManager.rosterStream.listen((List<Buddy> buddies) {
      buddies.forEach((Buddy buddy) {
        Map<String, dynamic> row = {
          DatabaseHelper.presence_name: buddy.name,
          DatabaseHelper.username: buddy.jid.local
        };
        dbHelper.insert(DatabaseHelper.contact_table, row);
      });
    });
  }

  Future<void> login(String host, int port, String username, String domain,
      String password, String resource, BuildContext context) async {
    _context = context;
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
    loginWithAccount(account, context);
  }


  Future<void> register(String host, int port, String username, String domain,
      String password, String resource, BuildContext context) async {
    Log.logLevel = LogLevel.DEBUG;
    Log.logXmpp = true;
    _context = context;
    atHost = "@" + domain;
    var userAtDomain = username + atHost;
    Log.d(TAG, userAtDomain);
    var jid = Jid.fromFullJid(userAtDomain);
    print('connecting...');
    var account = XmppAccountSettings(
        userAtDomain, jid.local, domain, password, port, resource: resource,
        host: host);
    connection = Connection(account);
    connection.needToRegister = true;
    connection.connect();
    connection.inStanzasStream.listen(_processStanza);
    connection.connectionStateStream.listen(onConnectionStateChanged);
    messageListener = SdkPacketListener();
  }

  void doRoute(page) {
    if(_context == null)
      return;
    Navigator.pop(_context);
    print('move to home page');
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (_context) => page),
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

  //  xep 0077

  // <iq from='localhost' id='IFXERYECV' type='result'><query xmlns='jabber:iq:register'>
  // <username>jaspreet_4</username>
  // <password>9319396142</password>
  // </query></iq>
  void _processStanza(AbstractStanza stanza) async {
    if (stanza is IqStanza) {
      if (stanza.type == IqStanzaType.RESULT) {
        XmppElement query =  stanza.getChild('query');
        if(query !=null && query.getAttribute('xmlns').value == Constants.REGISTER_XMLNS){
          ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
            content: Text("User Registered"),
            duration: const Duration(seconds: 10),
          ));
          connection.needToRegister = false;
        }
      }
    }
  }

  @override
  void onConnectionStateChanged(XmppConnectionState state) async {
    if (state == XmppConnectionState.Ready) {
      print('Ready');
      if (connection.needToRegister) {
        ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
          content: Text("User Already taken"),
          duration: const Duration(seconds: 5),
        ));
        connection.needToRegister = true;
      } else {
        XmppAccountSettings accountSettings = connection.account;
        Map<String, dynamic> row = {
          DatabaseHelper.username: accountSettings.username,
          DatabaseHelper.password: accountSettings.password,
          DatabaseHelper.domain: accountSettings.domain,
          DatabaseHelper.host: accountSettings.host,
          DatabaseHelper.port: accountSettings.port.toString(),
          DatabaseHelper.resource: accountSettings.resource
        };
        int inserted = await dbHelper.insert(DatabaseHelper.account_table, row);
        if (inserted == 1) {
          print('account saved');
          doRoute(MyHomePage());
        }
      }
    } else if (state == XmppConnectionState.Reconnecting) {
      print('Reconnecting');
    } else if (state == XmppConnectionState.Authenticated) {
      print('Authenticated');
    } else if (state == XmppConnectionState.AuthenticationFailure) {
      print('AuthenticationFailure');
    } else if (state == XmppConnectionState.Closed) {
      print('Closed');
        if(_context !=null) {
          print('context was not null..');
          ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
            content: Text(connection.needToRegister?"Registration failed": "Login Failed"),
            duration: const Duration(seconds: 5),
          ));
        }
      if (connection.needToRegister) {
        connection.needToRegister = true;
      }
      doRoute(LoginPage());
    } else if (state == XmppConnectionState.Idle) {
      print('Idle');
    } else if (state == XmppConnectionState.Authenticating) {
      print('Authenticating');
    } else if (state == XmppConnectionState.AuthenticationNotSupported) {
      print('AuthenticationNotSupported');
    } else if (state == XmppConnectionState.Resumed) {
      print('Resumed');
    } else if (state == XmppConnectionState.Closing) {
      print('Closing');
    } else if (state == XmppConnectionState.DoneParsingFeatures) {
      print('DoneParsingFeatures');
    } else if (state == XmppConnectionState.ForcefullyClosed) {
      print('ForcefullyClosed');
    } else if (state == XmppConnectionState.SocketOpened) {
      print('SocketOpened');
    } else if (state == XmppConnectionState.PlainAuthentication) {
      print('PlainAuthentication');
    } else if (state == XmppConnectionState.SessionInitialized) {
      print('SessionInitialized');
    } else if (state == XmppConnectionState.SocketOpening) {
      print('SocketOpening');
    } else if (state == XmppConnectionState.StartTlsFailed) {
      print('StartTlsFailed');
    } else if (state == XmppConnectionState.WouldLikeToClose) {
      print('WouldLikeToClose');
    } else if (state == XmppConnectionState.WouldLikeToOpen) {
      print('WouldLikeToOpen');
    }
  }
}