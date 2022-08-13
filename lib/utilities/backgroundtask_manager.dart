import 'package:birthday_book/model/birthday.dart';
import 'package:birthday_book/utilities/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import '../model/settings.dart';

class BackgroundtaskManager {
  static Future initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: true);
    await Workmanager()
        .registerPeriodicTask("check-birthday-today", "simpleTask");
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print("starting background task -----");
      await Settings.loadPrefs();
      if (Settings.doNotDisturb) {
        return true;
      }

      var now = DateTime.now();
      var todaysBirthdays = await Birthday.getForDate(now);

      var msgText = Settings.congratulationText;
      String genBdMessage(Birthday bd) => msgText
          .replaceAll("{name}", bd.displayName)
          .replaceAll("{age}", "${bd.getAgeOn(now)}");

      for (var bd in todaysBirthdays) {
        if (bd.lastYearChecked >= now.year) {
          continue;
        }
        NotificationManager.showHappyBirthdayNotification(bd, genBdMessage(bd));
        bd.lastYearChecked = now.year;
        Birthday.update(bd);
      }
    } catch (err) {
      print(err.toString());
      rethrow;
    }

    return true;
  });
}
