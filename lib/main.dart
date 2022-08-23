import 'dart:async';
import 'dart:ui';

import 'package:birthday_book/screens/main_screen.dart';
import 'package:birthday_book/utilities/backgroundtask_manager.dart';
import 'package:birthday_book/utilities/birthday_notifier.dart';
import 'package:birthday_book/utilities/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/welcome_screen.dart';

void main() async {

  () async {
    await NotificationManager.initialize();
    await BackgroundtaskManager.initialize();
  }();

  await Future.wait([
    BirthdayNotifier().asyncAllBirthdays(),
  ]);

  var prefs = await SharedPreferences.getInstance();

  runApp(MyApp(firstStartFinished: prefs.getBool("firstStartFinished") ?? false));
}

class MyApp extends StatelessWidget {
  final bool firstStartFinished;

  const MyApp({super.key, this.firstStartFinished = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birthday Book',
      home: firstStartFinished
        ? MainScreen()
        : WelcomeScreen(),
      theme: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
                headlineLarge: const TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.w600),
                headlineSmall: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 30,
                    fontWeight: FontWeight.w400),
                displaySmall: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                    fontWeight: FontWeight.w300),
              )),
    );
  }
}