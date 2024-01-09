import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'load_model.dart';



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

Future<List<PartData>> fetchPartData() async {
  String jsonString = await rootBundle.loadString('assets/data_parts.json');
  Map<String, dynamic> jsonResponse = json.decode(jsonString);
  return (jsonResponse['value'] as List).cast<Map<String, dynamic>>().map((e) => PartData.fromJson(e)).toList();
}

Future<List<ElementData>> fetchElementData() async {
  String jsonString = await rootBundle.loadString('assets/data_element.json');
  Map<String, dynamic> jsonResponse = json.decode(jsonString);
  return (jsonResponse['value'] as List).cast<Map<String, dynamic>>().map((e) => ElementData.fromJson(e)).toList();
}


class StockOffloading extends StatefulWidget {
  final int initialTabIndex;

  const StockOffloading({super.key, required this.initialTabIndex});

  @override
  State<StockOffloading> createState() => _StockOffloadingState();
}

class _StockOffloadingState extends State<StockOffloading>
    with SingleTickerProviderStateMixin {
  TextEditingController loadIDController = TextEditingController();
  TextEditingController projectIDController = TextEditingController();
  TextEditingController loadDateController = TextEditingController();
  TextEditingController toWarehouseController = TextEditingController();
  TextEditingController toBinController = TextEditingController();
  late TabController _tabController;
  String loadTypeValue = '';
  String loadConditionValue = '';
  String inputTypeValue = 'Manual';
  final _formKey = GlobalKey<FormState>();
  List<ElementData> selectedElements = [];
  List<PartData> selectedParts = [];
  Map<String, dynamic> loadData = {};
  List<dynamic> loadValue = [];

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Future<void> fetchLoadDataFromURL() async {

    final url = Uri.parse('https://77.92.189.102/IITPrecastVertical/api/v1/Ice.BO.UD103Svc/UD103s');
    final String username = 'manager';
    final String password = 'manager';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    try {
      final response = await http.get(
          url,
        headers: {
          HttpHeaders.authorizationHeader: basicAuth,
          HttpHeaders.contentTypeHeader: 'application/json',
        }
      );
      final jsonResponse = json.decode(response.body);
      setState(() {
        loadData = jsonResponse;
        loadValue = loadData['value'];
      });
      return jsonResponse;
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

  }

  Future<void> fetchOffloadData() async {
    final jsonString = await rootBundle.loadString('assets/OffloadProjects.json');
    setState(() {
      loadData = json.decode(jsonString);
    });
  }

  LoadData? getLoadObjectFromJson(String loadID) {
    if (loadValue.isNotEmpty){
      LoadData loadObject = LoadData.fromJson(loadValue.where((element) => element['Key1'] == loadID).first);
      debugPrint(loadObject.toString());
      return loadObject;
    }
    return null;
  }

  @override
  void initState() {
    _tabController =
        TabController(length: 3, vsync: this); // Change 3 to the number of tabs
    _tabController.index = widget.initialTabIndex;
    fetchLoadDataFromURL();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              const Text('Stock Offloading',
                  style: TextStyle(color: Colors.white)),
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
              text: 'Header',
            ),
            Tab(
              text: 'Details',
            ),
            Tab(
              text: 'Review',
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
                    child: Column(children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Load Type',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue),
                                  ),
                                ),
                                AbsorbPointer(
                                  child: RadioListTile(
                                    title: const Text('Return Trip'),
                                    value: 'Return',
                                    groupValue: loadTypeValue,
                                    onChanged: (value) {
                                      setState(() {
                                        loadTypeValue = value.toString();
                                      });
                                    },
                                  ),
                                ),
                                AbsorbPointer(
                                  child: RadioListTile(
                                    title: const Text('Delivery Trip'),
                                    value: 'Issue Load',
                                    groupValue: loadTypeValue,
                                    onChanged: (value) {
                                      setState(() {
                                        loadTypeValue = value.toString();
                                      });
                                    },
                                  ),
                                ),
                              ]),
                            ),
                            Expanded(
                              child: Column(children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Load Condition',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue),
                                  ),
                                ),
                                AbsorbPointer(
                                  child: RadioListTile(
                                    title: const Text('External'),
                                    value: 'External',
                                    groupValue: loadConditionValue,
                                    onChanged: (value) {
                                      setState(() {
                                        loadConditionValue = value.toString();
                                      });
                                    },
                                  ),
                                ),
                                AbsorbPointer(
                                  child: RadioListTile(
                                    title: const Text('Internal'),
                                    value: 'Internal Truck',
                                    groupValue: loadConditionValue,
                                    onChanged: (value) {
                                      setState(() {
                                        loadConditionValue = value.toString();
                                      });
                                    },
                                  ),
                                ),
                                AbsorbPointer(
                                  child: RadioListTile(
                                    title: const Text('Ex-Factory'),
                                    value: 'Ex-Factory',
                                    groupValue: loadConditionValue,
                                    onChanged: (value) {
                                      setState(() {
                                        loadConditionValue = value.toString();
                                      });
                                    },
                                  ),
                                )
                              ]),
                            ),
                          ]),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Load Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blue),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: loadIDController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  label: Text('Load ID'),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await fetchLoadDataFromURL();
                                String projectLoadID = loadIDController.text;
                                LoadData? offloadData = getLoadObjectFromJson(projectLoadID);
                                debugPrint(offloadData.toString());
                                if (offloadData != null) {
                                  setState(() {
                                    projectIDController.text = offloadData.projectId;
                                    loadDateController.text = offloadData.loadDate;
                                    toWarehouseController.text = offloadData.toWarehouse;
                                    toBinController.text = offloadData.toBin;
                                    loadTypeValue = offloadData.loadType;
                                    loadConditionValue = offloadData.loadCondition;
                                  });
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Error'),
                                        content: const Text('Load ID not found'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.search,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: projectIDController,
                          enabled: false,
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            label: Text('Project ID'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: loadDateController,
                          enabled: false,
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            label: Text('Load Date'),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: toWarehouseController,
                                enabled: false,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  label: Text('To Warehouse'),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: toBinController,
                                enabled: false,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  label: Text('To Bin'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _tabController.animateTo(1);
                          });
                        },
                        child: const Text('Unload Items'),
                      ),
                    ]),
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
                                title: const Text('Arrived Elements'),
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
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ExpansionTile(
                                title: const Text('Arrived Parts'),
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
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Review',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: loadIDController,
                        enabled: false,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          label: Text('Load ID'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: projectIDController,
                        enabled: false,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          label: Text('Project ID'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: loadDateController,
                        enabled: false,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          label: Text('Load Date'),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: toWarehouseController,
                              enabled: false,
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                label: Text('To Warehouse'),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: toBinController,
                              enabled: false,
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                label: Text('To Bin'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                          ],
                          rows: selectedElements
                              .map((row) => DataRow(cells: [
                                    DataCell(Text(row.elementId)),
                                    DataCell(Text(row.elementDesc)),
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
                          ],
                          rows: selectedParts
                              .map((row) => DataRow(cells: [
                                    DataCell(Text(row.partNum)),
                                    DataCell(Text(row.partDesc)),
                                  ]))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _tabController.animateTo(0);
                        });
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ])
      )
    );
  }
}
