import 'package:xmpp_sdk/base/elements/stanzas/MessageStanza.dart';
import 'package:xmpp_sdk/base/messages/MessagesListener.dart';
import 'package:xmpp_sdk/base/logger/Log.dart';

class SdkMessagesListener implements MessagesListener {

  final String TAG = 'SdkMessagesListener';

  @override
  void onNewMessage(MessageStanza message) {
    if (message.body != null) {
      Log.d(TAG, message.body);
    }
  }
}