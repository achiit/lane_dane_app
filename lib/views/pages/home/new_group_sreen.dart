// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class newgroup extends StatelessWidget {
  const newgroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading icon for previous screen will automatically
        //come once this screen is added

        backgroundColor: const Color(0xff008069),
        title: const ListTile(
          minLeadingWidth: 0,
          title: Text(
            'New Group',
            style: TextStyle(color: Colors.white, fontSize: 23),
          ),
          subtitle: Text(
            'Add participant',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            Icons.search,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Column(
              children: [
                contact_card(),
                contact_card(),
                contact_card(),
                contact_card(),
                contact_card(),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xff008069),
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }

  ListTile contact_card() {
    return const ListTile(
      leading: Icon(Icons.circle),
      title: Text(
        'Dummy contact',
        style: TextStyle(color: Colors.black),
      ),
      subtitle: Text('Subtitle'), //if needed
      minLeadingWidth: 0,
    );
  }
}
