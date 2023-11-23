import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:precast_demo/indexAppBar.dart';
import 'loginPage.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'elementMaster.dart';

class Data {
  final int userId;
  final int id;
  final String title;

  Data({required this.userId, required this.id, required this.title});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

Future<List<Data>> fetchData() async {
  var url = Uri.parse('https://jsonplaceholder.typicode.com/albums');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => Data.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occured!');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndexAppBar(title: 'Home Page',),
      drawer: Drawer(
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
              leading: Icon(Icons.dashboard_sharp, color: Colors.blue.shade400,),
              title: const Text('Dashboard'),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                  child: ListTile(
                    title: const Text('Element Status Viewer'),
                    onTap: () {

                    },
                  ),
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.settings_outlined, color: Colors.blue.shade400,),
              title: const Text('Set up'),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                  child: ListTile(
                    title: const Text('Element Master'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ElementMaster()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                  child: ListTile(
                    title: const Text('Part Details'),
                    onTap: () {

                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                  child: ListTile(
                    title: const Text('Truck Details'),
                    onTap: () {

                    },
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
                      title: const Text('Settings'),
                      onTap: () {},
                    ),
                  ),
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
                ]
            ),
            ExpansionTile(
              leading: Icon(Icons.note_alt_rounded, color: Colors.blue.shade400,),
              title: const Text('Report'),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                  child: ListTile(
                    title: const Text('Delivery Note'),
                    onTap: () {

                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                  child: ListTile(
                    title: const Text('QR Code Details'),
                    onTap: () {

                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.blue.shade400,),
              title: const Text('Logout'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const LoginPage()));
              }
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to the Home Page!',
                style: Theme.of(context).textTheme.displayMedium
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              Table(

              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: () {
                  // Handle button press
                },
                child: const Text('Press me', style: TextStyle(color: Colors.blueGrey),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}