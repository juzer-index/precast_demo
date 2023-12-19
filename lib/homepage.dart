import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:precast_demo/projectDetailTabs.dart';
import 'package:precast_demo/indexAppBar.dart';
import 'package:precast_demo/sideBarMenu.dart';
import 'loginPage.dart';
import 'package:http/http.dart' as http;
import 'elementMaster.dart';

class Data {
  final String projectId;
  // final int transactionId;
  final String date;
  final String location;
  // final int lineItems;
  // final String details;

  Data({
    required this.projectId,
    // required this.transactionId,
    required this.date,
    required this.location,
    // required this.lineItems,
    // required this.details,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      projectId: json['ProjectID'],
      // transactionId: json['TransactionId'],
      date: json['StartDate'],
      location: json['Description'],
      // lineItems: int.parse(json['PrimaryMtl']),
      // details: json['Details'],
    );
  }
}

//for internal usage

Future<List<Data>> fetchData() async {
  String jsonString = await rootBundle.loadString('assets/data_projects.json');
  Map<String, dynamic> jsonResponse = json.decode(jsonString);
  return (jsonResponse['value'] as List).cast<Map<String, dynamic>>().map((e) => Data.fromJson(e)).toList();
}

//main function to fetch data from a url

// Future<List<Data>> fetchData() async {
//   var url = Uri.parse('https://raw.githubusercontent.com/juzer-index/Precast-assets/main/data_projects.json');
//   final response = await http.get(url);
//   if (response.statusCode == 200) {
//     Map<String, dynamic> jsonResponse = json.decode(response.body);
//     return (jsonResponse['value'] as List).cast<Map<String, dynamic>>().map((e) => Data.fromJson(e)).toList();
//   } else {
//     throw Exception('Unexpected error occurred!');
//   }
// }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Welcome, Joe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade400,),
                ),
              ),
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
                                'Department: Sales ',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade800),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(120, 0, 0, 0),
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
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Your Assigned Projects',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade400,
                  ),
                ),
              ),
              //add a table here whose rows can be selected with checkboxes
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Card(
                  elevation: 1,
                  color: Colors.lightBlue.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder<List<Data>>(
                      future: fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Data>? data = snapshot.data;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                onSelectAll: null,
                                showCheckboxColumn: true,
                                columns: const [
                                  // DataColumn(
                                  //   label: Text(
                                  //     'Transaction ID',
                                  //   ),
                                  // ),
                                  DataColumn(
                                    label: Text(
                                      'Project ID',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Date of Delivery',
                                    ),
                                  ),
                                  DataColumn(
                                      label: Text('Location')
                                  ),
                                  // DataColumn(
                                  //   label: Text(
                                  //     'Line Items',
                                  //   ),
                                  // ),
                                  // DataColumn(
                                  //   label: Text(
                                  //     'Details',
                                  //   ),
                                  // ),
                                ],
                                rows: data!
                                    .map(
                                      (data) => DataRow(
                                        onSelectChanged: (bool? value) {
                                          setState(() {
                                            // data.selected = value!;
                                          });
                                        },
                                        cells: [
                                          // DataCell(
                                          //   Text(data.transactionId.toString()),
                                          // ),
                                          DataCell(
                                            Text(data.projectId.toString()),
                                          ),
                                          DataCell(
                                            Text(data.date.toString()),
                                          ),
                                          DataCell(
                                            Text(data.location.toString()),
                                          ),
                                          // DataCell(
                                          //   Text(data.toString()),
                                          // ),
                                          // DataCell(
                                          //   Text(data.details),
                                          // ),
                                        ],
                                      ),
                                    ).toList(),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
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
                          builder: (context) => ProjectDetails(initialTabIndex: 0,),
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
                          builder: (context) => ProjectDetails(initialTabIndex: 1,),
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
                          builder: (context) => ProjectDetails(initialTabIndex: 2,),
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
      ),
    );
  }


}
