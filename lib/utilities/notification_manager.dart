import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:birthday_book/model/birthday.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/settings.dart';

class NotificationManager {
  static Uri getUriFormat(PreferredMessenger messenger, String number, String body) {
    switch (messenger) {
      case PreferredMessenger.whatsapp:
        return Uri.parse("whatsapp://send?phone=${Uri.encodeComponent(number)}&text=${Uri.encodeComponent(body)}");
      case PreferredMessenger.telegram:
        return Uri.parse("tg://msg?text=${Uri.encodeComponent(body)}");
      case PreferredMessenger.sms:
      default:
        return Uri(scheme: "smsto", path: number, queryParameters: <String, String>{
          "body": body
        });
    }
  }

  static Future initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await AwesomeNotifications().initialize(
        'resource://mipmap/ic_launcher',
        [            // notification icon
          NotificationChannel(
            channelGroupKey: 'basic_test',
            channelKey: 'basic',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            channelShowBadge: true,
            importance: NotificationImportance.High,
            enableVibration: true,
          ),
        ]
    );

    AwesomeNotifications().actionStream.listen((action) {
      if (action.buttonKeyPressed == "message") {
        launchUrl(getUriFormat(Settings.preferredMessenger, action.payload!["phoneNum"]!, action.payload!["message"]!));
      } else if (action.buttonKeyPressed == "call") {
        launchUrl(Uri.parse("tel:${action.payload!["phoneNum"]!}"));
      }
    });
  }

  static void showHappyBirthdayNotification(Birthday bd, String message) {
    AwesomeNotifications().createNotification(
        content: NotificationContent( //simple notification
          id: (bd.uid * 1000000).floor(),
          channelKey: 'basic', //set configuration with key "basic"
          title: '🎂 ${bd.displayName}',
          body: 'They are turning ${bd.getAgeOn(DateTime.now())} years old! 🎉',
          payload: {
            ...bd.toMap().map((key, value) => MapEntry(key, value.toString())),
            "message": message,
          },
          autoDismissible: false,
        ),

        actionButtons: bd.phoneNum == null ? [] : [
          NotificationActionButton(
            key: "call",
            label: "Call",
          ),

          NotificationActionButton(
            key: "message",
            label: "Message",
          )
        ]
    );
  }
}