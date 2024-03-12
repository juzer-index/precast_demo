import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:precast_demo/elementTable.dart';
import 'package:precast_demo/partTable.dart';
import 'package:precast_demo/stockLoadingPage.dart';
import 'package:precast_demo/truckDetails.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'elementSearchForm.dart';
import 'load_model.dart';
import 'part_model.dart';
import 'element_model.dart';

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
  TextEditingController offloadDateController = TextEditingController();
  String _selectedDate = '';
  late TabController _tabController;
  String loadTypeValue = '';
  String loadConditionValue = '';
  String loadStatus = '';
  String inputTypeValue = 'Manual';
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> loadData = {};
  List<dynamic> loadValue = [];

  Map<String, dynamic> elementData = {};
  List<dynamic> elementValue = [];
  List<ElementData> arrivedElements = [];
  List<ElementData> selectedElements = [];

  Map<String, dynamic> partData = {};
  List<dynamic> partValue = [];
  List<PartData> arrivedParts = [];

  final String username = 'manager';
  final String password = 'manager';

  LoadData? offloadData;

  bool loaded = false;
  bool elementsAndPartsLoaded = false;

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final loadURL = Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/Ice.BO.UD103Svc/UD103s');
  final detailsURL = Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/Ice.BO.UD103Svc/UD103As');

  Future<void> fetchLoadDataFromURL() async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    try {
      final response = await http.get(
          loadURL,
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

  LoadData? getLoadObjectFromJson(String loadID) {
    if (loadValue.isNotEmpty){
      LoadData loadObject = LoadData.fromJson(loadValue.where((element) => element['Key1'] == loadID).first);
      return loadObject;
    }
    return null;
  }

  Future<void> fetchElementDataFromURL() async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    try {
      final response = await http.get(
          detailsURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      final jsonResponse = json.decode(response.body);
      setState(() {
        elementData = jsonResponse;
        elementValue = elementData['value'].where((element) => element['CheckBox13'] == false).toList();
      });
      debugPrint(elementValue.toString());
      return jsonResponse;
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  ElementData? getElementObjectFromJson(String loadID) {
    if (elementValue.isNotEmpty){
      var matchingElement = elementValue.where((element) => element['Key1'] == loadID).toList();
      ElementData? elementObject;
      if (matchingElement.isNotEmpty){
        for (var v = 0; v<matchingElement.length; v++) {
          elementObject = ElementData.fromJson(matchingElement[v]);
          debugPrint(elementObject.elementId);
          arrivedElements.add(elementObject);
        }
      }
    }
    return null;
  }

  Future<void> fetchPartDataFromURL() async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    try {
      final response = await http.get(
          detailsURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      final jsonResponse = json.decode(response.body);
      setState(() {
        partData = jsonResponse;
        partValue = partData['value'].where((part) => part['CheckBox13'] == true).toList();
      });
      return jsonResponse;
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  PartData? getPartObjectFromJson(String loadID) {
    if (partValue.isNotEmpty){
      var matchingPart = partValue.where((part) => part['Key1'] == loadID).toList();
      if (matchingPart.isNotEmpty){
        for (var v = 0; v<matchingPart.length; v++) {
          PartData partObject = PartData.fromJson(matchingPart[v]);
          arrivedParts.add(partObject);
        }
      }
    }
    return null;
  }

  Future<void> updateLoadStatus(Map<String, dynamic> statusData) async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    try {
      final response = await http.post(
          loadURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        body: jsonEncode(statusData)
      );
      if(response.statusCode == 201){
        debugPrint('Load Status Updated');
        setState(() {
          loaded = true;
        });
      }
      else {
        debugPrint('Load Status Update Failed');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateUD103A(Map<String, dynamic> ud103AData) async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    try {
      final response = await http.post(
          detailsURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(ud103AData)
      );
      if(response.statusCode == 201){
        setState(() {
          elementsAndPartsLoaded = true;
        });
      }
      else {
        debugPrint('UD103A Update Failed');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void updateElementInformation(List<ElementData> selectedElementsFromForm, List<PartData> selectedPartsFromForm){
    setState(() {
      selectedElements = selectedElementsFromForm;
      arrivedParts = selectedPartsFromForm;
    });
  }


  @override
  void initState() {
    _tabController =
        TabController(length: 3, vsync: this); // Change 3 to the number of tabs
    _tabController.index = widget.initialTabIndex;
    fetchLoadDataFromURL();
    fetchElementDataFromURL();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(),
              Text('Stock Offloading',
                  style: TextStyle(color: Colors.white)),
              // ClipOval(
              //   child: Image.network(
              //     'https://media.licdn.com/dms/image/D4D03AQFpmZgzpRLrhg/profile-displayphoto-shrink_800_800/0/1692612499698?e=1711584000&v=beta&t=Ho-Wta1Gpc-aiWZMJrsni_83CG16TQeq_gtbIJBM7aI',
              //     height: 35,
              //     width: 35,
              //   ),
              // )
            ],
          ),
        ),
        actions:[
          PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.create_new_folder),
                    title: const Text('Create New Load'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StockOffloading(initialTabIndex: 0,)));
                    },
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.edit_calendar),
                    title: const Text('Edit a Load'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StockLoading(initialTabIndex: 0, isUpdate: true)));
                    },
                  ),
                ),
              ],
          )
        ],
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
                                await fetchElementDataFromURL();
                                await fetchPartDataFromURL();
                                String projectLoadID = loadIDController.text;
                                offloadData = getLoadObjectFromJson(projectLoadID);
                                getElementObjectFromJson(projectLoadID);
                                getPartObjectFromJson(projectLoadID);
                                if (offloadData != null) {
                                  if(offloadData!.loadStatus == 'Closed'){
                                    if(mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Error'),
                                            content: const Text('This Load has already been delivered'),
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
                                  }
                                  setState(() {
                                    projectIDController.text = offloadData!.projectId;
                                    loadDateController.text = offloadData!.loadDate;
                                    toWarehouseController.text = offloadData!.toWarehouse;
                                    toBinController.text = offloadData!.toBin;
                                    loadTypeValue = offloadData!.loadType;
                                    loadConditionValue = offloadData!.loadCondition;
                                  });
                                }
                                else {
                                  if(mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Error'),
                                          content: const Text(
                                              'Load ID not found'),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: offloadDateController,
                          onTap: () async {
                            final DateTime? date = await showDatePicker(
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary :Theme.of(context).primaryColor,
                                      background: Colors.white,
                                      secondary: Theme.of(context).primaryColor,
                                      outline: Colors.cyanAccent,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2018),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                offloadDateController.text =
                                "${date.day}/${date.month}/${date
                                    .year}";
                                _selectedDate = DateFormat('yyyy-MM-dd').format(date);
                              });
                            }
                          },
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "OffLoad Date"),
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
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Truck Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),),
                      ),
                      TruckDetailsForm(isEdit: false, truckDetails: offloadData,),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _tabController.animateTo(1);
                          });
                        },
                        child: const Text('Next'),
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
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Verify Elements',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElementSearchForm(onElementsSelected: updateElementInformation, arrivedElements: arrivedElements, isOffloading: true,),
                            ),
                          ),
                          const SizedBox(height: 20,),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Arrived Elements',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blue),
                        ),
                      ),
                      ElementTable(selectedElements: selectedElements),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Arrived Parts',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue),
                      ),
                      PartTable(selectedParts: arrivedParts),
                      const SizedBox(height: 20,),
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
                          border: OutlineInputBorder(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: offloadDateController,
                        enabled: false,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          label: Text('Offload Date'),
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
                    const SizedBox(height: 20,),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Truck Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),),
                    ),
                    TruckDetailsForm(isEdit: false, truckDetails: offloadData,),
                    const SizedBox(height: 20,),
                    const Text(
                      'Arrived Elements',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue),
                    ),
                    ElementTable(selectedElements: selectedElements),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Arrived Parts',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue),
                    ),
                    PartTable(selectedParts: arrivedParts),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if(offloadData!.loadStatus == 'Closed'){
                          null;
                        }
                        setState(() {
                          loadStatus = 'Closed';
                        });
                        if(offloadData!.loadStatus == 'Closed'){
                          if(mounted) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Load Already Offloaded'),
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
                        }
                        else {
                          await updateLoadStatus({
                            "Key1": loadIDController.text,
                            "Company": 'EPIC06',
                            "ShortChar03": loadStatus,
                          });
                          final loadDateFormat = '${_selectedDate}T00:00:00';
                          for (var v = 0; v < selectedElements.length; v++) {
                            await updateUD103A({
                              "Key1": loadIDController.text,
                              "Character01": selectedElements[v].elementId,
                              "Company": 'EPIC06',
                              "CheckBox02": true,
                              "Date10": loadDateFormat,
                            });
                            debugPrint(selectedElements[v].elementId);
                          }
                          for (var v = 0; v < arrivedParts.length; v++) {
                            await updateUD103A({
                              "Key1": loadIDController.text,
                              "Character01": arrivedParts[v].partNum,
                              "Company": 'EPIC06',
                              "CheckBox02": true,
                            });
                            debugPrint(arrivedParts[v].partNum);
                          }
                        }
                        if(loaded && elementsAndPartsLoaded){
                          if(mounted) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Success'),
                                  content: const Text('Load Offloaded'),
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
                        }
                        if(loaded && !elementsAndPartsLoaded){
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Success'),
                                  content: const Text('Load Offloaded'),
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
                        }
                        if (!loaded && !elementsAndPartsLoaded){
                          if(mounted) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Error', style: TextStyle(color: Colors.red),),
                                  content: const Text('Offload Failed'),
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
                        }
                      },
                      child: const Text('Offload Items'),
                    ),
                  ],
                ),
              ),
            ])
      )
    );
  }
}
