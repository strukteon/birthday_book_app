import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/birthday.dart';


class BirthdayNotifier extends ChangeNotifier {
  static Map<DateTime, List<Birthday>>? preloadedBirthdays;

  Map<DateTime, List<Birthday>> birthdays = {};
  List<Birthday> get birthdayList => birthdays.values.fold([], (value, element) {
    value.addAll(element);
    return value;
  });

  BirthdayNotifier() {
    if (preloadedBirthdays != null) {
      birthdays = preloadedBirthdays!;
    }
  }

  Future asyncAllBirthdays() async {
    birthdays = await Birthday.getAll();
    preloadedBirthdays = birthdays;
  }

  void addBirthday(Birthday bd) {
    birthdays.containsKey(bd.date) ? birthdays[bd.date]!.add(bd) : birthdays[bd.date] = [bd];
    Birthday.insert(bd);
    notifyListeners();
  }

  void addBirthdays(Iterable<Birthday> bds) {
    for (var bd in bds) {
      birthdays.containsKey(bd.date) ? birthdays[bd.date]!.add(bd) : birthdays[bd.date] = [bd];
      Birthday.insert(bd);
    }
    notifyListeners();
  }

  void updateBirthday(Birthday bd) {
    var oldDate = birthdayList.firstWhere((element) => element.uid == bd.uid).date;
    birthdays[oldDate]?.removeWhere((element) => element.uid == bd.uid);
    birthdays.containsKey(bd.date) ? birthdays[bd.date]!.add(bd) : birthdays[bd.date] = [bd];
    Birthday.update(bd);
    notifyListeners();
  }

  void updateBirthdays(Iterable<Birthday> bds) {
    for (var bd in bds) {
      var oldDate = birthdayList.firstWhere((element) => element.uid == bd.uid).date;
      birthdays[oldDate]?.removeWhere((element) => element.uid == bd.uid);
      birthdays.containsKey(bd.date) ? birthdays[bd.date]!.add(bd) : birthdays[bd.date] = [bd];
      Birthday.update(bd);
    }
    notifyListeners();
  }

  void deleteBirthday(Birthday bd) {
    var oldDate = birthdayList.firstWhere((element) => element.uid == bd.uid).date;
    birthdays[oldDate]!.removeWhere((element) => element.uid == bd.uid);
    Birthday.delete(bd);
    notifyListeners();
  }

  List<Birthday> getBirthdaysForDate(DateTime date) {
    var days = <Birthday>[];
    final format = DateFormat("MM-dd");
    birthdays.forEach((key, value) {
      if (key.isBefore(date.add(Duration(seconds: 5))) && format.format(key) == format.format(date)) {
        days.addAll(value);
      }
    });
    days.sort(BirthdaySortingMethod.name);
    return days;
  }

  void deleteAllBirthdays() {
    birthdays.clear();
    Birthday.deleteAll();
    notifyListeners();
  }

  getSorted([int Function(Birthday, Birthday)? compare]) {
    var birthdays = birthdayList;
    birthdays.sort(compare);
    return birthdays;
  }
}

class BirthdaySortingMethod {
  static int Function(Birthday, Birthday) name = (birthday1, birthday2) {
    return birthday1.displayName.compareTo(birthday2.displayName);
  };
}