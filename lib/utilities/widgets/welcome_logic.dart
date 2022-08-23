import 'package:birthday_book/model/birthday.dart';
import 'package:birthday_book/widgets/BirthdayEntry.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/main_screen.dart';
import '../../utilities/utils.dart';

Future Function() onImportContactsTap(BuildContext context) => () async {
      var permissionStatus = await Permission.contacts.request();
      if (permissionStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Please grant contact permissions to link to a contact.")));
        return;
      }

      var contacts = await Utils.loadContacts();

      await showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text("Import results"),
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 24, top: 12, bottom: 12),
                  child: Text("${contacts.length} contacts were imported."),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Ok")),
                )
              ],
            );
          });

      for (var element in contacts) {
        Birthday.insert(element);
      }
    };

void openMainScreen(BuildContext context) async {
  var prefs = await SharedPreferences.getInstance();
  prefs.setBool("firstStartFinished", true);
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => const MainScreen()));
}
