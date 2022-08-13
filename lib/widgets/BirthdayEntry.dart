import 'package:birthday_book/utilities/widgets/bd_entry_logic.dart';
import 'package:flutter/material.dart';

import '../../model/birthday.dart';

class BirthdayEntry extends StatelessWidget {
  final Birthday birthday;
  late final int age;
  final DateTime ageCalcDate;
  final bool smallView;
  final bool canClick;

  BirthdayEntry(
      {Key? key,
      required this.birthday,
      required this.ageCalcDate,
      this.smallView = false,
      this.canClick = true})
      : super(key: key) {
    age = birthday.getAgeOn(ageCalcDate);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: canClick ? onWidgetClick(context, birthday) : null,
        title: Text(
            birthday.displayName.isEmpty ? "(No name)" : birthday.displayName),
        subtitle: Text(getSubtitle(birthday)),
        leading: birthday.photo == null
            ? InitialsAvatar(birthday)
            : ImageAvatar(birthday),
        trailing: smallView ? null : AgeWidget(age));
  }
}

class InitialsAvatar extends StatelessWidget {
  late final String initials;

  InitialsAvatar(Birthday birthday, {Key? key}) : super(key: key) {
    initials = generateInitials(birthday);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: const BorderRadius.all(const Radius.circular(99)),
      ),
      padding: const EdgeInsets.all(8),
      child:
          Center(child: FittedBox(fit: BoxFit.fitWidth, child: Text(initials))),
    );
  }
}

class ImageAvatar extends StatelessWidget {
  final Birthday birthday;

  const ImageAvatar(this.birthday, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox.fromSize(
        size: const Size.fromRadius(20), // Image radius
        child: Image.memory(birthday.photo!),
      ),
    );
  }
}

class AgeWidget extends StatelessWidget {
  final int age;

  const AgeWidget(this.age, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 38,
      child: Stack(
        children: [
          const Positioned.fill(
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Icon(
                    Icons.cake_rounded,
                    size: 24,
                  ))),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(age < 0 ? "-" : age.toString(),
                      style: const TextStyle(color: Colors.black45)))),
        ],
      ),
    );
  }
}
