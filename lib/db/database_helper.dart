import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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

  static final presence_name = 'presence_name';
  static final username = 'username';
  static final password = 'password';
  static final domain = 'domain';
  static final host = 'host';
  static final port = 'port';
  static final resource = 'resource';

  static final CREATE_CONTACT_TABLE = "CREATE TABLE $contact_table ($presence_name TEXT ,$username TEXT PRIMARY KEY)";


  static final CREATE_ACCOUNT_TABLE = "CREATE TABLE $account_table "
                                      "($username TEXT not null ,"
                                       "$password TEXT not null ,"
                                       "$domain TEXT not null ,"
                                       "$port TEXT not null ,"
                                       "$host TEXT not null ,"
                                       "$resource TEXT not null ,"
                                       "PRIMARY KEY($username,$domain))";

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('$CREATE_CONTACT_TABLE');
    await db.execute('$CREATE_ACCOUNT_TABLE');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(table,Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row,conflictAlgorithm: ConflictAlgorithm.replace);
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

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(table,Map<String, dynamic> row) async {
    Database db = await instance.database;
    String vUsername = row[username];
    return await db.update(table, row, where: '$username = ?', whereArgs: [vUsername]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(table,int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$username = ?', whereArgs: [id]);
  }
}