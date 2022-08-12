import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class Birthday {
  double uid;
  String? contactId;
  DateTime date;
  String displayName;
  String? phoneNum;
  int lastYearChecked; // last year when notification was shown
  bool notify;
  Uint8List? photo;

  Birthday(
      {required this.date,
      this.displayName = "",
      this.uid = -1,
      this.contactId,
      this.phoneNum,
      this.notify = true,
      this.lastYearChecked = -1,
      this.photo}) {
    if (uid == -1) {
      uid = Random().nextDouble();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'contactId': contactId,
      'date': date.toString(),
      'displayName': displayName,
      'phoneNum': phoneNum,
      'notify': notify ? 1 : 0,
      'lastYearChecked': lastYearChecked,
    };
  }

  int getAgeOn(DateTime compareDate) {
    return compareDate.year -
        date.year -
        (date.month > compareDate.month ||
                date.month == compareDate.month && date.day > compareDate.day
            ? 1
            : 0);
  }

  Future loadPhoto() async {
    if (contactId != null &&
        photo == null &&
        await Permission.contacts.isGranted) {
      var contact =
          await FlutterContacts.getContact(contactId!, withPhoto: true);
      if (contact != null) {
        photo = contact.photo;
      }
    }
  }

  @override
  String toString() {
    return "Birthday${toMap()}";
  }

  static Birthday fromMap(Map<String, dynamic> map) {
    return Birthday(
        uid: map['uid'],
        contactId: map['contactId'],
        displayName: map['displayName'],
        phoneNum: map['phoneNum'],
        date: DateTime.parse(map['date']),
        notify: map['notify'] == 1,
        lastYearChecked: map['lastYearChecked']);
  }

  static Future<Database> get _database async {
    WidgetsFlutterBinding.ensureInitialized();
    return await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'bd_database.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE birthdays(uid DOUBLE PRIMARY KEY, contactId TEXT, displayName TEXT, phoneNum TEXT, date DATETIME, note STRING, notify INTEGER, lastYearChecked INTEGER)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insert(Birthday bd) async {
    // Get a reference to the database.
    final db = await _database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'birthdays',
      bd.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(Birthday bd) async {
    // Get a reference to the database.
    final db = await _database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.update(
      'birthdays',
      bd.toMap(),
      where: "uid = ?",
      whereArgs: [bd.uid],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(Birthday bd) async {
    // Get a reference to the database.
    final db = await _database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.delete(
      'birthdays',
      where: "uid = ?",
      whereArgs: [bd.uid],
    );
  }

  static Future<void> deleteAll() async {
    // Get a reference to the database.
    final db = await _database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.delete(
      'birthdays',
      where: "1 = 1",
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  static Future<List<Birthday>> getAllAsList() async {
    // Get a reference to the database.
    final db = await _database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('birthdays');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    var bdList = List.generate(maps.length, (i) {
      return Birthday.fromMap(maps[i]);
    });

    await Future.wait(bdList.map((e) => e.loadPhoto()));
    return bdList;
  }

  // A method that retrieves all the dogs from the dogs table.
  static Future<Map<DateTime, List<Birthday>>> getAll() async {
    var list = await getAllAsList();
    return list.fold(<DateTime, List<Birthday>>{}, (previousValue, bd) async {
      var val = await previousValue;
      val.containsKey(bd.date) ? val[bd.date]!.add(bd) : val[bd.date] = [bd];
      return val;
    });
  }

  static Future<List<Birthday>> getForDate(DateTime date) async {
    // Get a reference to the database.
    final db = await _database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('birthdays',
        where: "date <= ? and strftime('%m-%d', date) = ?",
        whereArgs: [date.toString(), DateFormat("MM-dd").format(date)]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Birthday.fromMap(maps[i]);
    });
  }

  Future<int> getCountForDate(DateTime date) async {
    // Get a reference to the database.
    final db = await _database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('birthdays',
        columns: ["count(date)"],
        where: "date >= ? and strftime('%m-%d', date) = ?",
        whereArgs: [date.toString(), DateFormat("MM-dd").format(date)]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return maps[0]["count(date)"];
  }
}
