import 'package:birthday_book/utilities/birthday_notifier.dart';
import 'package:birthday_book/utilities/utils.dart';
import 'package:birthday_book/utilities/widgets/main_calendar_logic.dart';
import 'package:birthday_book/widgets/BirthdayEntry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/birthday.dart';
import '../widgets/bd_add_widget.dart';

class CalenderWidget extends StatefulWidget {
  const CalenderWidget({Key? key}) : super(key: key);

  @override
  State<CalenderWidget> createState() => _CalenderWidgetState();
}

class _CalenderWidgetState extends State<CalenderWidget> {
  var _focusedDay = DateTime.now();
  var _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayNotifier>(
        builder: (context, birthdays, child) => Stack(children: [
              Column(children: [
                TableCalendar(
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                  ),
                  firstDay: StaticValues.firstDate,
                  lastDay: StaticValues.lastDate,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay =
                          focusedDay; // update `_focusedDay` here as well
                    });
                  },
                  eventLoader: (day) {
                    return birthdays.getBirthdaysForDate(day);
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                Container(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dayDifference(DateTime.now(), _focusedDay),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withAlpha(100)),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      if (birthdays.getBirthdaysForDate(_focusedDay).isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                            child: const Center(
                          child: Text("No birthdays on this date"),
                        )),
                      for (var birthday
                          in birthdays.getBirthdaysForDate(_focusedDay))
                        BirthdayEntry(
                            birthday: birthday, ageCalcDate: _focusedDay)
                    ],
                  ),
                )
              ]),
              Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => BdAddWidget(
                            Birthday(date: _focusedDay), onSubmit: (bd) {
                          birthdays.addBirthday(bd);
                        })),
                    child: const Icon(Icons.add),
                  ))
            ]));
  }
}
