import 'package:flutter/material.dart';

import 'elementMaster.dart';
import 'loginPage.dart';


Drawer SideBarMenu(BuildContext context) {
  return Drawer(
    shadowColor: Colors.blueGrey.shade800,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.103,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Sidebar Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
        ExpansionTile(
          leading: Icon(
            Icons.dashboard_sharp,
            color: Colors.blue.shade400,
          ),
          title: const Text('Dashboard'),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: ListTile(
                title: const Text('Element Status Viewer'),
                onTap: () {},
              ),
            ),
          ],
        ),
        ExpansionTile(
          leading: Icon(
            Icons.settings_outlined,
            color: Colors.blue.shade400,
          ),
          title: const Text('Set up'),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: ListTile(
                title: const Text('Element Master'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ElementMaster()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: ListTile(
                title: const Text('Part Details'),
                onTap: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: ListTile(
                title: const Text('Truck Details'),
                onTap: () {},
              ),
            ),
          ],
        ),
        ExpansionTile(
            leading: Icon(Icons.hardware, color: Colors.blue.shade400),
            title: const Text('Process'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                child: ListTile(
                  title: const Text('Dispatch Load'),
                  onTap: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                child: ListTile(
                  title: const Text('Receive Load'),
                  onTap: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                child: ListTile(
                  title: const Text('Issue element'),
                  onTap: () {},
                ),
              ),
            ]),
        ExpansionTile(
          leading: Icon(
            Icons.note_alt_rounded,
            color: Colors.blue.shade400,
          ),
          title: const Text('Report'),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: ListTile(
                title: const Text('Delivery Note'),
                onTap: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: ListTile(
                title: const Text('QR Code Details'),
                onTap: () {},
              ),
            ),
          ],
        ),
        const Divider(),
        ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.blue.shade400,
            ),
            title: const Text('Logout'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage()));
            }),
      ],
    ),
  );
}