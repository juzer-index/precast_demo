import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:IIT_precast_app/elementTable.dart';
import 'package:IIT_precast_app/partTable.dart';
import 'package:IIT_precast_app/stockLoadingPage.dart';
import 'package:IIT_precast_app/truckDetails.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'elementSearchForm.dart';
import 'load_model.dart';
import 'part_model.dart';
import 'element_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'PdfViewer.dart';
import 'package:image/image.dart' as img;



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
  bool Offloaded = false;
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
  final String password = 'Adp@2023';

  LoadData? offloadData;

  bool loaded = false;
  bool elementsAndPartsLoaded = false;
  bool isPrinting = false ;
  int PDFCount =0;

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final detailsURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD103Svc/UD103As');



  Future<bool> submitReport() async {
    dynamic body={
      "ds": {
        "extensionTables": [],
        "BAQReportParam": [
          {
            "Summary": false,
            "BAQRptID": "",
            "ReportID": "IIT_DeliveryNot",
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
            "ReportStyleNum": 1002,
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
        "ReportStyle": [
          {
            "Company": "158095",
            "ReportID": "IIT_DeliveryNot",
            "StyleNum": 1002,
            "StyleDescription": "Delivery Note Report - SSRS",
            "RptTypeID": "SSRS",
            "PrintProgram": "Reports/CustomReports/IIT_DeliveryNot/IIT_Delivery_v2",
            "PrintProgramOptions": "",
            "RptDefID": "IIT_DeliveryNot",
            "CompanyList": "158095",
            "ServerNum": 0,
            "OutputLocation": "Database",
            "OutputEDI": "",
            "SystemFlag": false,
            "CGCCode": "",
            "SysRevID": 93280823,
            "SysRowID": "724b1ca9-4a67-4db8-840a-24b73be01b80",
            "RptCriteriaSetID": null,
            "RptStructuredOutputDefID": null,
            "StructuredOutputEnabled": false,
            "RequireSubmissionID": false,
            "AllowResetAfterSubmit": false,
            "CertificateID": null,
            "LangNameID": "",
            "FormatCulture": "",
            "StructuredOutputCertificateID": null,
            "StructuredOutputAlgorithm": null,
            "HasBAQOrEI": false,
            "RoutingRuleEnabled": false,
            "CertificateIsAllComp": false,
            "CertificateIsSystem": false,
            "CertExpiration": null,
            "Status": 0,
            "StatusMessage": "",
            "RptDefSystemFlag": false,
            "LangNameIDDescription": "",
            "IsBAQReport": false,
            "StructuredOutputCertificateIsAllComp": false,
            "StructuredOutputCertificateIsSystem": false,
            "StructuredOutputCertificateExpirationDate": null,
            "AllowGenerateEDI": false,
            "BitFlag": 0,
            "ReportRptDescription": "",
            "RptDefRptDescription": "",
            "RptTypeRptTypeDescription": "",
            "RowMod": "",
            "SSRSRenderFormat": "PDF"
          }

        ]
      },
      "agentID": "",
      "agentSchedNum": 0,
      "agentTaskNum": 0,
      "maintProgram": "Ice.UIRpt.IIT_DeliveryNot"
    };
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:Adp@2023'))}';
    try {
      final submitReportURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.RPT.BAQReportSvc/TransformAndSubmit');
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
    final loadURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD103Svc/GetByID');
    Map<String, dynamic> body = {
      "key1": loadIDController.text,
      "key2": "",
      "key3": "",
      "key4": "",
      "key5": ""
    };
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

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
          loadValue = loadData['UD103'];

          elementValue = loadData['UD103A']?.where((element) =>
          element['CheckBox13'] == false).toList();
          partValue = loadData['UD103A']?.where((part) =>
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
/*Future <void> fetchElementANDPartsDataFromURL() async {
    final stringBasicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    final detailsURL2 = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD103Svc/UD103As?\$filter=Key1 eq \'${loadIDController.text}\'');
    try {
      final response = await http.get(
          detailsURL2,
          headers: {
            HttpHeaders.authorizationHeader: stringBasicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      if(response.statusCode ==200) {
        final jsonResponse = json.decode(response.body);

        elementData = jsonResponse;
        elementValue =
            elementData['value'].where((element) =>
            element['CheckBox13'] ==
                false).toList();
        partData = jsonResponse;
        partValue = partData['value']
            .where((part) => part['CheckBox13'] == true)
            .toList();
        setState(() {
          arrivedElements = elementValue.map((e) => ElementData.fromJson(e)).toList();
          arrivedParts = partValue.map((e) => PartData.fromJson(e)).toList();
        });
      }


    } on Exception catch (e) {
      debugPrint(e.toString());
    }
}*/
  Future<dynamic> fetchPDFCounts() async {
    final String basicAuth = 'Basic ${base64Encode(
        utf8.encode('manager:Adp@2023'))}';
    try {
      final pdfCountsURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_getDN(158095)/?%24orderby=SysRptLst1_CreatedOn%20desc&%24top=1');
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
    final loadURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD103Svc/UD103s?\$filter=Key1 eq \'${loadIDController.text}\'');
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
  Future<Uint8List> deliveryNote(String base64String) async {
    Uint8List decodedBytes = base64.decode(base64String);
    final pdf = pw.Document();
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Regular.ttf'));
    final directory = await getApplicationDocumentsDirectory();
    final output = File('${directory.path}/DeliveryNote${loadIDController.text}.pdf');

    await pdf.save();
    await output.writeAsBytes(decodedBytes, flush: true);

    return output.readAsBytesSync();
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
        debugPrint(response.body);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateStatusOnSite (String partNum, String elementId) async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    final response = await http.post(
        Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates'),
        headers: {
          HttpHeaders.authorizationHeader: basicAuth,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({
          "Company": "158095",
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
    /*                                await fetchElementDataFromURL();
                                    await fetchPartDataFromURL();*/
                                    /*await fetchElementANDPartsDataFromURL();*/
                                    String projectLoadID = loadIDController.text;
                                    offloadData = getLoadObjectFromJson(projectLoadID);
    /*                                getElementObjectFromJson(projectLoadID);
                                    getPartObjectFromJson(projectLoadID);*/
                                    if (offloadData != null) {
                                      if(offloadData!.loadStatus == 'Closed'){
                                        Offloaded = true;
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
                                          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)
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
                                  child: ElementSearchForm(onElementsSelected: updateElementInformation, arrivedElements: arrivedElements, isOffloading: true,AddElement:(ElementData)=>{}, ),
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
                        Offloaded? ElevatedButton(
                            onPressed: () async {
                          setState(() {
                            isPrinting = true;
                          });
                          fetchPDFCounts().then((count) {
                            if (count!=null&&count.isNotEmpty) {
                              setState(() {
                                PDFCount = count[0]['Calculated_Count'];

                              });
                            }
                              submitReport().then((value) async  {
                                if (value != false) {
                                  for (int i = 0; i < 3; i++) {
                                    await Future.delayed(const Duration(seconds: 2));
                                    var updatedCounts = await fetchPDFCounts();
                                    if (updatedCounts != null &&
                                        updatedCounts[0]['Calculated_Count'] > PDFCount) {
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
                                                              updatedCounts[0][
                                                                  'SysRptLst1_RptData']))));
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
                                                  child: const Text('Close'),
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
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                            else {
                              final loadDateFormat = '${DateFormat('yyyy-mm-dd').format(DateTime.now())}T00:00:00';
                              for (var v = 0; v < selectedElements.length; v++) {
                                await updateUD103A({
                                  "Key1": loadIDController.text,
                                  "Character01": selectedElements[v].elementId,
                                  "Company": '158095',
                                  "CheckBox01": true,
                                  "CheckBox02": false,
                                  "CheckBox03": false,
                                  "CheckBox05": false,
                                  "Date02": loadDateFormat,
                                });
                                await updateStatusOnSite(selectedElements[v].partId, selectedElements[v].elementId);
                                debugPrint(selectedElements[v].elementId);
                              }
                              for (var v = 0; v < arrivedParts.length; v++) {
                                await updateUD103A({
                                  "Key1": loadIDController.text,
                                  "Character01": arrivedParts[v].partNum,
                                  "Company": '158095',
                                  "CheckBox01": true,
                                  "CheckBox02": false,
                                  "CheckBox03": false,
                                  "CheckBox05": false,
                                });
                                debugPrint(arrivedParts[v].partNum);
                              }
                              await updateLoadStatus({
                                "Key1": loadIDController.text,
                                "Company": '158095',
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
                                Offloaded = true;
                              });
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
                            if (!loaded /*&& !elementsAndPartsLoaded*/){
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







