import 'package:flutter/material.dart';
import 'load_model.dart';
import 'elementTracker.dart';
import 'loginPage.dart';
import './load_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

Drawer SideBarMenu(BuildContext context,List<LoadData> loads , dynamic AddLoadData, dynamic tenantConfig) {

  return Drawer(
    shadowColor: Colors.blueGrey.shade800,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.150,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
        // ExpansionTile(
        //   leading: Icon(
        //     Icons.dashboard_sharp,
        //     color: Colors.blue.shade400,
        //   ),
        //   title: const Text('Dashboard'),
        //   children: [
        //     Padding(
        //       padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
        //       child: ListTile(
        //         title: const Text('Element Status Viewer'),
        //         onTap: () {},
        //       ),
        //     ),
        //   ],
        // ),
        // ExpansionTile(
        //   leading: Icon(
        //     Icons.settings_outlined,
        //     color: Colors.blue.shade400,
        //   ),
        //   title: const Text('Set up'),
        //   children: [
        //     Padding(
        //       padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
        //       child: ListTile(
        //         title: const Text('Element Master'),
        //         onTap: () {
        //           Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => ElementMaster()));
        //         },
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
        //       child: ListTile(
        //         title: const Text('Part Details'),
        //         onTap: () {},
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
        //       child: ListTile(
        //         title: const Text('Truck Details'),
        //         onTap: () {},
        //       ),
        //     ),
        //   ],
        // ),
        // ExpansionTile(
        //     leading: Icon(Icons.hardware, color: Colors.blue.shade400),
        //     title: const Text('Process'),
        //     children: [
        //       Padding(
        //         padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
        //         child: ListTile(
        //           title: const Text('Dispatch Load'),
        //           onTap: () {},
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
        //         child: ListTile(
        //           title: const Text('Receive Load'),
        //           onTap: () {},
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
        //         child: ListTile(
        //           title: const Text('Issue element'),
        //           onTap: () {},
        //         ),
        //       ),
        //     ]),
        // ExpansionTile(
        //   leading: Icon(
        //     Icons.note_alt_rounded,
        //     color: Colors.blue.shade400,
        //   ),
        //   title: const Text('Report'),
        //   children: [
        //     Padding(
        //       padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
        //       child: ListTile(
        //         title: const Text('Delivery Note'),
        //         onTap: () {},
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
        //       child: ListTile(
        //         title: const Text('QR Code Details'),
        //         onTap: () {},
        //       ),
        //     ),
        //   ],
        // ),
       /* ListTile(
            leading: Icon(
              Icons.history,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Load History'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoadHistory(loads:loads!=null?loads:[],addLoad:AddLoadData,tenantConfig: tenantConfig,)));
              // Navigator.push(context, route);
            }),

        */
        const Divider(),
        ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Logout'),
            onTap: () {
              SharedPreferences.getInstance().then((value) {
                value.remove('userManagement');
                value.remove('tenantConfig');
              });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage()));
            }),
      ],
    ),
  );
}