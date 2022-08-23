import 'package:flutter_contacts/flutter_contacts.dart';

import '../model/birthday.dart';

class StaticValues {
  StaticValues._();

  static DateTime get firstDate => DateTime.utc(1900, 1, 1);

  static DateTime get lastDate => DateTime.utc(2100, 12, 31);

  static const String privacyPolicyUrl =
      "https://github.com/strukteon/birthday_book_app/blob/master/privacy_policy.md";
}

class Utils {
  static Future<List<Birthday>> loadContacts() async {
    var contacts = await FlutterContacts.getContacts(
        withProperties: true, withPhoto: true);

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
          photo: contact.photo);
    }).toList();

    await Future.wait(bdList.map((e) => e.loadPhoto()));
    return bdList;
  }
}
