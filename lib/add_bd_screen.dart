import 'package:flutter/material.dart';

import 'model/birthday.dart';

class BirthdayAddScreen extends StatelessWidget {
  const BirthdayAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new birthday'),
      ),
      body: ListView(
        children: [
          const TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
          ),
          ElevatedButton(onPressed: () {}, child: const Text("date")),
          CheckboxListTile(
            title: const Text("title text"),
            value: true,
            onChanged: (newValue) {  },
            controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
          ),
          const TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Note',
            ),
          )
        ],
      ),
    );
  }
}
