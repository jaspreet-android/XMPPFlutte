import 'package:intl/intl.dart';

class DateUtil{

 static String showRecentMessageTime(int time){
    final now = DateTime.now();
    final messageTime = DateTime.fromMillisecondsSinceEpoch(time);
    if(messageTime.day == now.day) {
      return 'today, ' +  DateFormat('Hms').format(messageTime);
    } else if(messageTime == now.day - 1) {
      return 'yesterday, '+  DateFormat('Hms').format(messageTime);
    } else {
      return DateFormat('EE, d MMM, yyyy').format(messageTime);
    }
  }

 static String showChatDetailMessageTime(int time){
   final now = DateTime.now();
   final messageTime = DateTime.fromMillisecondsSinceEpoch(time);
   if(messageTime.day == now.day) {
     return 'today, ' +  DateFormat('Hms').format(messageTime);
   } else if(messageTime == now.day - 1) {
     return 'yesterday, '+  DateFormat('Hms').format(messageTime);
   } else {
     return DateFormat('EE, d MMM, yyyy').format(messageTime);
   }
 }
}