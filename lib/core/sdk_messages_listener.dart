import 'package:xmpp_sdk/base/chat/Message.dart';
import 'package:xmpp_sdk/base/elements/XmppAttribute.dart';
import 'package:xmpp_sdk/base/elements/XmppElement.dart';
import 'package:xmpp_sdk/base/elements/stanzas/AbstractStanza.dart';
import 'package:xmpp_sdk/base/elements/stanzas/MessageStanza.dart';
import 'package:xmpp_sdk/base/messages/MessageHandler.dart';
import 'package:xmpp_sdk/base/messages/MessagesListener.dart';
import 'package:xmpp_sdk/base/logger/Log.dart';
import 'package:xmpp_sdk/core/constants.dart';
import 'package:xmpp_sdk/core/xmpp_connection.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/listeners/message_lestener.dart';

class SdkMessagesListener implements MessagesListener {

  final String TAG = 'SdkMessagesListener';
  final dbHelper = DatabaseHelper.instance;
  UIMessageListener _UiMessageListener;


  SdkMessagesListener(){
    var messageHandler = MessageHandler.getInstance(XMPPConnection.connection);
    messageHandler.messagesStream.listen(onNewMessage);
  }

  @override
  void onNewMessage(MessageStanza message) {
    if (message.body != null) {
      List<XmppElement>  list = message.children;

      list.forEach((XmppElement element) {
        var name =element.name;
        var nameSpace =  element.getNameSpace();

        //xep 0184
        // <message
        // from='kingrichard@royalty.england.lit/throne'
        // id='bi29sg183b4v'
        // to='northumberland@shakespeare.lit/westminster'>
        // <received xmlns='urn:xmpp:receipts' id='richard2-4.1.247'/>
        // </message>
        if(name == Constants.REQUEST && nameSpace == Constants.RECEIPTS_XMLNS){
          var stanza = MessageStanza(AbstractStanza.getRandomId(), MessageStanzaType.CHAT);
          stanza.toJid = message.fromJid;
          XmppElement element = XmppElement();
          element.name = Constants.RECEIVED;
          element.addAttribute(XmppAttribute('xmlns', Constants.RECEIPTS_XMLNS));
          element.addAttribute(XmppAttribute('id', message.id));
          stanza.addChild(element);
          XMPPConnection.connection.writeStanza(stanza);
        }

      });



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

  addCallback(UIMessageListener UiMessageListener) {
    _UiMessageListener = UiMessageListener;
  }

}