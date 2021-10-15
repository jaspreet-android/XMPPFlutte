//xep 0085

class Constants {


  static final HOST = "192.168.29.8";
  static final PORT = 5222;
  static final DOMAIN = "localhost";
  static final RESOURCE = 'scrambleapps';
  static final AT_DOMAIN = "@" + DOMAIN;
  static final AT_MUC_LIGHT_DOMAIN = "@" + "muclight." + DOMAIN;

  static final String DEFAULT_IMAGE = 'https://i.stack.imgur.com/l60Hf.png';

  //xep 0184
  static final REQUEST = "request";
  static final RECEIVED = "received";
  static final ID = "id";
  static final RECEIPTS_XMLNS = "urn:xmpp:receipts";

  //xep 0085
  static final ACTIVE = "active";
  static final INACTIVE = "inactive";
  static final GONE = "gone";
  static final COMPOSING = "composing";
  static final PAUSED = "paused";
  static final CHAT_STATES_XMLNS = "http://jabber.org/protocol/chatstates";

  // XEP 0077
  static final REGISTER_XMLNS = "jabber:iq:register";


  // XEP-xxxx: Multi-User Chat Light
  static final CONFIGURATION = "configuration";
  static final ROOM_NAME = "roomname";
  static final OCCUPANTS = "occupants";
  static final SUBJECT = "subject";
  static final AFFILIATION = "affiliation";
  static final USER = "user";
  static final MEMBER = "member";
  static final MUC_LIGHT_CREATE_XMLNS= "urn:xmpp:muclight:0#create";

}