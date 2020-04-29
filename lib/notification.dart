import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Notification {

  int id;
  String title;
  String body;
  bool isActive = true;
  bool isChecked = false;

  Notification({this.title, this.body, this.isActive=true, this.isChecked=false});

  Notification.withId({this.id, this.title, this.body, this.isActive=true, this.isChecked=false});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'title': this.title,
      'body': this.body,
      'isActive': this.isActive? 1: 0,
      'isChecked': this.isChecked? 1: 0
    };
    if (this.id != null) {
      map['id'] = this.id;
    }

    return map;
  }
}


class NotificationDB {
  Future<Database> database;

  Future<void> open() async {
    print(join(await getDatabasesPath(), 'notifications.db'));
    this.database = openDatabase(
      join(await getDatabasesPath(), 'notifications.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE notifications ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "title TEXT NOT NULL,"
          "body TEXT NOT NULL,"
          "isActive BOOLEAN DEFAULT 1,"
          "isChecked BOOLEAN DEFAULT 0"
          ")",
        );
      },
      version: 1
    );
  }

  Future<void> insertNotification(Notification notification) async {
    Database db = await this.database;

    await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> close() async {
    Database db = await this.database;

    db.close();
  }


  Future<List> listNotifications() async {
    Database db = await this.database;

    List<Map<String, dynamic>> maps = await db.query('notifications');

    return List.generate(maps.length, (i) { return Notification.withId(
      id: maps[i]['id'],
      title: maps[i]['title'],
      body: maps[i]['body']
      );
    });
  }

  Future<void> deleteNotification(int id) async {
    Database db = await this.database;

    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

}