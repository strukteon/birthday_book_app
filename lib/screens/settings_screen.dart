import 'package:birthday_book/utilities/widgets/settings_logic.dart';
import 'package:flutter/material.dart';

import'../model/settings.dart';

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
        padding: const EdgeInsets.all(8),
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
              title: const Text("Do not disturb"),
              subtitle: const Text("Stop receiving birthday notifications"),
            ),
            ListTile(
              title: const Text("Automatic congratulation text"),
              subtitle: const Text('For example: "Happy Birthday, Mark!"'),
              onTap: onMessageSettingsTap(context),
            ),
            ListTile(
              title: const Text("Preferred messenger app"),
              subtitle: const Text("App to send messages with, eg. WhatsApp"),
              onTap: onMessengerSettingsTap(context),
            ),
            const Divider(),
            OutlinedButton(
                onPressed: onReimportContactsTap(context),
                child: const Text("Reimport contacts")),
            OutlinedButton(
              onPressed: onDeleteAllBirthdaysTap(context),
              style:
              OutlinedButton.styleFrom(primary: Theme.of(context).errorColor),
              child: const Text("Delete all saved birthdays"),
            ),
            Expanded(child: Container(
              alignment: Alignment.bottomRight,
              child: const Text("(c) Nils Schneider-Sturm 2022"),
            ))
          ],
        ),
      ),
    );
  }
}
