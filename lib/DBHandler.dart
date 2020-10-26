import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/* Database handler class: Handles storing of the pending posts uploaded by the user when when user is offline */

class DBProvider {
  DBProvider._();

  //Object creation to follow the Singleton pattern
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = "${documentsDirectory.path}/TestDB.db";
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE PendingPosts ("
          "image TEXT,"
          "posttext TEXT,"
          "hashtags TEXT"
          ")");
    });
  }

  //Stores new post to the file when the device is offline
  Future<int> newPost(String image, String postText, String hashTags) async {
    final db = await database;
    var res = await db
        .rawInsert("INSERT Into PendingPosts (image, posttext, hashtags)"
            " VALUES (\'${image}\',\'${postText}\',\'${hashTags}\')");
    return res;
  }

  //Reads the pending posts from the SQLite database
  getPendingPosts() async {
    print("Getting pending posts");
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM PendingPosts");
    List<Map<String, dynamic>> result = res;
    return result;
  }

  //Deletes all the posts from the SQLite database once they have been uploaded
  deleteAll() async {
    final db = await database;
    return db.rawDelete("Delete from PendingPosts");
  }
}
