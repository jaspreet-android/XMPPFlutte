import 'package:xmpp_sdk/base/elements/stanzas/MessageStanza.dart';

abstract class MessagesListener {
  void onNewMessage(MessageStanza message);
}
