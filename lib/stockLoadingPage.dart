import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:precast_demo/addTruckDetails.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';


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

class StockLoading extends StatefulWidget {
  final int initialTabIndex;
  String? truckDetails;
  StockLoading({super.key, required this.initialTabIndex, this.truckDetails});


  @override
  State<StockLoading> createState() => _StockLoadingState();
}

class _StockLoadingState extends State<StockLoading> with SingleTickerProviderStateMixin{

  late TabController _tabController;
  TextEditingController dateController = TextEditingController();
  TextEditingController loadTimeController = TextEditingController();
  TextEditingController truckController = TextEditingController();
  TextEditingController truckDetailsController = TextEditingController();
  String loadTypeValue = '';
  String loadConditionValue = '';
  String inputTypeValue = 'Manual';
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();
  TextEditingController projectIdController = TextEditingController();
  TextEditingController deliverySiteController = TextEditingController();
  List<ElementData> selectedElements = [];
  List<PartData> selectedParts = [];

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');


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
              const Text('Stock Loading', style: TextStyle(color: Colors.white)),
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
              text: 'Detail',
            ),
            Tab(
                text: 'Line',
              ),
            Tab(
              text: 'Summary',
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
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Load Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                                        ),
                                      ),
                                      RadioListTile(
                                        title: const Text('Return Trip'),
                                        value: 'Delivery',
                                        groupValue: loadTypeValue,
                                        onChanged: (value) {
                                          setState(() {
                                            loadTypeValue = value.toString();
                                          });
                                        },
                                      ),
                                      RadioListTile(
                                        title: const Text('Delivery Trip'),
                                        value: 'Return',
                                        groupValue: loadTypeValue,
                                        onChanged: (value) {
                                          setState(() {
                                            loadTypeValue = value.toString();
                                          });
                                        },
                                      ),
                                    ]
                                ),
                              ),
                              Expanded(
                                child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Load Condition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                                        ),
                                      ),
                                      RadioListTile(
                                        title: const Text('External'),
                                        value: 'External',
                                        groupValue: loadConditionValue,
                                        onChanged: (value) {
                                          setState(() {
                                            loadConditionValue = value.toString();
                                          });
                                        },
                                      ),
                                      RadioListTile(
                                        title: const Text('Internal'),
                                        value: 'Internal',
                                        groupValue: loadConditionValue,
                                        onChanged: (value) {
                                          setState(() {
                                            loadConditionValue = value.toString();
                                          });
                                        },
                                      ),
                                      RadioListTile(
                                        title: const Text('Ex-Factory'),
                                        value: 'Ex-Factory',
                                        groupValue: loadConditionValue,
                                        onChanged: (value) {
                                          setState(() {
                                            loadConditionValue = value.toString();
                                          });
                                        },
                                      )
                                    ]
                                ),
                              ),
                            ]
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Load Details',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                          ),
                        ),
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
                                      labelText: "Load Date"),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  onTap: () async {
                                    final TimeOfDay? time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      setState(() {
                                        loadTimeController.text = "${loadTimeController.text} ${time.hour}:${time.minute}";
                                      });
                                    }
                                  },
                                  controller: loadTimeController,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Load Time"),
                                ),
                              )
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "From"),
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
                                        deliverySiteController.text =
                                            value.toString();
                                      });
                                    },
                                  )),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "To"),
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
                                        deliverySiteController.text =
                                            value.toString();
                                      });
                                    },
                                  )),
                            ),
                          ],
                        ),
                        if(loadConditionValue == 'External')
                        Row(
                          children: [
                            Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    // controller: poNumberController,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "PO Num"),
                                  ),
                                )
                              ),
                            Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    // controller: poLineController,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "PO Line"),
                                  ),
                                )
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Truck Details',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: truckDetailsController,
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
                                onPressed: () async {
                                  String truckResult = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const AddTruckDetails()),
                                  ) as String;
                                  setState(() {
                                    truckDetailsController.text = truckResult.toString();
                                  });
                                },
                                child: const Text('Add Truck Details')),
                            ElevatedButton(
                                onPressed: () {
                                  // if (widget.truckDetails == null) {
                                  //   showDialog(context: context,
                                  //       builder: (BuildContext context) {
                                  //         return AlertDialog(
                                  //           title: const Text('Error'),
                                  //           content: const Text('Please add truck details'),
                                  //           actions: [
                                  //             TextButton(
                                  //               onPressed: () {
                                  //                 Navigator.of(context).pop();
                                  //               },
                                  //               child: const Text('OK'),
                                  //             ),
                                  //           ],
                                  //         );
                                  //       }
                                  //   );
                                  // }
                                  setState(() {
                                    _tabController.animateTo(1);
                                  });
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
              ),
              //Tab 2 Content
              SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Input Type',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blue),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: RadioListTile(
                              title: const Text('Manual'),
                              value: 'Manual',
                              groupValue: inputTypeValue,
                              onChanged: (value) {
                                setState(() {
                                  inputTypeValue = value.toString();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              title: const Text('QR Code'),
                              value: 'QR Code',
                              groupValue: inputTypeValue,
                              onChanged: (value) {
                                setState(() {
                                  inputTypeValue = value.toString();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (inputTypeValue == 'Manual')
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ExpansionTile(
                                title: const Text('Elements'),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: FutureBuilder<List<ElementData>>(
                                          future: fetchElementData(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return DataTable(
                                                columns: const [
                                                  DataColumn(
                                                      label:
                                                          Text('Element ID')),
                                                  DataColumn(
                                                      label: Text(
                                                          'Element Description')),
                                                  DataColumn(
                                                      label: Text('Select')),
                                                ],
                                                rows: snapshot.data!
                                                    .map((row) =>
                                                        DataRow(cells: [
                                                          DataCell(Text(
                                                              row.elementId)),
                                                          DataCell(Text(
                                                              row.elementDesc)),
                                                          DataCell(IconButton(
                                                            icon: const Icon(
                                                                Icons.add),
                                                            onPressed: () {
                                                              setState(() {
                                                                selectedElements
                                                                    .add(row);
                                                              });
                                                            },
                                                          )),
                                                        ]))
                                                    .toList(),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text('${snapshot.error}');
                                            }
                                            return const CircularProgressIndicator();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20,),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ExpansionTile(
                                title: const Text('Parts'),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: FutureBuilder<List<PartData>>(
                                          future: fetchPartData(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return DataTable(
                                                columns: const [
                                                  DataColumn(
                                                      label: Text('Part Num')),
                                                  DataColumn(
                                                      label: Text(
                                                          'Part Description')),
                                                  DataColumn(
                                                      label: Text('Select')),
                                                ],
                                                rows: snapshot.data!
                                                    .map((row) =>
                                                        DataRow(cells: [
                                                          DataCell(Text(
                                                              row.partNum)),
                                                          DataCell(Text(
                                                              row.partDesc)),
                                                          DataCell(IconButton(
                                                            icon: const Icon(
                                                                Icons.add),
                                                            onPressed: () {
                                                              setState(() {
                                                                selectedParts
                                                                    .add(row);
                                                              });
                                                            },
                                                          )),
                                                        ]))
                                                    .toList(),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text('${snapshot.error}');
                                            }
                                            return const CircularProgressIndicator();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (inputTypeValue == 'QR Code')
                        Column(children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: QRView(
                              key: qrKey,
                              onQRViewCreated: (controller) {
                                setState(() {
                                  this.controller = controller;
                                });
                                controller.scannedDataStream.listen((scanData) {
                                  setState(() {
                                    result = scanData;
                                  });
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: Center(
                              child: Text(
                                  'Barcode Type: ${describeEnum(result?.format ?? BarcodeFormat.unknown)}   Data: ${result?.code ?? 'Unknown'}'),
                            ),
                          ),
                        ]),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Selected Elements',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Element ID')),
                              DataColumn(label: Text('Element Description')),
                              DataColumn(label: Text('Remove')),
                            ],
                            rows: selectedElements
                                .map((row) => DataRow(cells: [
                                      DataCell(Text(row.elementId)),
                                      DataCell(Text(row.elementDesc)),
                                      DataCell(IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            selectedElements.remove(row);
                                          });
                                        },
                                      )),
                                    ]))
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Selected Parts',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Part Num')),
                              DataColumn(label: Text('Part Description')),
                              DataColumn(label: Text('Remove')),
                            ],
                            rows: selectedParts
                                .map((row) => DataRow(cells: [
                                      DataCell(Text(row.partNum)),
                                      DataCell(Text(row.partDesc)),
                                      DataCell(IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            selectedParts.remove(row);
                                          });
                                        },
                                      )),
                                    ]))
                                .toList(),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _tabController.animateTo(2);
                          });
                        },
                        child: const Text('Next'),
                      )
                    ]),
              ),
              //Tab 3 Content
              SingleChildScrollView(
                controller: ScrollController(),
                child: Center(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Project Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          enabled: false,
                          initialValue: projectIdController.text,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: "Project ID"),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                enabled: false,
                                initialValue: loadTimeController.text,
                                decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: "Load Date"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                enabled: false,
                                initialValue: loadTimeController.text,
                                decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: "Load Time"),
                              ),
                            )
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  enabled: false,
                                  initialValue: deliverySiteController.text,
                                  decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: "From"),
                                ),
                              )
                          ),
                          Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  enabled: false,
                                  initialValue: deliverySiteController.text,
                                  decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: "To"),
                                ),
                              )
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Truck Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          enabled: false,
                          controller: truckDetailsController,
                          maxLines: null, // Set to null for unlimited lines
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Selected Elements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Element ID')),
                              DataColumn(label: Text('Element Description')),
                            ],
                            rows: selectedElements.map((row) => DataRow(
                                cells: [
                                  DataCell(Text(row.elementId)),
                                  DataCell(Text(row.elementDesc)),
                                ]
                            )).toList(),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Selected Parts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Part Num')),
                              DataColumn(label: Text('Part Description')),
                            ],
                            rows: selectedParts.map((row) => DataRow(
                                cells: [
                                  DataCell(Text(row.partNum)),
                                  DataCell(Text(row.partDesc)),
                                ]
                            )).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Success'),
                                    content: const Text('Stock Loading details saved successfully, LoadID: ID-L1'),
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
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.green),
                          )),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ));
  }
}


