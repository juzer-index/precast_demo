import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:precast_demo/elementStatusTracker.dart';
import 'package:precast_demo/indexAppBar.dart';
import 'package:precast_demo/sideBarMenu.dart';
import 'loginPage.dart';
import 'package:http/http.dart' as http;
import 'elementMaster.dart';

class Data {
  final int headerId;
  final String date;
  final String lineItems;
  final String details;

  Data({
    required this.headerId,
    required this.date,
    required this.lineItems,
    required this.details,});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      headerId: json['HeaderId'],
      date: json['Date'],
      lineItems: json['LineItems'],
      details: json['Details'],
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
    throw Exception('Unexpected error occurred!');
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
      appBar: IndexAppBar(
        title: 'Home Page',
      ),
      drawer: SideBarMenu(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.11,
              child: Card(
                elevation: 1,
                color: Colors.lightBlue.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          'https://media.licdn.com/dms/image/D4D03AQFpmZgzpRLrhg/profile-displayphoto-shrink_200_200/0/1692612499698?e=1706140800&v=beta&t=WX4ydCp7VUP7AhXZOIDHIX3D3Ts5KfR-1YJJU6FmalI',
                          height: 40,
                          width: 40,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ID: 408',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Name: Joe ',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(160, 0, 0, 0),
                          child: IconButton(
                              onPressed: () {
                                //display a popup with rounded borders and half screen size
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20.0)),
                                          child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              child: const Padding(
                                                  padding:
                                                      EdgeInsets.all(12.0),
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Profile Information',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          'Name: Joe',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          'ID: 408',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          'Department: Sales',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          'Shift: Morning',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                        SizedBox(height: 10),
                                                      ]
                                                  )
                                              )
                                          )
                                      );
                                    }
                                    );
                              },
                              icon: Icon(
                                Icons.info,
                                color: Colors.blueGrey.shade800,
                              )))
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            //add a table here whose rows can be selected with checkboxes
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Card(
                elevation: 1,
                color: Colors.lightBlue.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: true,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Header ID',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Date of Delivery',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Line Items',
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Details',
                          ),
                        ),
                      ],
                      rows: const [

                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ElementStatusTracker(initialTabIndex: 0,),
                      ),
                    );
                  },
                  child: const Text(
                    'Add New',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ElementStatusTracker(initialTabIndex: 1,),
                      ),
                    );

                  },
                  child: const Text(
                    'Complete',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ElementStatusTracker(initialTabIndex: 2,),
                      ),
                    );
                  },
                  child: const Text(
                    'Undo',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
