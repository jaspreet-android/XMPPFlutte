import 'package:xmpp_sdk/src/roster/Buddy.dart';

abstract class RosterListener {
  void onRosterListChanged(List<Buddy> roster);
}
