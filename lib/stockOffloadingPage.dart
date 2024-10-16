import 'dart:convert';
import 'dart:io';
import 'dart:async';


import 'package:GoCastTrack/truckDetails.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'elementTable.dart';
import 'partTable.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'elementSearchForm.dart';
import 'load_model.dart';
import 'part_model.dart';
import 'element_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'PdfViewer.dart';



class StockOffloading extends StatefulWidget {
  final int initialTabIndex;
  final dynamic tenantConfig;
  const StockOffloading({super.key, required this.initialTabIndex, required this.tenantConfig});

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
  bool offloaded = false;
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

  //final String username = 'manager';
  //final String password = 'Adp@2023';

  LoadData? offloadData;

  bool loaded = false;
  bool elementsAndPartsLoaded = false;
  bool isPrinting = false ;
  int pdfCount =0;

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');




  Future<bool> submitReport() async {
    dynamic body={
      "ds": {
        "extensionTables": [],
        "BAQReportParam": [
          {
            "Summary": false,
            "BAQRptID": "",
            "ReportID": "IIT_Delivery",
            "Option01": loadIDController.text,
            "SysRowID": "00000000-0000-0000-0000-000000000000",
            "AutoAction": "SSRSGenerate",
            "PrinterName": "Microsoft Print to PDF",
            "AgentSchedNum": 0,
            "AgentID": "",
            "AgentTaskNum": 0,
            "RecurringTask": false,
            "RptPageSettings": "Color=True,Landscape=False,AutoRotate=False,PaperSize=[Kind=\"Custom\" PaperName=\"Custom\" Height=0 Width=0],PaperSource=[SourceName=\"Automatically Select\" Kind=\"Custom\"],PrinterResolution=[]",
            "RptPrinterSettings": "PrinterName=\"Microsoft Print to PDF\",Copies=1,Collate=False,Duplex=Default,FromPage=1,ToPage=0",
            "RptVersion": "",
            "ReportStyleNum": 1,
            "WorkstationID": "web_Manager",
            "AttachmentType": "PDF",
            "ReportCurrencyCode": "USD",
            "ReportCultureCode": "en-US",
            "SSRSRenderFormat": "PDF",
            "UIXml": "",
            "PrintReportParameters": false,
            "SSRSEnableRouting": false,
            "DesignMode": false,
            "RowMod": "A"
          }
        ],
      },
      "agentID": "",
      "agentSchedNum": 0,
      "agentTaskNum": 0,
      "maintProgram": "Ice.UIRpt.IIT_Delivery"
    };
    final String basicAuth = 'Basic ${base64Encode(
        utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';
    try {
      final submitReportURL = Uri.parse('${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Ice.RPT.BAQReportSvc/TransformAndSubmit');
      final response = await http.post(
          submitReportURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(body)
      );
      if(response.statusCode == 200){
        return true;
      }
      else {
        return false;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<void> fetchLoadDataFromURL() async {
    final loadURL = Uri.parse('${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/GetByID');
    Map<String, dynamic> body = {
      "key1": loadIDController.text,
      "key2": "",
      "key3": "",
      "key4": "",
      "key5": ""
    };
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';

    Completer<void> completer = Completer<void>();

    try {
      final response = await http.post(
          loadURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(body)
      );

      if(response.statusCode == 200){
        final jsonResponse = json.decode(response.body);

        setState(() {
          loadData = jsonResponse['returnObj'];
          loadValue = loadData['UD104'];

          elementValue = loadData['UD104A']?.where((element) =>
          element['CheckBox13'] == false).toList();
          partValue = loadData['UD104A']?.where((part) =>
          part['CheckBox13'] == true).toList();
          arrivedElements = elementValue.map((e) => ElementData.fromJson(e)).toList();
          arrivedParts = partValue.map((e) => PartData.fromJson(e)).toList();
        });

        // Resolve the completer when the states are set
        completer.complete();
      }
      else {
        debugPrint('Load Data Fetch Failed');
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    // Return the future associated with the completer
    return completer.future;
  }

  LoadData? getLoadObjectFromJson(String loadID) {
    if (loadValue.isNotEmpty){
      LoadData loadObject = LoadData.fromJson(loadValue.where((element) => element['Key1'] == loadID).first);
      return loadObject;
    }
    return null;
  }

  Future<dynamic> fetchPDFCounts() async {
    final String basicAuth = 'Basic ${base64Encode(
        utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';
    try {

      final pdfCountsURL = Uri.parse('${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/BaqSvc/IIT_getDN2/?%24orderby=SysRptLst_CreatedOn%20desc&%24top=1');

      final response = await http.get(
          pdfCountsURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse['value'];
      }
      else {
        return null;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> fetchElementDataFromURL() async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';
    try {
      final detailsURL = Uri.parse('${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/UD104As');
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
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';
    try {
      final detailsURL = Uri.parse('${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/UD104As');
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
    final loadURL = Uri.parse('${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/UD104s');
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';
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
          offloaded = true;
        });
      }
      else {
        debugPrint('Load Status Update Failed');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<Uint8List> deliveryNote(String base64String) async {
    Uint8List decodedBytes = base64.decode(base64String);
    final pdf = pw.Document();
    final directory = await getApplicationDocumentsDirectory();
    final output = File('${directory.path}/DeliveryNote${loadIDController.text}.pdf');

    await pdf.save();
    await output.writeAsBytes(decodedBytes, flush: true);

    return output.readAsBytesSync();
  }


  Future<void> updateUD104A(Map<String, dynamic> UD104AData ,String ChildKey) async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';
    try {
      final detailsURL = Uri.parse('${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/UD104As(${widget.tenantConfig['company']},${loadIDController.text},,,,,$ChildKey,,,,)');
      final response = await http.patch(
          detailsURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(UD104AData)
      );
      if(response.statusCode == 204){
        setState(() {
          elementsAndPartsLoaded = true;
        });
      }
      else {
        debugPrint('UD104A Update Failed');
        debugPrint(response.body);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateStatusOnSite (String partNum, String elementId) async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';
    final response = await http.post(
        Uri.parse('${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates'),
        headers: {
          HttpHeaders.authorizationHeader: basicAuth,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({
          "Company": "${widget.tenantConfig['company']}",
          "PartNum": partNum,
          "LotNum": elementId,
          "ElementStatus_c": "OnSite"
        })
    );
    if(response.statusCode == 201){
      debugPrint('Status Updated');
    }
    else {
      debugPrint('Status Update Failed');
      debugPrint(response.body);
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
   /* fetchLoadDataFromURL();
    fetchElementDataFromURL();*/
    super.initState();
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).shadowColor,
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
        actions: const [
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
      body:isPrinting? const Center(child: CircularProgressIndicator(),)
          :Padding(
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
                           Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Load Details',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).canvasColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: loadIDController,
                                    decoration:  InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).canvasColor),
                                      ),
                                      label: Text('Load ID'),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await fetchLoadDataFromURL();
    /*                                await fetchElementDataFromURL();
                                    await fetchPartDataFromURL();*/
                                    /*await fetchElementANDPartsDataFromURL();*/
                                    String projectLoadID = loadIDController.text;
                                    offloadData = getLoadObjectFromJson(projectLoadID);
    /*                                getElementObjectFromJson(projectLoadID);
                                    getPartObjectFromJson(projectLoadID);*/
                                    if (offloadData != null) {
                                      if(offloadData!.loadStatus == 'Closed'){
                                        offloaded = true;
                                        if(mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('Warning'),
                                                content: const Text('This Load has already been delivered'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child:  Text('Close',style: TextStyle(color:Theme.of(context).canvasColor)),
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
                                  icon:  Icon(
                                    Icons.search,
                                    color: Theme.of(context).canvasColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:  EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: projectIDController,
                              enabled: false,
                              decoration:  InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).canvasColor),
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
                              decoration:  InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).canvasColor),
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
                                    decoration:  InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).canvasColor),
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
                                    decoration:  InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).canvasColor),
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
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Load Type',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Theme.of(context).canvasColor),
                                      ),
                                    ),
                                    AbsorbPointer(
                                      child: RadioListTile(
                                        title: Text('Return Trip', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)),
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
                                        title: Text('Delivery Trip', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)),
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Load Condition',
                                          style:  TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Theme.of(context).canvasColor),
                                      ),
                                    ),
                                    AbsorbPointer(
                                      child: RadioListTile(
                                        title: Text('External', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)),
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
                                        title: Text('Internal', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)),
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
                                        title: Text('Ex-Factory', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)),
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
                           Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Truck Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).canvasColor),),
                          ),
                          TruckDetailsForm(isEdit: false, truckDetails: offloadData,
                          tenantConfigP: widget.tenantConfig,
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
                               Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Verify Elements',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context).canvasColor),
                                ),
                              ),
                              const SizedBox(height: 10,),
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).indicatorColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElementSearchForm(
                                    isInstalling: false,
                                    onElementsSelected: updateElementInformation, arrivedElements: arrivedElements, isOffloading: true,AddElement:(ElementData)=>{}, tenantConfig: widget.tenantConfig,),
                                ),
                              ),
                              const SizedBox(height: 20,),
                            ],
                          ),


                           Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Arrived Elements',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).canvasColor),
                            ),
                          ),
                          ElementTable(selectedElements: selectedElements),
                          const SizedBox(
                            height: 20,
                          ),
                           Text(
                            'Arrived Parts',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).canvasColor),
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
                    Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Review',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).canvasColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: loadIDController,
                            enabled: false,
                            decoration:  InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).canvasColor),
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
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).canvasColor),
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
                            decoration:  InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).canvasColor),
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
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).canvasColor),
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
                                  decoration:  InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).canvasColor),
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
                                  decoration:  InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).canvasColor),
                                    ),
                                    label: Text('To Bin'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20,),
                    Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Truck Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).canvasColor),),
                        ),
                        TruckDetailsForm(isEdit: false, truckDetails: offloadData,
                        tenantConfigP: widget.tenantConfig,
                        ),
                        const SizedBox(height: 20,),
                        Text(
                          'Arrived Elements',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).canvasColor),
                        ),

                        ElementTable(selectedElements: selectedElements),
                        const SizedBox(
                          height: 20,
                        ),
                         Text(
                          'Arrived Parts',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).canvasColor),
                        ),

                        PartTable(selectedParts: arrivedParts),
                        const SizedBox(
                          height: 20,
                        ),
                        offloaded? ElevatedButton(
                            onPressed: () async {
                          setState(() {
                            isPrinting = true;
                          });
                          fetchPDFCounts().then((count) {
                            if (count!=null&&count.isNotEmpty) {
                              setState(() {
                                pdfCount = count[0]['Calculated_Count'];

                              });
                            }
                              submitReport().then((value) async  {
                                if (value != false) {
                                  for (int i = 0; i < 3; i++) {
                                    await Future.delayed(const Duration(seconds: 2));
                                    var updatedCounts = await fetchPDFCounts();
                                    if (updatedCounts != null &&
                                        updatedCounts[0]['Calculated_Count'] > pdfCount) {
                                      setState(() {
                                        isPrinting = false;
                                      });
                                      if (mounted) {
                                        Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => PdfViewerPage(
                                                          filePath:
                                                              'DeliveryNote${loadIDController.text}.pdf',
                                                          generatePdf: deliveryNote(
                                                              updatedCounts[0]['SysRptLst_RptData']))));
                                      }
                                            break; // Exit the loop if condition is met
                                    }
                                    if(i==2){
                                      isPrinting = false;
                                      if (mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Error'),
                                              content: const Text('Failed to Generate Delivery Note'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child:  Text('Close',style: TextStyle(color:Theme.of(context).canvasColor)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }
                                  }

                                }
                              });

                          });

                        }, child: const Text('Generate Delivery Note')):
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
                                          child:  Text('Close',style: TextStyle(color:Theme.of(context).canvasColor)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                            else {
                              final loadDateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
                              debugPrint(selectedElements.toString());
                             for (var v = 0; v < selectedElements.length; v++) {
                                await updateUD104A({

                                  "CheckBox01": true,
                                  "CheckBox02": true,
                                  "CheckBox03": false,
                                  "CheckBox05": false,
                                  "Date02": loadDateFormat,
                                },

                                selectedElements[v].ChildKey1);
                                await updateStatusOnSite(selectedElements[v].partId, selectedElements[v].elementId);
                                debugPrint(selectedElements[v].elementId);
                              }
                              for (var v = 0; v < arrivedParts.length; v++) {
                                await updateUD104A({
                                  "Key1": loadIDController.text,
                                  "Character01": arrivedParts[v].partNum,
                                  "Company": '${widget.tenantConfig['company']}',
                                  "CheckBox01": true,
                                  "CheckBox02": false,
                                  "CheckBox03": false,
                                  "CheckBox05": false,
                                },
                                "1");



                                debugPrint(arrivedParts[v].partNum);
                              }
                              await updateLoadStatus({
                                "Key1": loadIDController.text,
                                "Company": widget.tenantConfig['company'],
                                "ShortChar03": loadStatus,
                              });
                            }
                            if(loaded /*&& elementsAndPartsLoaded*/){
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
                              setState(() {
                                offloaded = true;
                              });
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('warning'),
                                      content: const Text('Some Elements and Parts could not be offloaded'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child:  Text('Close',style: TextStyle(color:Theme.of(context).canvasColor)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                            if (!loaded /*&& !elementsAndPartsLoaded*/){
                              if(mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text('Load could not be offloaded'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child:  Text('Close',style: TextStyle(color:Theme.of(context).canvasColor)),
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







