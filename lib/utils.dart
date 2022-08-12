import 'package:flutter/material.dart';
import 'model/birthday.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';

class StaticValues {
  StaticValues._();

  static DateTime get firstDate => DateTime.utc(1900, 1, 1);
  static DateTime get lastDate => DateTime.utc(2050, 10, 16);
}

class Utils {
  static Future<List<Birthday>> loadContacts() async {
    var contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);

    var contactsWithBirthday = contacts.where((contact) =>
        contact.events.any((event) => event.label == EventLabel.birthday));

    var bdList = contactsWithBirthday.map((contact) {
      var bdEvent = contact.events
          .firstWhere((event) => event.label == EventLabel.birthday);

      return Birthday(
        date: DateTime(
            bdEvent.year ?? DateTime.now().year, bdEvent.month, bdEvent.day),
        displayName: contact.displayName,
        contactId: contact.id,
        phoneNum:
            contact.phones.isNotEmpty ? contact.phones.first.number : null,
        photo: contact.photo
      );
    }).toList();

    await Future.wait(bdList.map((e) => e.loadPhoto()));
    return bdList;
  }
}
