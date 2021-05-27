import 'dart:async';
import 'package:xmpp_sdk/src/Connection.dart';
import 'package:xmpp_sdk/src/ConnectionStateChangedListener.dart';
import 'package:xmpp_sdk/src/logger/Log.dart';
import 'package:xmpp_sdk/src/messages/MessagesListener.dart';
import 'package:xmpp_sdk/src/presence/PresenceApi.dart';
import 'package:xmpp_sdk/xmpp//xmpp_stone.dart';

class SdkConnectionStateChangedListener implements ConnectionStateChangedListener {
  final String TAG = 'SdkConnectionStateChangedListener';
  Connection _connection;
  StreamSubscription<String> subscription;

  SdkConnectionStateChangedListener(Connection connection, MessagesListener messagesListener) {
    _connection = connection;
    _connection.connectionStateStream.listen(onConnectionStateChanged);
  }

  @override
  void onConnectionStateChanged(XmppConnectionState state) {
    if (state == XmppConnectionState.Ready) {
      print('Connected');
      var presenceManager = PresenceManager.getInstance(_connection);
      presenceManager.presenceStream.listen(onPresence);
    } else if (state == XmppConnectionState.Reconnecting) {
      print( 'Reconnecting');
    } else if (state == XmppConnectionState.Authenticated) {
      print( 'Authenticated');
    } else if (state == XmppConnectionState.AuthenticationFailure) {
      print( 'AuthenticationFailure');
    } else if (state == XmppConnectionState.Closed) {
      print( 'Closed');
    } else if (state == XmppConnectionState.Idle) {
      print( 'Idle');
    } else if (state == XmppConnectionState.Authenticating) {
      print( 'Authenticating');
    } else if (state == XmppConnectionState.AuthenticationNotSupported) {
      print( 'AuthenticationNotSupported');
    } else if (state == XmppConnectionState.Resumed) {
      print( 'Resumed');
    } else if (state == XmppConnectionState.Closing) {
      print( 'Closing');
    } else if (state == XmppConnectionState.DoneParsingFeatures) {
      print( 'DoneParsingFeatures');
    } else if (state == XmppConnectionState.ForcefullyClosed) {
      print( 'ForcefullyClosed');
    } else if (state == XmppConnectionState.SocketOpened) {
      print( 'SocketOpened');
    } else if (state == XmppConnectionState.PlainAuthentication) {
      print( 'PlainAuthentication');
    } else if (state == XmppConnectionState.SessionInitialized) {
      print( 'SessionInitialized');
    } else if (state == XmppConnectionState.SocketOpening) {
      print( 'SocketOpening');
    } else if (state == XmppConnectionState.StartTlsFailed) {
      print( 'StartTlsFailed');
    } else if (state == XmppConnectionState.WouldLikeToClose) {
      print( 'WouldLikeToClose');
    } else if (state == XmppConnectionState.WouldLikeToOpen) {
      print( 'WouldLikeToOpen');
    }


  }

  void onPresence(PresenceData event) {
    print( 'presence Event from ' + event.jid.fullJid + ' PRESENCE: ' + event.showElement.toString());
  }
}
