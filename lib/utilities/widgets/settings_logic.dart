import 'package:birthday_book/utilities/birthday_notifier.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../model/settings.dart';
import '../../utilities/utils.dart';

Future Function() onMessageSettingsTap(BuildContext context) => () async {
      var textController =
          TextEditingController(text: Settings.congratulationText);
      var saveChanges = await showDialog<bool>(
          context: context,
          builder: (context) => SimpleDialog(
                title: const Text("Automatic congratulation text"),
                children: [
                  Container(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: ListBody(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: "Name: ",
                                  style: DefaultTextStyle.of(context).style),
                              WidgetSpan(
                                  child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey,
                                ),
                                child: const Text(
                                  "{name}",
                                  style: TextStyle(
                                    fontFamily: "monospace",
                                    color: Colors.black,
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              )),
                              TextSpan(
                                  text: " => eg. Max",
                                  style: TextStyle(
                                      color: Colors.black
                                          .withAlpha((255 * 0.5).floor()))),
                              TextSpan(
                                  text: "\nAge: ",
                                  style: DefaultTextStyle.of(context).style),
                              WidgetSpan(
                                  child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey,
                                ),
                                child: const Text(
                                  "{age}",
                                  style: TextStyle(
                                    fontFamily: "monospace",
                                    color: Colors.black,
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              )),
                              TextSpan(
                                  text: " => eg. 32",
                                  style: TextStyle(
                                      color: Colors.black
                                          .withAlpha((255 * 0.5).floor()))),
                            ])),
                          ),
                          TextField(
                            controller: textController,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                  child: Container(
                                padding: const EdgeInsets.all(4),
                                child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text("Cancel")),
                              )),
                              Expanded(
                                  child: Container(
                                padding: const EdgeInsets.all(4),
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text("Save")),
                              )),
                            ],
                          )
                        ],
                      ))
                ],
              ));

      if (saveChanges == true) {
        Settings.congratulationText = textController.text;
      }
    };

Future Function() onMessengerSettingsTap(BuildContext context) => () async {
      var changes = await showDialog<PreferredMessenger>(
          context: context,
          builder: (context) {
            PreferredMessenger? preferredMessenger =
                Settings.preferredMessenger;
            return SimpleDialog(
              title: const Text("Preferred messenger app"),
              children: [
                Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: ListBody(
                      children: [
                        StatefulBuilder(
                            builder: (context, setState) => ListView(
                                  shrinkWrap: true,
                                  children: [
                                    for (var msnger
                                        in PreferredMessenger.values)
                                      RadioListTile<PreferredMessenger>(
                                        title: Text(msnger.humanReadable),
                                        value: msnger,
                                        groupValue: preferredMessenger,
                                        onChanged: (PreferredMessenger? value) {
                                          setState(() {
                                            preferredMessenger = value;
                                          });
                                        },
                                      )
                                  ],
                                )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.all(4),
                              child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel")),
                            )),
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.all(4),
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context, preferredMessenger);
                                  },
                                  child: const Text("Save")),
                            )),
                          ],
                        )
                      ],
                    ))
              ],
            );
          });
      if (changes != null) {
        Settings.preferredMessenger = changes;
      }
    };

Future Function() onReimportContactsTap(BuildContext context) => () async {
      var permissionStatus = await Permission.contacts.request();
      if (permissionStatus.isDenied) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Please grant contact permissions to link to a contact.")));
        return;
      }

      var contacts = await Utils.loadContacts();
      var birthdays =
          // ignore: use_build_context_synchronously
          Provider.of<BirthdayNotifier>(context, listen: false);
      var birthdayList = birthdays.birthdayList;

      var newContacts = contacts.where((contact) =>
          !birthdayList.any((bd) => bd.contactId == contact.contactId));
      var updatedContacts =
          contacts.where((contact) => !newContacts.contains(contact));

      for (var contact in updatedContacts) {
        contact.uid = birthdayList
            .firstWhere((bd) => bd.contactId == contact.contactId)
            .uid;
      }
      birthdays.updateBirthdays(updatedContacts);
      birthdays.addBirthdays(newContacts);
    };


Future Function() onDeleteAllBirthdaysTap(BuildContext context) => () async {
  var providerContext = context;
  showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all birthdays'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text(
                  'Do you really want to delete all saved birthdays?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              primary: Theme.of(context).errorColor,
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).errorColor,
            ),
            onPressed: () {
              Provider.of<BirthdayNotifier>(providerContext,
                  listen: false)
                  .deleteAllBirthdays();
              Navigator.of(context).pop(true);
            },
            child: const Text('Continue'),
          ),
        ],
      ));
};
