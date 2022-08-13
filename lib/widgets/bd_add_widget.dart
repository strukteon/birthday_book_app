import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';

import '../model/birthday.dart';
import '../utilities/widgets/bd_add_logic.dart';

class BdAddWidget extends StatefulWidget {
  final Birthday bd;
  final Function(Birthday)? onSubmit;
  final Function(Birthday)? onDelete;
  final bool isEditing;

  const BdAddWidget(this.bd,
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
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2 +
          MediaQuery.of(context).viewInsets.bottom,
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
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "${widget.isEditing ? "Edit" : "Add a"} birthday",
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                        ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Icon(Icons.text_fields)],
                            ),
                            title: TextFormField(
                              controller: displayNameController,
                              decoration: const InputDecoration(
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
                          leading: const Icon(Icons.calendar_month),
                          trailing: const Icon(Icons.edit),
                          title:
                              Text(DateFormat("dd.MM.yyyy").format(newBd.date)),
                          onTap: onDateTileTap(context, newBd, setState),
                        ),
                        ListTile(
                            leading: const Icon(Icons.contacts),
                            trailing: Icon(
                                contact == null ? Icons.edit : Icons.delete),
                            onTap: () async {
                              Contact? newContact = await onContactTileTap(context, contact, displayNameController, newBd, setState)();
                                setState(() {
                                  contact = newContact;
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
                                          color:
                                              Theme.of(context).disabledColor)),
                                  TextSpan(
                                      text: "\nPhone Number: ",
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        TextSpan(
                                            text: newBd.phoneNum ?? "None",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .disabledColor))
                                      ])
                                ]))),
                        const Spacer(),
                        if (widget.isEditing)
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: OutlinedButton(
                                          onPressed: () {
                                            widget.onDelete!(newBd);
                                            Navigator.pop(context);
                                          },
                                          style: OutlinedButton.styleFrom(
                                              primary: Theme.of(context)
                                                  .errorColor),
                                          child: const Text("Delete")))),
                            ],
                          ),
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ))),
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: ElevatedButton(
                                      onPressed: onSaveTileTap(
                                          context,
                                          _formKey,
                                          newBd,
                                          widget,
                                          displayNameController,
                                          contact),
                                      child: Text(
                                          widget.isEditing ? "Save" : "Add"),
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
}
