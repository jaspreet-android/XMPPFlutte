import 'package:xmpp_sdk/src/elements/stanzas/AbstractStanza.dart';

abstract class StanzaProcessor {
  void processStanza(AbstractStanza stanza);
}
