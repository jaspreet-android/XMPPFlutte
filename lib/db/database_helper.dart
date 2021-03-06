import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xmpp_sdk/base/elements/stanzas/MessageStanza.dart';
import 'package:xmpp_sdk/core/cashe/cache_utils.dart';
import 'package:xmpp_sdk/core/constants.dart';
import 'package:xmpp_sdk/core/xmpp_connection.dart';

class DatabaseHelper {

  static final _databaseName = "xmpp.db";
  static final _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }


  static final contact_table = 'contacts';
  static final account_table = 'accounts';
  static final messages_table = 'messages';

  static final presence_name = 'presence_name';
  static final username = 'username';
  static final password = 'password';
  static final domain = 'domain';
  static final host = 'host';
  static final port = 'port';
  static final resource = 'resource';
  static final message_id = 'message_id';
  static final sender_username = 'sender_username';
  static final receiver_username = 'receiver_username';
  static final content = 'content';
  static final chat_username = 'chat_username';
  static final type = 'type';
  static final received_time = 'received_time';
  static final is_sent = 'is_sent';
  static final is_delivered = 'is_delivered';
  static final is_displayed = 'is_displayed';
  static final user_image = 'user_image';
  static final chat_state = 'chat_state';

  static final CREATE_CONTACT_TABLE = "CREATE TABLE $contact_table "
                                      "($presence_name TEXT ,"
                                      "$user_image TEXT DEFAULT '' ,"
                                      "$chat_state TEXT DEFAULT '"+Constants.INACTIVE+"' ,"
                                      "$username TEXT PRIMARY KEY)";


  static final CREATE_ACCOUNT_TABLE = "CREATE TABLE $account_table "
                                      "($username TEXT not null ,"
                                       "$password TEXT not null ,"
                                       "$domain TEXT not null ,"
                                       "$port TEXT not null ,"
                                       "$host TEXT not null ,"
                                       "$resource TEXT not null ,"
                                       "PRIMARY KEY($username,$domain))";

  static final CREATE_MESSAGE_TABLE = "CREATE TABLE $messages_table "
      "($message_id TEXT not null ,"
      "$sender_username TEXT not null ,"
      "$receiver_username TEXT not null ,"
      "$content TEXT not null ,"
      "$chat_username TEXT not null ,"
      "$type INTEGER DEFAULT 1,"
      "$received_time  NUMBER , "
      "$is_sent INTEGER DEFAULT 0 ,"
      "$is_delivered INTEGER DEFAULT 0 ,"
      "$is_displayed INTEGER DEFAULT 0 ,"
      "PRIMARY KEY($message_id))";

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('$CREATE_CONTACT_TABLE');
    await db.execute('$CREATE_ACCOUNT_TABLE');
    await db.execute('$CREATE_MESSAGE_TABLE');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(table,Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row,conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> createMessage(MessageStanza message, int delivered) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> row = {
      message_id: message.id,
      content: message.body,
      sender_username: message.fromJid.local,
      receiver_username: message.toJid.local,
      chat_username: message.fromJid.local,
      received_time: DateTime.now().millisecondsSinceEpoch,
      is_sent: 1,
      is_delivered: delivered,
      is_displayed: 0
    };
    insert(messages_table, row);
    List<Map<String, dynamic>> lastChats = await CacheUtil.lastChats;
    bool found = false;
    lastChats.forEach((Map<String, dynamic> userLastChat) {
      if (userLastChat[chat_username] == message.fromJid.local) {
          print('cache updated');
          userLastChat[content] = message.body;
          userLastChat['unread_count'] = userLastChat['unread_count'] + 1;
          lastChats.remove(userLastChat);
          lastChats.insert(0, userLastChat);
          found = true;
          return;
      }
    });

    if(found){
      return;
    }
    CacheUtil.createLastChatsCache(message.fromJid.local, 'https://i.stack.imgur.com/l60Hf.png', Constants.INACTIVE, content, 1,time);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount(table) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(table,int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$username = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getLastCachedChats() async {
    if (CacheUtil.lastChats != null) {
      CacheUtil.needToCacheFromUI = false;
      print('lastChats = ' + CacheUtil.lastChats.toString());
      return CacheUtil.lastChats;
    }
    CacheUtil.lastChats ;
    return getLastChats();
  }

  Future<List<Map<String, dynamic>>> getLastChats() async {
    List<Map<String, dynamic>> unread = await getLastChatsUnread();
    String userNames ='';
    unread.forEach((element) {
      var user = element[chat_username];
      userNames += ',\'$user\'';
    });
    String finalUserNames= userNames.length >0 ?userNames.substring(1,userNames.length):'';
    List<Map<String, dynamic>> read = await getLastChatsRead(finalUserNames);
    List<Map<String, dynamic>> newList = new List.from(unread)..addAll(read);
    return newList;
  }

  Future<List<Map<String, dynamic>>> getLastChatsUnread() async {
    Database db = await instance.database;
    var q = 'SELECT '
              'count($messages_table.$is_displayed) as unread_count, '
              '$messages_table.$content, '
              '$messages_table.$received_time, '
              '$messages_table.$chat_username, '
              '$contact_table.$chat_state, '
              '$contact_table.$user_image '
            'FROM $contact_table '
            'INNER JOIN $messages_table '
            'ON $contact_table.$username = $messages_table.$chat_username '
            'WHERE $messages_table.$is_displayed =0 '
            'GROUP BY $messages_table.$chat_username having max($messages_table.$received_time) '
            'ORDER BY $messages_table.$received_time DESC';

    print(q);
    return await db.rawQuery(q);
  }

  Future<List<Map<String, dynamic>>> getLastChatsRead(userNames) async {
    Database db = await instance.database;
    var q = 'SELECT 0 as unread_count, '
              '$messages_table.$content, '
              '$messages_table.$received_time, '
              '$messages_table.$chat_username, '
              '$contact_table.$chat_state, '
              '$contact_table.$user_image '
            'FROM $messages_table '
            'INNER JOIN  $contact_table '
            'ON $messages_table.$chat_username  = $contact_table.$username '
            'WHERE $messages_table.$is_displayed =1 and $messages_table.$chat_username  not in ($userNames) '
            'GROUP BY $messages_table.$chat_username having max($messages_table.$received_time) '
            'ORDER BY $messages_table.$received_time DESC';

    print(q);
    return await db.rawQuery(q);
  }

  Future<List<Map<String, dynamic>>> getCurrentChatDetail() async {
    Database db = await instance.database;
    var currentChat = XMPPConnection.currentChat;
    var q1 = 'UPDATE $messages_table set $is_displayed = 1 where $chat_username = \'$currentChat\'';
    print(q1);
    db.rawQuery(q1);
    List<Map<String, dynamic>> lastChats = await CacheUtil.lastChats;
    if(lastChats != null) {
      lastChats.forEach((Map<String, dynamic> userLastChat) {
        if (userLastChat[chat_username] == XMPPConnection.currentChat) {
          print('cache updated');
          userLastChat['unread_count'] = 0;
          return;
        }
      });
    }
    var q2 = 'SELECT * '
        'FROM $contact_table '
        'INNER JOIN $messages_table '
        'ON $contact_table.$username = $messages_table.$chat_username '
        'WHERE $messages_table.$chat_username =  \'$currentChat\' '
        'ORDER BY $messages_table.$received_time';

    print(q2);
    return await db.rawQuery(q2);
  }

  Future<void> updateDelivered(String messageId) async {
    Database db = await instance.database;
    var q = 'UPDATE $messages_table set $is_delivered = 1 where $message_id = \'$messageId\'';
    print(q);
    db.rawQuery(q);
  }

  Future<void> updateSent(String messageId) async {
    Database db = await instance.database;
    var q = 'UPDATE $messages_table set $is_sent = 1 where $message_id = \'$messageId\'';
    print(q);
    db.rawQuery(q);
  }

  Future<void> updateChatState(String state, String username) async {
    Database db = await instance.database;
    var q = 'UPDATE $contact_table set $chat_state = \'$state\'  where username = \'$username\'';
    print(q);
    db.rawQuery(q);
    if(CacheUtil.lastChats == null)
      return;
    List<Map<String, dynamic>> lastChats = await CacheUtil.lastChats;
    lastChats.forEach((Map<String, dynamic> userLastChat) {
      if (userLastChat[chat_username] == username) {
        print('cache updated');
        userLastChat[chat_state] = state;
        return;
      }
    });
  }


}