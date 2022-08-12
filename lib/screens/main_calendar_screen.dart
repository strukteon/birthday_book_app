import 'dart:convert';
import 'dart:typed_data';

import 'package:birthday_book/BirthdayEntry.dart';
import 'package:birthday_book/change_notifiers/birthday.dart';
import 'package:birthday_book/utils.dart';
import 'package:flutter/material.dart';
import '../model/birthday.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    return Consumer<AllBirthdays>(
        builder: (context, birthdays, child) => Stack(children: [
              Column(children: [
                TableCalendar(
                  headerStyle: HeaderStyle(
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
                  padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _dayDifference(DateTime.now(), _focusedDay),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withAlpha(100)),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      if (birthdays.getBirthdaysForDate(_focusedDay).length ==
                          0)
                        Container(
                          padding: EdgeInsets.all(16),
                            child: Center(
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
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => BdAddWidget(
                                  Birthday(date: _focusedDay), onSubmit: (bd) {
                                birthdays.addBirthday(bd);
                              }));
                    },
                    child: Icon(Icons.add),
                  ))
            ]));
  }

  String _dayDifference(DateTime now, DateTime compare) {
    var format = DateFormat("dd-MM-yyyy");
    var diff = format
        .parse(format.format(compare))
        .difference(format.parse(format.format(now)))
        .inDays;

    if (diff == 0) {
      return "Today";
    } else if (diff == -1) {
      return "Yesterday";
    } else if (diff == 1) {
      return "Tomorrow";
    } else if (diff < 0) {
      return "${-diff} days ago";
    }
    return "In $diff days";
  }
}

class BdAddWidget extends StatefulWidget {
  Birthday bd;
  Function(Birthday)? onSubmit;
  Function(Birthday)? onDelete;
  bool isEditing;

  BdAddWidget(this.bd,
      {this.onSubmit, this.onDelete, this.isEditing = false, Key? key})
      : super(key: key);

  @override
  State<BdAddWidget> createState() => _BdAddWidgetState();
}

class _BdAddWidgetState extends State<BdAddWidget> {
  final _formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final phoneNumController = TextEditingController();

  late Birthday newBd;
  Contact? contact;

  @override
  void initState() {
    super.initState();
    newBd = Birthday.fromMap(widget.bd.toMap());
    displayNameController.text = newBd.displayName;
    phoneNumController.text = newBd.phoneNum ?? "";

    initStateAsync();
  }

  void initStateAsync() async {
    if (widget.bd.contactId != null) {
      var loadedContact =
          await FlutterContacts.getContact(widget.bd.contactId!);
      setState(() {
        contact = loadedContact;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).viewInsets.bottom);
    return Container(
      height: MediaQuery.of(context).size.height / 2 + MediaQuery.of(context).viewInsets.bottom,
      child: Stack(
        children: [
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
                body: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            (widget.isEditing ? "Edit" : "Add a") + " birthday",
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                        ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.text_fields)],
                            ),
                            title: TextFormField(
                              controller: displayNameController,
                              decoration: InputDecoration(
                                labelText: 'Name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter a name";
                                }
                                return null;
                              },
                            )),
                        ListTile(
                          leading: Icon(Icons.calendar_month),
                          trailing: Icon(Icons.edit),
                          title: Text(DateFormat("dd.MM.yyyy").format(newBd.date)),
                          onTap: () async {
                            var selectedDate = await showDatePicker(
                                context: context,
                                initialDate: newBd.date,
                                firstDate: StaticValues.firstDate,
                                lastDate: StaticValues.lastDate);
                            if (selectedDate != null) {
                              setState(() {
                                newBd.date = selectedDate;
                              });
                            }
                          },
                        ),
                        ListTile(
                            leading: Icon(Icons.contacts),
                            trailing: Icon(contact == null ? Icons.edit : Icons.delete),
                            onTap: () async {
                              if (contact != null) {
                                setState(() {
                                  contact = null;
                                  newBd.phoneNum = null;
                                });
                                return;
                              }

                              var permissionStatus =
                              await Permission.contacts.request();
                              if (permissionStatus.isDenied) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Please grant contact permissions to link to a contact.")));
                                return;
                              }
                              var selectedContact =
                              await FlutterContacts.openExternalPick();
                              if (selectedContact == null) return;

                              if (selectedContact.phones.length > 1) {
                                var cancel = false;
                                await showDialog<void>(
                                  context: context,
                                  barrierDismissible: false, // user must tap button!
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'More than one phone number exists'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: const <Widget>[
                                            Text(
                                                'The first phone number will be automatically selected.'),
                                            Text('Do you want to continue?'),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            cancel = true;
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ElevatedButton(
                                          child: const Text('Continue'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (cancel) return;
                              }

                              if (displayNameController.text.isEmpty) {
                                displayNameController.text =
                                    selectedContact.displayName;
                              }

                              newBd.phoneNum = selectedContact.phones.isEmpty
                                  ? null
                                  : selectedContact.phones.first.number;


                              newBd.photo = contact?.photo;

                              setState(() {
                                contact = selectedContact;
                              });
                            },
                            title: RichText(
                                text: TextSpan(
                                    text: "Linked contact: ",
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      TextSpan(
                                          text: contact == null
                                              ? "None"
                                              : (contact!.displayName.isEmpty
                                              ? "(No name)"
                                              : contact!.displayName),
                                          style: TextStyle(
                                              color: Theme.of(context).disabledColor)),
                                      TextSpan(
                                          text: "\nPhone Number: ",
                                          style: DefaultTextStyle.of(context).style,
                                          children: [
                                            TextSpan(
                                                text: newBd.phoneNum == null
                                                    ? "None"
                                                    : newBd.phoneNum,
                                                style: TextStyle(
                                                    color: Theme.of(context).disabledColor))
                                          ])
                                    ]))),
                        Spacer(),
                        if (widget.isEditing)
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      padding: EdgeInsets.only(left: 8, right: 8),
                                      child: OutlinedButton(
                                          onPressed: () {
                                            widget.onDelete!(newBd);
                                            Navigator.pop(context);
                                          },
                                          child: Text("Delete"),
                                          style: OutlinedButton.styleFrom(
                                              primary: Theme.of(context).errorColor)))),
                            ],
                          ),
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel"),
                                    ))),
                            Expanded(
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          newBd.displayName =
                                              displayNameController.text;
                                          newBd.contactId = contact?.id;
                                          widget.onSubmit!(newBd);

                                          // sync to contacts
                                          if (newBd.contactId != null) {
                                            var contact =
                                            (await FlutterContacts.getContact(
                                                newBd.contactId!,
                                                withAccounts: true))!;
                                            contact.events.removeWhere((ev) =>
                                            ev.label == EventLabel.birthday);
                                            contact.events.add(Event(
                                                year: newBd.date.year,
                                                month: newBd.date.month,
                                                day: newBd.date.day,
                                                label: EventLabel.birthday));
                                            FlutterContacts.updateContact(contact);
                                          }

                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text(widget.isEditing ? "Save" : "Add"),
                                    ))),
                          ],
                        ),
                      ],
                    ))),
          )
        ],
      ),
    );
  }

  Phone primaryPhoneNumber(Contact contact) {
    return contact.phones.firstWhere((element) => element.isPrimary);
  }
}
