import 'package:xmpp_sdk/src/data/Jid.dart';

abstract class MessageApi {
  void sendMessage(Jid to, String text);
}
