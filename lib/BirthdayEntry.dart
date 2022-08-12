import 'package:birthday_book/change_notifiers/birthday.dart';
import 'package:birthday_book/notification_manager.dart';
import 'package:flutter/material.dart';
import '../model/birthday.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'screens/main_calendar_screen.dart';

class BirthdayEntry extends StatelessWidget {
  final Birthday birthday;
  late String initials;
  late int age;
  DateTime ageCalcDate;
  bool smallView;
  bool canClick;

  BirthdayEntry({Key? key, required this.birthday, required this.ageCalcDate, this.smallView = false, this.canClick = true})
      : super(key: key) {
    initials = birthday.displayName.isEmpty ? "?" : birthday.displayName
        .splitMapJoin(" ", onMatch: (m) => "", onNonMatch: (str) => str.isNotEmpty ? str[0] : "");
    age = birthday.getAgeOn(ageCalcDate);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: canClick ? () {
          var providerContext = context;
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) => BdAddWidget(
                    birthday,
                    isEditing: true,
                    onSubmit: (bd) {
                      Provider.of<AllBirthdays>(providerContext, listen: false).updateBirthday(bd);
                    },
                    onDelete: (bd) {
                      Provider.of<AllBirthdays>(providerContext, listen: false).deleteBirthday(bd);
                    },
                  ));
        } : null,
        title: Text(birthday.displayName.isEmpty ? "(No name)" : birthday.displayName),
        subtitle: Text(DateFormat("dd.MM.yyyy").format(birthday.date) +
            (birthday.phoneNum != null && birthday.phoneNum!.isNotEmpty
                ? " | ${birthday.phoneNum}"
                : "")),
        leading:
        birthday.photo == null ?
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(99)),
          ),
          padding: EdgeInsets.all(8),
          child: Center(
              child: FittedBox(fit: BoxFit.fitWidth, child: Text(initials))),
        ) :
        ClipOval(
          child: SizedBox.fromSize(
            size: Size.fromRadius(20), // Image radius
            child: Image.memory(birthday.photo!),
          ),
        ),
        trailing: smallView ? null : Container(
          width: 32,
          height: 38,
          child: Stack(
            children: [
              Positioned.fill(
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.cake_rounded,
                        size: 24,
                      ))),
              Positioned.fill(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                          age < 0 ? "-" : age.toString(),
                          style: TextStyle(color: Colors.black45)))),
            ],
          ),
        ));
  }
}
