import 'package:xmpp_sdk/src/Connection.dart';

abstract class ConnectionStateChangedListener {
  void onConnectionStateChanged(XmppConnectionState state);
}
