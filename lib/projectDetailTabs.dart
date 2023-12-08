import 'package:flutter/material.dart';
import 'package:precast_demo/addTruckDetails.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

Future<List<PartData>> fetchPartData() async {
  var url = Uri.parse('https://raw.githubusercontent.com/juzer-index/Precast-assets/main/data_parts.json');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return (jsonResponse['value'] as List).cast<Map<String, dynamic>>().map((e) => PartData.fromJson(e)).toList();
  } else {
    throw Exception('Unexpected error occurred!');
  }
}

Future<List<ElementData>> fetchElementData() async {
  var url = Uri.parse('https://raw.githubusercontent.com/juzer-index/Precast-assets/main/data_element.json');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return (jsonResponse['value'] as List).cast<Map<String, dynamic>>().map((e) => ElementData.fromJson(e)).toList();
  } else {
    throw Exception('Unexpected error occurred!');
  }
}

class ProjectDetails extends StatefulWidget {
  final int initialTabIndex;
  const ProjectDetails({super.key, required this.initialTabIndex});


  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> with SingleTickerProviderStateMixin{

  late TabController _tabController;
  TextEditingController dateController = TextEditingController();
  late DateTime _selectedDate;

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
                //First Tab widget
              Center(
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
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddTruckDetails()),
                              );
                            },
                            child: const Text('Add Truck Details')),
                        ElevatedButton(
                            onPressed: () {},
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
              //Second Tab widget
              SingleChildScrollView(
                child: SizedBox(
                  child: Column(children: [
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
                                    child: Text('Elements',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            FutureBuilder<List<ElementData>>(
                                future: fetchElementData(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height *
                                            0.5,
                                        child: DataTable(
                                          columns: const [
                                            DataColumn(label: Text('Element ID')),
                                            DataColumn(
                                                label: Text('Element Description')),
                                          ],
                                          rows: snapshot.data!.map((element) {
                                            return DataRow(cells: [
                                              DataCell(Text(element.elementId)),
                                              DataCell(Text(element.elementDesc)),
                                            ]);
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('${snapshot.error}');
                                  }
                                  return const CircularProgressIndicator();
                                }),
                          ],
                        ),
                      ),
                    ),
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
                            const Divider(),
                            FutureBuilder<List<PartData>>(
                                future: fetchPartData(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height *
                                            0.5,
                                        child: DataTable(
                                          columns: const [
                                            DataColumn(label: Text('Part ID')),
                                            DataColumn(
                                                label: Text('Part Description')),
                                          ],
                                          rows: snapshot.data!.map((part) {
                                            return DataRow(cells: [
                                              DataCell(Text(part.partNum)),
                                              DataCell(Text(part.partDesc)),
                                            ]);
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('${snapshot.error}');
                                  }
                                  return const CircularProgressIndicator();
                                }),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              //Third Tab Widget
              SizedBox(
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
                      rows: const [],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ));
  }
}
