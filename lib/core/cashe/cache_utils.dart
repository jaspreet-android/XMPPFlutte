import 'package:xmpp_sdk/db/database_helper.dart';

class CacheUtil {

  static bool needToCacheFromUI = true;
  static Future<List<Map<String, dynamic>>> lastChats ;

  static Map<String, Future<List<Map<String, dynamic>>>> currentUserChats;

  static void createLastChatsCache(String chatUsername, String userImage,
      String chatState, String content, int unreadCount, int time) async {
    Map<String, dynamic> userLastChatNew = Map<String, dynamic>();
    userLastChatNew[DatabaseHelper.chat_username] = chatUsername;
    userLastChatNew[DatabaseHelper.user_image] = userImage;
    userLastChatNew[DatabaseHelper.chat_state] = chatState;
    userLastChatNew[DatabaseHelper.content] = content;
    userLastChatNew['unread_count'] = unreadCount;
    userLastChatNew[DatabaseHelper.received_time] = time;
    if(lastChats == null){
      lastChats = Future(() => List());
    }
    (await lastChats).insert(0,userLastChatNew);
  }
}
