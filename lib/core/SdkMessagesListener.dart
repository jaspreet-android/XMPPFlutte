import 'package:flutter/cupertino.dart';
import 'package:xmpp_sdk/base/Connection.dart';
import 'package:xmpp_sdk/base/elements/stanzas/MessageStanza.dart';
import 'package:xmpp_sdk/base/messages/MessageHandler.dart';
import 'package:xmpp_sdk/base/messages/MessagesListener.dart';
import 'package:xmpp_sdk/base/logger/Log.dart';
import 'package:xmpp_sdk/core/global.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/listeners/message_lestener.dart';

class SdkMessagesListener implements MessagesListener {

  final String TAG = 'SdkMessagesListener';
  final dbHelper = DatabaseHelper.instance;
  UIMessageListener _UiMessageListener;


  SdkMessagesListener(UIMessageListener UiMessageListener) {
    _UiMessageListener = UiMessageListener;
    var messageHandler = MessageHandler.getInstance(Global.connection);
    messageHandler.messagesStream.listen(onNewMessage);
  }

  @override
  void onNewMessage(MessageStanza message) {
    if (message.body != null) {
      Log.d(TAG, message.body);
      Map<String, dynamic> row = {
        DatabaseHelper.message_id : message.id,
        DatabaseHelper.content : message.body,
        DatabaseHelper.sender_username  : message.fromJid.local,
        DatabaseHelper.receiver_username  : message.toJid.local,
        DatabaseHelper.chat_username  : message.fromJid.local,
        DatabaseHelper.received_time  : DateTime.now().millisecondsSinceEpoch,
        DatabaseHelper.is_sent  : 1,
        DatabaseHelper.is_delivered  : 0,
        DatabaseHelper.is_displayed  : 0
      };
      dbHelper.insert(DatabaseHelper.messages_table,row);
      if(_UiMessageListener!=null) {
        _UiMessageListener.refresh();
      }
    }
  }

  removeCallback(){
    _UiMessageListener =null;
  }

}