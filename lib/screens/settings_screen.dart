import 'package:birthday_book/change_notifiers/birthday.dart';
import '../change_notifiers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Settings.loadPrefs(),
      builder: (c, s) => Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              value: Settings.doNotDisturb,
              onChanged: (val) {
                setState(() {
                  Settings.doNotDisturb = val;
                });
              },
              title: Text("Do not disturb"),
              subtitle: Text("Stop receiving birthday notifications"),
            ),
            ListTile(
              title: Text("Automatic congratulation text"),
              subtitle: Text('For example: "Happy Birthday, Mark!"'),
              onTap: () async {
                var congTextController =
                TextEditingController(text: Settings.congratulationText);
                var saveChanges = await showDialog<bool>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text("Automatic congratulation text"),
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: 8, right: 8),
                            child: ListBody(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: "Name: ",
                                            style: DefaultTextStyle.of(context)
                                                .style),
                                        WidgetSpan(
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                                color: Colors.grey,
                                              ),
                                              child: Text(
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
                                                color: Colors.black.withAlpha(
                                                    (255 * 0.5).floor()))),
                                        TextSpan(
                                            text: "\nAge: ",
                                            style: DefaultTextStyle.of(context)
                                                .style),
                                        WidgetSpan(
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                                color: Colors.grey,
                                              ),
                                              child: Text(
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
                                                color: Colors.black.withAlpha(
                                                    (255 * 0.5).floor()))),
                                      ])),
                                ),
                                TextField(
                                  controller: congTextController,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          child: OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: Text("Cancel")),
                                        )),
                                    Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: Text("Save")),
                                        )),
                                  ],
                                )
                              ],
                            ))
                      ],
                    ));

                if (saveChanges == true) {
                  Settings.congratulationText = congTextController.text;
                }
              },
            ),
            ListTile(
              title: Text("Preferred messenger app"),
              subtitle: Text("App to send messages with, eg. WhatsApp"),
              onTap: () async {
                var changes = await showDialog<PreferredMessenger>(
                    context: context,
                    builder: (context) {
                      PreferredMessenger? preferredMessenger =
                          Settings.preferredMessenger;
                      return SimpleDialog(
                        title: Text("Preferred messenger app"),
                        children: [
                          Container(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: ListBody(
                                children: [
                                  Container(
                                      child: StatefulBuilder(
                                          builder: (context, setState) =>
                                              ListView(
                                                shrinkWrap: true,
                                                children: [
                                                  for (var msnger
                                                  in PreferredMessenger
                                                      .values)
                                                    RadioListTile<
                                                        PreferredMessenger>(
                                                      title: Text(
                                                          msnger.humanReadable),
                                                      value: msnger,
                                                      groupValue:
                                                      preferredMessenger,
                                                      onChanged:
                                                          (PreferredMessenger?
                                                      value) {
                                                        setState(() {
                                                          preferredMessenger =
                                                              value;
                                                        });
                                                      },
                                                    )
                                                ],
                                              ))),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            child: OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Cancel")),
                                          )),
                                      Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context, preferredMessenger);
                                                },
                                                child: Text("Save")),
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
              },
            ),
            Divider(),
            OutlinedButton(
                onPressed: () async {
                  var permissionStatus = await Permission.contacts.request();
                  if (permissionStatus.isDenied) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Please grant contact permissions to link to a contact.")));
                    return;
                  }

                  var contacts = await Utils.loadContacts();
                  var birthdays =
                  Provider.of<AllBirthdays>(context, listen: false);
                  var birthdayList = birthdays.birthdayList;

                  var newContacts = contacts.where((contact) => !birthdayList
                      .any((bd) => bd.contactId == contact.contactId));
                  var updatedContacts =
                  contacts.where((contact) => !newContacts.contains(contact));

                  for (var contact in updatedContacts) {
                    contact.uid = birthdayList
                        .firstWhere((bd) => bd.contactId == contact.contactId)
                        .uid;
                  }
                  birthdays.updateBirthdays(updatedContacts);
                  birthdays.addBirthdays(newContacts);
                },
                child: Text("Reimport contacts")),
            OutlinedButton(
              onPressed: () {
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
                          child: const Text('Cancel'),
                          style: TextButton.styleFrom(
                            primary: Theme.of(context).errorColor,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Continue'),
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).errorColor,
                          ),
                          onPressed: () {
                            Provider.of<AllBirthdays>(providerContext,
                                listen: false)
                                .deleteAllBirthdays();
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    ));
              },
              child: Text("Delete all saved birthdays"),
              style:
              OutlinedButton.styleFrom(primary: Theme.of(context).errorColor),
            ),
            Expanded(child: Container(
              alignment: Alignment.bottomRight,
              child: Text("(c) Nils Schneider-Sturm 2022"),
            ))
          ],
        ),
      ),
    );
  }
}
