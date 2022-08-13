import 'package:birthday_book/model/birthday.dart';
import 'package:birthday_book/utilities/birthday_notifier.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../widgets/bd_add_widget.dart';


String generateInitials(Birthday birthday) {
  return birthday.displayName.isEmpty ? "?" : birthday.displayName
      .splitMapJoin(" ", onMatch: (m) => "", onNonMatch: (str) => str.isNotEmpty ? str[0] : "");
}

void Function() onWidgetClick(BuildContext context, Birthday birthday) => () {
  var providerContext = context;
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => BdAddWidget(
        birthday,
        isEditing: true,
        onSubmit: (bd) {
          Provider.of<BirthdayNotifier>(providerContext, listen: false).updateBirthday(bd);
        },
        onDelete: (bd) {
          Provider.of<BirthdayNotifier>(providerContext, listen: false).deleteBirthday(bd);
        },
      ));
};

String getSubtitle(Birthday birthday) {
  return DateFormat("dd.MM.yyyy").format(birthday.date) +
      (birthday.phoneNum != null && birthday.phoneNum!.isNotEmpty
          ? " | ${birthday.phoneNum}"
          : "");
}
