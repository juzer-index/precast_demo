import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:precast_demo/addTruckDetails.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectData{
  late final String projectID;
  late final String deliveryDate;
  late final String deliverySite;
  late final String truckDetails;
  ProjectData({required this.projectID, required this.deliveryDate, required this.deliverySite, required this.truckDetails});

  factory ProjectData.fromJson(Map<String, dynamic> json) {
    return ProjectData(
      projectID: json['ProjectID'],
      deliveryDate: json['DeliveryDate'],
      deliverySite: json['DeliverySite'],
      truckDetails: json['TruckDetails'],
    );
  }
}

class ElementData {
  late final String elementId;
  late final String elementDesc;
  ElementData({required this.elementId, required this.elementDesc});

  factory ElementData.fromJson(Map<String, dynamic> json) {
    return ElementData(
        elementId: json['PartNum'],
        elementDesc: json['PartLotDescription'],
    );
  }
}

class PartData {
  late final String partNum;
  late final String partDesc;
  PartData({required this.partNum, required this.partDesc});

  factory PartData.fromJson(Map<String, dynamic> json) {
    return PartData(
      partNum: json['Part_PartNum'],
      partDesc: json['Part_PartDescription'],
    );
  }
}

Future<void> writeProjectDataToJson(String projectID, String deliveryDate, String deliverySite, String truckDetails) async {
  final Map<String, dynamic> projectData = <String, dynamic>{
    'ProjectID':  projectID,
    'DeliveryDate': deliveryDate,
    'DeliverySite': deliverySite,
    'TruckDetails': truckDetails,
  };
  final jsonString = json.encode(projectData);
  debugPrint (jsonString);
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/projectData.json');
  await file.writeAsString(jsonString);
}

Future<Map<String, dynamic>> fetchProjectDataFromJson() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/projectData.json');
  final jsonString = await file.readAsString();
  Map<String, dynamic> jsonResponse = json.decode(jsonString);
  return jsonResponse;
}

//Part Data URL fetch

// Future<List<PartData>> fetchPartData() async {
//   var url = Uri.parse('https://raw.githubusercontent.com/juzer-index/Precast-assets/main/data_parts.json');
//   final response = await http.get(url);
//   if (response.statusCode == 200) {
//     Map<String, dynamic> jsonResponse = json.decode(response.body);
//     return (jsonResponse['value'] as List).cast<Map<String, dynamic>>().map((e) => PartData.fromJson(e)).toList();
//   } else {
//     throw Exception('Unexpected error occurred!');
//   }
// }

//Part Data local fetch

Future<List<PartData>> fetchPartData() async {
  String jsonString = await rootBundle.loadString('assets/data_parts.json');
  Map<String, dynamic> jsonResponse = json.decode(jsonString);
  return (jsonResponse['value'] as List).cast<Map<String, dynamic>>().map((e) => PartData.fromJson(e)).toList();
}

//Element Data URL Fetch

// Future<List<ElementData>> fetchElementData() async {
//   var url = Uri.parse('https://raw.githubusercontent.com/juzer-index/Precast-assets/main/data_element.json');
//   final response = await http.get(url);
//   if (response.statusCode == 200) {
//     Map<String, dynamic> jsonResponse = json.decode(response.body);
//     return (jsonResponse['value'] as List).cast<Map<String, dynamic>>().map((e) => ElementData.fromJson(e)).toList();
//   } else {
//     throw Exception('Unexpected error occurred!');
//   }
// }

//Element Data local fetch

Future<List<ElementData>> fetchElementData() async {
  String jsonString = await rootBundle.loadString('assets/data_element.json');
  Map<String, dynamic> jsonResponse = json.decode(jsonString);
  return (jsonResponse['value'] as List).cast<Map<String, dynamic>>().map((e) => ElementData.fromJson(e)).toList();
}

class ProjectDetails extends StatefulWidget {
  final int initialTabIndex;
  String? truckDetails;
  ProjectDetails({super.key, required this.initialTabIndex, this.truckDetails});


  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> with SingleTickerProviderStateMixin{

  late TabController _tabController;
  TextEditingController dateController = TextEditingController();
  TextEditingController truckController = TextEditingController();
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();
  TextEditingController projectIdController = TextEditingController();
  TextEditingController deliverySiteController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this); // Change 3 to the number of tabs
    _tabController.index = widget.initialTabIndex;
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              const Text('Project Details', style: TextStyle(color: Colors.white)),
              ClipOval(
                child: Image.network(
                  'https://media.licdn.com/dms/image/D4D03AQFpmZgzpRLrhg/profile-displayphoto-shrink_200_200/0/1692612499698?e=1706140800&v=beta&t=WX4ydCp7VUP7AhXZOIDHIX3D3Ts5KfR-1YJJU6FmalI',
                  height: 35,
                  width: 35,
                ),
              )
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Tab 1',
            ),
            Tab(
              text: 'Tab 2',
            ),
            Tab(
              text: 'Tab 3',
            ),
          ],
        ),
      ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBarView(
              controller: _tabController,
                children: [
                //Tab 1 Content
              Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                              labelText: "Project ID"),
                          items: const [
                            DropdownMenuItem(
                              value: 'Project 1',
                              child: Text('Project 1'),
                            ),
                            DropdownMenuItem(
                              value: 'Project 2',
                              child: Text('Project 2'),
                            ),
                            DropdownMenuItem(
                              value: 'Project 3',
                              child: Text('Project 3'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              //value handler here
                              projectIdController.text = value.toString();
                            });
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: dateController,
                                onTap: () async {
                                  final DateTime? date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2018),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                      dateController.text = "${date.day}/${date.month}/${date.year}";
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Date"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                    labelText: "Delivery Site",
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Site 1',
                                    child: Text('Site 1'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Site 2',
                                    child: Text('Site 2'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Site 3',
                                    child: Text('Site 3'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    //value handler here
                                    deliverySiteController.text = value.toString();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: widget.truckDetails,
                          enabled: false,
                          maxLines: null, // Set to null for unlimited lines
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Truck Details',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                String result = Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddTruckDetails()),
                                ) as String;
                                setState(() {
                                  widget.truckDetails = result.toString();
                                });
                              },
                              child: const Text('Add Truck Details')),
                          ElevatedButton(
                              onPressed: () {
                                if (widget.truckDetails == null) {
                                  showDialog(context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Error'),
                                          content: const Text('Please add truck details'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      }
                                  );
                                }
                                else {
                                  setState(() {
                                    writeProjectDataToJson(projectIdController.text, dateController.text, deliverySiteController.text, widget.truckDetails.toString());
                                    _tabController.animateTo(2);
                                  });
                                }
                              },
                              child: const Text(
                                'Next',
                                style: TextStyle(color: Colors.green),
                              )),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              //Tab 2 Content
              Tab2(),
              //Tab 3 Content
              Tab3(),
            ]),
          ),
        ));
  }
}

class Tab3 extends StatelessWidget {
  const Tab3({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        color: Colors.lightBlue.shade100,
        child: SingleChildScrollView(
          controller: ScrollController(),
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Project ID')),
              DataColumn(label: Text('Delivery Date')),
              DataColumn(label: Text('Delivery Site')),
              DataColumn(label: Text('Truck Details')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Project 1')),
                DataCell(Text('01/01/2021')),
                DataCell(Text('Site 1')),
                DataCell(Text('Truck 1')),
              ]),
              DataRow(cells: [
                DataCell(Text('Project 2')),
                DataCell(Text('02/01/2021')),
                DataCell(Text('Site 2')),
                DataCell(Text('Truck 2')),
              ]),
              DataRow(cells: [
                DataCell(Text('Project 3')),
                DataCell(Text('03/01/2021')),
                DataCell(Text('Site 3')),
                DataCell(Text('Truck 3')),
              ]),
            ]
          ),
        ),
      ),
    );
  }
}

class Tab2 extends StatefulWidget {
  const Tab2({
    super.key,
  });

  @override
  State<Tab2> createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        child: Column(children: [
          //Elements Card
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            color: Colors.lightBlue.shade100,
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Elements',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.44,
                      child: FutureBuilder<List<ElementData>>(
                          future: fetchElementData(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.5,
                                child: Expanded(
                                  child: ListView.builder(itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(snapshot.data![index].elementDesc),
                                    );
                                  },
                                    itemCount: snapshot.data!.length,
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }
                            return const CircularProgressIndicator();
                          }),
                    ),
                    Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.44,

                      child: FutureBuilder<List<ElementData>>(
                          future: fetchElementData(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.5,
                                child: Expanded(
                                  child: ListView.builder(itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(snapshot.data![index].elementDesc),
                                    );
                                  },
                                    itemCount: snapshot.data!.length,
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }
                            return const CircularProgressIndicator();
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          //Parts Card
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            color: Colors.lightBlue.shade100,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Parts',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.44,
                        child: FutureBuilder<List<PartData>>(
                            future: fetchPartData(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.5,
                                  child: ListView.builder(itemBuilder:
                                      (context, index) {
                                    return ListTile(
                                      title: Text(snapshot.data![index].partDesc),
                                    );
                                  },
                                    itemCount: snapshot.data!.length,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Text('${snapshot.error}');
                              }
                              return const CircularProgressIndicator();
                            }),
                      ),
                      Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.44,
                        child: FutureBuilder<List<PartData>>(
                            future: fetchPartData(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.5,
                                  child: ListView.builder(itemBuilder:
                                      (context, index) {
                                    return ListTile(
                                      title: Text(snapshot.data![index].partDesc),
                                    );
                                  },
                                    itemCount: snapshot.data!.length,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Text('${snapshot.error}');
                              }
                              return const CircularProgressIndicator();
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
