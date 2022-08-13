import 'package:birthday_book/model/birthday.dart';
import 'package:birthday_book/utilities/utils.dart';
import 'package:birthday_book/widgets/bd_add_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';


Phone primaryPhoneNumber(Contact contact) {
  return contact.phones.firstWhere((element) => element.isPrimary);
}

VoidCallback onDateTileTap(BuildContext context, Birthday newBd,
    void Function(VoidCallback) setState) =>
        () async {
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
    };

VoidCallback onCancelTileTap(BuildContext context) =>
        () => Navigator.pop(context);

VoidCallback onSaveTileTap(BuildContext context,
    GlobalKey<FormState> formKey,
    Birthday newBd,
    BdAddWidget widget,
    TextEditingController displayNameController,
    Contact? contact) =>
        () async {
      if (formKey.currentState!.validate()) {
        newBd.displayName = displayNameController.text;
        newBd.contactId = contact?.id;
        widget.onSubmit!(newBd);

        // sync to contacts
        if (newBd.contactId != null) {
          var contact = (await FlutterContacts.getContact(newBd.contactId!,
              withAccounts: true))!;
          contact.events.removeWhere((ev) => ev.label == EventLabel.birthday);
          contact.events.add(Event(
              year: newBd.date.year,
              month: newBd.date.month,
              day: newBd.date.day,
              label: EventLabel.birthday));
          FlutterContacts.updateContact(contact);
        }

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    };

Future<Contact?> Function() onContactTileTap(BuildContext context, Contact? contact, TextEditingController displayNameController, Birthday newBd, void Function(VoidCallback) setState) =>
        () async {
      if (contact != null) {
        setState(() {
          newBd.phoneNum = null;
        });
        return null;
      }

      var permissionStatus =
      await Permission.contacts.request();
      if (permissionStatus.isDenied) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Please grant contact permissions to link to a contact.")));
        return contact;
      }
      var selectedContact = await FlutterContacts.openExternalPick();
      if (selectedContact == null) return contact;

      if (selectedContact.phones.length > 1) {
        var cancel = false;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          // user must tap button!
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
        if (cancel) return contact;
      }

      if (displayNameController.text.isEmpty) {
        displayNameController.text =
            selectedContact.displayName;
      }

      newBd.phoneNum = selectedContact.phones.isEmpty
          ? null
          : selectedContact.phones.first.number;

      newBd.photo = contact?.photo;

      return selectedContact;
    };