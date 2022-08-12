import 'package:birthday_book/BirthdayEntry.dart';
import 'package:birthday_book/change_notifiers/birthday.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/birthday.dart';

class AllBdsScreen extends StatefulWidget {
  const AllBdsScreen({Key? key}) : super(key: key);

  @override
  State<AllBdsScreen> createState() => _AllBdsScreenState();
}

class _AllBdsScreenState extends State<AllBdsScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AllBirthdays>(builder: (context, birthdays, child) => ListView.builder(
        itemCount: birthdays.birthdayList.length,
        itemBuilder: (context, index) {
          return BirthdayEntry(birthday: birthdays.birthdayList[index], ageCalcDate: DateTime.now(),);
        })
    );
  }
}
