import 'package:xmpp_sdk/base/elements/XmppAttribute.dart';
import 'package:xmpp_sdk/base/elements/XmppElement.dart';
import 'package:xmpp_sdk/base/elements/stanzas/AbstractStanza.dart';
import 'package:xmpp_sdk/base/elements/stanzas/IqStanza.dart';
import 'package:xmpp_sdk/base/elements/stanzas/MessageStanza.dart';
import 'package:xmpp_sdk/base/features/streammanagement/StreamManagmentModule.dart';
import 'package:xmpp_sdk/base/messages/MessageHandler.dart';
import 'package:xmpp_sdk/base/messages/MessagesListener.dart';
import 'package:xmpp_sdk/base/logger/Log.dart';
import 'package:xmpp_sdk/core/constants.dart';
import 'package:xmpp_sdk/core/xmpp_connection.dart';
import 'package:xmpp_sdk/core/xmpp_stone.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/listeners/message_listener.dart';
import 'package:xmpp_sdk/ui/listeners/statue_listener.dart';

class SdkPacketListener implements MessagesListener {

  final String TAG = 'SdkMessagesListener';
  final dbHelper = DatabaseHelper.instance;
  List<UIMessageListener> _UiMessageListeners = List<UIMessageListener>();
  List<UIStatusListener> _UiStatusListeners = List<UIStatusListener>();

  SdkPacketListener(){
    var messageHandler = MessageHandler.getInstance(XMPPConnection.connection);
    messageHandler.messagesStream.listen(onNewMessage);
    var presenceManager = PresenceManager.getInstance(XMPPConnection.connection);
    presenceManager.presenceStream.listen(onPresence);
  }

  @override
  void onNewMessage(MessageStanza message) {

    int delivered =0;
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
        XmppElement elementToBeSent = XmppElement();
        elementToBeSent.name = Constants.RECEIVED;
        elementToBeSent.addAttribute(XmppAttribute('xmlns', Constants.RECEIPTS_XMLNS));
        elementToBeSent.addAttribute(XmppAttribute('id', message.id));
        stanza.addChild(elementToBeSent);
        XMPPConnection.connection.writeStanza(stanza);
        delivered = 1;
      }

      //xep 0184
      // <message id="aac2a" to="jaspreet_2@localhost/scrambleapps">
      // <received xmlns="urn:xmpp:receipts" id="FORJMGFEY"/>
      // </message>

      if(name == Constants.RECEIVED && nameSpace == Constants.RECEIPTS_XMLNS){
        String receivedId = element.getAttribute(Constants.ID).value;
        dbHelper.updateDelivered(receivedId);
        updateChatUI();
        return;
      }

      // xep 0085
      // <message type="chat" id="abb6a" to="jaspreet_2@localhost/scrambleapps">
      // <body>dsdsddsdsds</body>
      // <active xmlns="http://jabber.org/protocol/chatstates"/>
      // <request xmlns="urn:xmpp:receipts"/>
      // </message>

      if(nameSpace == Constants.CHAT_STATES_XMLNS){
        dbHelper.updateChatState(name,message.fromJid.local);
        updateStatusUI(name);
        if(name == Constants.COMPOSING || name == Constants.PAUSED) {
          updateChatUI();
        }
      }


    });


    if (message.body != null) {
      Log.d(TAG, message.body);
      dbHelper.createMessage(message,delivered);
      updateChatUI();
    }
  }


  updateChatUI(){
    _UiMessageListeners.forEach((_UiMessageListener) {
      _UiMessageListener.refresh();
    });
  }

  updateStatusUI(String status){
    _UiStatusListeners.forEach((_UiMessageListener) {
      _UiMessageListener.updateStatus(status);
    });
  }

  removeMessageCallback(UIMessageListener uiMessageListener){
    _UiMessageListeners.remove(uiMessageListener);
  }

  addMessageCallback(UIMessageListener uiMessageListener) {
    _UiMessageListeners.add(uiMessageListener);
  }


  removeStatusCallback(UIStatusListener uiStatusListener){
    _UiStatusListeners.remove(uiStatusListener);
  }

  addStatusCallback(UIStatusListener uiStatusListener) {
    _UiStatusListeners.add(uiStatusListener);
  }

  void onPresence(PresenceData event) {
    print( 'presence Event from ' + event.jid.fullJid + ' PRESENCE: ' + event.showElement.toString());
    dbHelper.updateChatState(event.status == null? Constants.ACTIVE: Constants.INACTIVE, event.jid.local );
    updateStatusUI(event.showElement.toString());
    updateChatUI();
  }

}