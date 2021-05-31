import 'package:xmpp_sdk/base/data/Jid.dart';

abstract class MessageApi {
  void sendMessage(Jid to, String text);
}
