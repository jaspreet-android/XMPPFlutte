import 'package:xmpp_sdk/src/elements/stanzas/MessageStanza.dart';

abstract class MessagesListener {
  void onNewMessage(MessageStanza message);
}
