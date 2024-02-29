import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precast_demo/indexAppBar.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'detailsPage.dart';


class ElementMaster extends StatefulWidget {
  const ElementMaster({super.key});

  @override
  State<ElementMaster> createState() => _ElementMasterState();
}

class MyDataTableSource extends DataTableSource{
  final List<dynamic> _elementData;
  final BuildContext dialogContext;

  MyDataTableSource(this._elementData, this.dialogContext);

  @override
  DataRow? getRow(int index) {
    Color statusColor;
    final row = _elementData[index];
    if (row["PartLot_ElementStatus_c"] == 'Entered'){
      statusColor = Colors.blue;
    } else if(row["PartLot_ElementStatus_c"] == 'Casted') {
      statusColor = Colors.grey;
    } else if (row["PartLot_ElementStatus_c"] == 'Erected'){
      statusColor = Colors.black54;
    } else if (row["PartLot_ElementStatus_c"] == 'In-Transit') {
      statusColor = Colors.brown;
    } else if (row["PartLot_ElementStatus_c"] == 'OnSite') {
      statusColor = Colors.purple;
    } else if (row["PartLot_ElementStatus_c"] == 'Cancelled') {
      statusColor = Colors.red;
    } else if (row["PartLot_ElementStatus_c"] == 'Approved') {
      statusColor = Colors.green;
    } else if (row["PartLot_ElementStatus_c"] == 'Draft') {
      statusColor = Colors.orange;
    } else if (row["PartLot_ElementStatus_c"] == 'Hold') {
      statusColor = Colors.yellow;
    }
    else {
      statusColor = Colors.transparent;
    }
    return DataRow(cells: [
      DataCell(
          GestureDetector(
            onTap: () async {
              final String elementId = row["PartLot_LotNum"];
              final String partNum = row["PartLot_PartNum"];
              Map<String, dynamic> elementDetails = {};
              final String basicAuth = 'Basic ${base64Encode(
                  utf8.encode('manager:manager'))}';
              try {
                final response = await http.get(
                  Uri.parse('https://77.92.189.102/IIT_vertical_precast/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates(EPIC06,$partNum,$elementId)'),
                    headers: {
                      HttpHeaders.authorizationHeader: basicAuth,
                      HttpHeaders.contentTypeHeader: 'application/json',
                    },
                );
                debugPrint(response.statusCode.toString());
                if (response.statusCode == 200) {
                  debugPrint(response.body);
                  elementDetails = json.decode(response.body);
                }
              } on Exception catch (e) {
                  debugPrint(e.toString());
              }
              Navigator.push(
                dialogContext,
                MaterialPageRoute(builder: (context) => DetailsPage(elementId: row["PartLot_LotNum"], elementDetails: elementDetails, statusColor: statusColor)),
              );
            },
            child: Text(row["PartLot_LotNum"],
              style: const TextStyle(
                //add an underline
                decoration: TextDecoration.underline,
              ),
            ),
          )
      ),
      DataCell(
          Text(row["PartLot_PartNum"])
      ),
      DataCell(
        Text(row["PartLot_PartLotDescription"]),
      ),
      DataCell(
        Text(row["PartLot_Project_c"]),
      ),
      DataCell(
        Container(
          height: 20,
          width: 100,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: statusColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(row["PartLot_ElementStatus_c"]),
            ],
          ),
        ),
      )
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _elementData.length;

  @override
  int get selectedRowCount => 0;
}



class _ElementMasterState extends State<ElementMaster> {

  late Future _elementListFuture;

  Map<String, dynamic> elementListData = {};
  List<dynamic> elementListValue = [];
  List<dynamic> partElementList = [];

  TextEditingController partNumController = TextEditingController();
  TextEditingController elementIdController = TextEditingController();

  bool isSingleElement = false;

  final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:manager'))}';

  Barcode? elementResult;
  String elementResultCode = '';
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool isScanned = false;

  Future<void> getElementList() async {
    var url = Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/BaqSvc/IIT_AllElement');
    try {
      final response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      if (response.statusCode == 200) {
        elementListData = json.decode(response.body);
        elementListValue = elementListData['value'];
        debugPrint(elementListValue.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getScannedElement(String partNum, String elementId) async {
    var url = Uri.parse('https://77.92.189.102/IIT_vertical_precast/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates(EPIC06,$partNum,$elementId)');
    try {
      final response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        elementListData = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailsPage(elementId: elementId, elementDetails: elementListData, statusColor: Colors.transparent)),
        );
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getPartElementList(String partNum) async {
    if (!isSingleElement) {
      for(int i = 0; i < elementListValue.length; i++) {
        if (elementListValue[i]['PartLot_PartNum'] == partNum) {
          setState(() {
            partElementList.add(elementListValue[i]);
          });
        }
      }
    }
    if(isSingleElement) {
      for(int i = 0; i < elementListValue.length; i++) {
        if (elementListValue[i]['PartLot_LotNum'] == partNum) {
          setState(() {
            partElementList.add(elementListValue[i]);
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _elementListFuture = getElementList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndexAppBar(title: 'Element Master',),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.12,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      elevation: 1,
                      color: Colors.lightBlue.shade100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                onTap: () {
                                  setState(() {
                                    elementIdController.clear();
                                  });
                                },
                                controller: partNumController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                    filled: true,
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    labelText: "Part Num"),

                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                onTap: () {
                                  setState(() {
                                    partNumController.clear();
                                  });
                                },
                                controller: elementIdController,
                                decoration: const InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    labelText: "Element ID"),

                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder(
                              future: _elementListFuture,
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  return IconButton(
                                    onPressed: () async {
                                      partElementList.clear();
                                      if(partNumController.text.isNotEmpty) {
                                        setState(() {
                                          isSingleElement = false;
                                        });
                                        await getPartElementList(partNumController.text);
                                      }
                                      if(elementIdController.text.isNotEmpty){
                                        setState(() {
                                          isSingleElement = true;
                                        });
                                        await getPartElementList(elementIdController.text);
                                      }
                                    },
                                    icon: const Icon(Icons.search),
                                  );
                                }
                                return const CircularProgressIndicator();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.6,
                                        height: MediaQuery.of(context).size.height * 0.6,
                                        child: QRView(
                                          key: qrKey,
                                          overlay: QrScannerOverlayShape(
                                            borderColor: Colors.red,
                                            borderRadius: 10,
                                            borderLength: 30,
                                            borderWidth: 10,
                                            cutOutSize: 300,
                                          ),
                                          onQRViewCreated: (QRViewController controller) {
                                            this.controller = controller;
                                            controller.scannedDataStream
                                                .listen((scanData) async {
                                              controller.pauseCamera();
                                              Navigator.pop(context);
                                              List<String> scanResult =
                                                  scanData.code!.split('-');
                                              // String company = scanResult[1];
                                              String partNum = scanResult[2];
                                              String elementId = scanResult[3];
                                              debugPrint('$partNum $elementId');
                                              await getScannedElement(
                                                  partNum, elementId);
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.qr_code_scanner),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Card(
                      color: Colors.lightBlue.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                                child: PaginatedDataTable(
                                  headingRowColor: MaterialStateColor.resolveWith((states) {return Theme.of(context).primaryColor;}),
                                  columnSpacing: 30,
                                  columns: const [
                                    DataColumn(label: Text('Element ID')),
                                    DataColumn(label: Text('Part Num')),
                                    DataColumn(label: Text('Element Desc')),
                                    DataColumn(label: Text('Project')),
                                    DataColumn(label: Text('Status')),
                                  ],
                                  source: MyDataTableSource(partElementList, context),
                                  )
                              )
                        ),
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




