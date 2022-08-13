import 'package:birthday_book/utilities/birthday_notifier.dart';
import 'package:birthday_book/widgets/BirthdayEntry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllBdsScreen extends StatefulWidget {
  const AllBdsScreen({Key? key}) : super(key: key);

  @override
  State<AllBdsScreen> createState() => _AllBdsScreenState();
}

class _AllBdsScreenState extends State<AllBdsScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayNotifier>(builder: (context, birthdays, child) => ListView.builder(
        itemCount: birthdays.birthdayList.length,
        itemBuilder: (context, index) {
          return BirthdayEntry(birthday: birthdays.birthdayList[index], ageCalcDate: DateTime.now(),);
        })
    );
  }
}
