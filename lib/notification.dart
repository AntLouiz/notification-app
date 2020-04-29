import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Notification {

  String title;
  String body;
  bool isActive = true;
  bool isChecked = false;

  Notification({this.title, this.body, this.isActive, this.isChecked});
}


class NotificationDB {
  Future<Database> database;

  Future<void> open() async {
    this.database = openDatabase(
      join(await getDatabasesPath(), 'notifications.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE notifications("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "title TEXT NOT NULL,"
          "body TEXT NOT NULL,"
          "isActive BOOLEAN DEFAULT 1,"
          "isChecked BOOLEAN DEFAULT 0"
        );
      },
      version: 1
    );
  }
}