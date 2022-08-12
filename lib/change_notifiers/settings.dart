import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Settings {
  static SharedPreferences? prefs;

  static bool get doNotDisturb =>
      prefs?.getBool("settings.do_not_disturb") ?? false;

  static set doNotDisturb(bool val) {
    prefs?.setBool("settings.do_not_disturb", val);
  }

  static String get congratulationText =>
      prefs?.getString("settings.congratulation_text") ??
      "Happy Birthday, {name}!";

  static set congratulationText(String val) {
    prefs?.setString("settings.congratulation_text", val);
  }

  static PreferredMessenger get preferredMessenger =>
      PreferredMessenger.parse(prefs?.getString("settings.preferred_messenger")) ??
      PreferredMessenger.sms;

  static set preferredMessenger(PreferredMessenger val) {
    prefs?.setString("settings.preferred_messenger", val.toString());
  }

  static Future loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
}

enum PreferredMessenger {
  sms("SMS", Icons.sms),
  whatsapp("WhatsApp", Icons.whatsapp),
  telegram("Telegram", Icons.telegram);

  final String humanReadable;
  final IconData icon;

  const PreferredMessenger(this.humanReadable, this.icon);

  static PreferredMessenger? parse(String? val) {
    if (val == null) return null;
    return PreferredMessenger.values.firstWhereOrNull((el) => el.toString() == val);
  }
}
