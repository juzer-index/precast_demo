import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:IIT_precast_app/indexAppBar.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';


import 'detailsPage.dart';
class ElementDataSource extends ChangeNotifier {
  List<dynamic> partElementList = [];

  void updateList(List<dynamic> newList) {
    partElementList = newList;

    notifyListeners();
  }


}

class ElementMaster extends StatefulWidget {
  const ElementMaster({Key? key}) ;

  @override
  State<ElementMaster> createState() => _ElementMasterState();
}

class MyDataTableSource extends DataTableSource{
  final List<dynamic> _elementData;
  final BuildContext dialogContext;
  bool _hasMore = false;

  @override
  bool get hasMore => _hasMore;


  set hasMore(bool value) {
    _hasMore = value;
  }




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
                  utf8.encode('manager:Adp@2023'))}';
              try {
                final response = await http.get(
                  Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates(EPIC06,$partNum,$elementId)'),
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
  bool isSearching = false;

  final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:Adp@2023'))}';

  Barcode? elementResult;
  String elementResultCode = '';
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool isScanned = false;
  bool isElement = false;
  int offset = 0;
  int currentPageIndex = 0;
  final GlobalKey<PaginatedDataTableState> DataTablekey = GlobalKey();

  @override
  void initState() {

    super.initState();

  }


  /*Future<void> getElementList() async {
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
  }*/
  Future<void> getElementList(String Param, bool isElement,int offset) async {
    var url;
    int page = offset == 0 ? 11: 10;
    if(!isElement) {
      url = Uri.parse(
          'https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_AllElement(158095)?\$filter=PartLot_PartNum eq \'$Param\'&\$top=$page''&\$skip=$offset');

    }

    else {
      url = Uri.parse(
          'https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_AllElement(158095)?\$filter=PartLot_LotNum eq \'$Param\'&\$top=$page&\$skip=$offset');
      isElement = true;
    }
    try {
      final String basicAuth = 'Basic ${base64Encode(
          utf8.encode('manager:Adp@2023'))}';
      final response = await http.get(url, headers: {

        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',


      });
      if (response.statusCode == 200) {
        var elementListData = json.decode(response.body);
        var elementListValue = elementListData['value'];
        setState(() {
          partElementList+=elementListValue;
          offset += elementListValue.length as int;
        });


        debugPrint(elementListValue.toString());
      }
      else {
        debugPrint(response.statusCode.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> getScannedElement(String partNum, String elementId) async {
    var url = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates(EPIC06,$partNum,$elementId)');
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
                   // width: MediaQuery.of(context).size.width,
                   // height: MediaQuery.of(context).size.height * 0.12,
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
                                    currentPageIndex= 0;

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
                            child: /*FutureBuilder(
                              future: _elementListFuture,
                              builder: (BuildContext context, AsyncSnapshot snapshot) {*/
                               /* if (snapshot.connectionState == ConnectionState.done) {*/
                                 /* return */isSearching?

                                   CircularProgressIndicator()
                                 :IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        isSearching = true;
                                      });

                                      partElementList.clear();
                                      setState(() {
                                        currentPageIndex = 0;
                                      });
                                      DataTablekey.currentState?.pageTo(0);
                                      if(partNumController.text.isNotEmpty) {
                                        setState(() {
                                          isSingleElement = false;
                                        });

                                        await getElementList(partNumController.text, false, 0);
                                      }
                                      if(elementIdController.text.isNotEmpty){
                                        setState(() {
                                          isSingleElement = true;
                                        });
                                        await getElementList(elementIdController.text, true,0);
                                      }
                                      setState(() {
                                        isSearching = false;
                                      });
                                    },
                                    icon: const Icon(Icons.search),/*
                                  ),
                                }
                                return const CircularProgressIndicator();
                              },*/
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Scan Element'),
                                      content: SizedBox(
                                        width: MediaQuery.of(context).size.width ,
                                        height: MediaQuery.of(context).size.height * 0.35,
                                        child: QRView(
                                          key: qrKey,
                                          onQRViewCreated: (QRViewController controller) {
                                            this.controller = controller;
                                            controller.scannedDataStream.listen((scanData) async {
                                              String elementId = '';
                                              String partNum = '';
                                              controller.pauseCamera();
                                              Navigator.pop(context);
                                              debugPrint('this is the code ${scanData.code}');
                                              List<String> scanResult = scanData.code!.split('-');
                                              if (scanResult.length >= 4) {
                                                elementId = scanResult.sublist(3).join("-");
                                                partNum = scanResult[2];
                                                await getScannedElement(partNum, elementId);
                                              } else {
                                                showDialog(context: context, builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text('Invalid QR Code'),
                                                    content: const Text('Please scan a valid QR code'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  );
                                                });
                                              }
                                              // // String company = scanResult[1];
                                              // String partNum = scanResult[2];
                                              // String elementId = scanResult[3];
                                              // debugPrint('$partNum $elementId');
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

                                child: PaginatedDataTable(
                                  key : DataTablekey,
                                  onPageChanged: (page) async {

                                    debugPrint(offset.toString());
                                    if(page>offset){
                                      offset=max(offset, page);
                                      isElement ? await getElementList(elementIdController.text, true, page) : await getElementList(partNumController.text, false, page);

                                    }


                                   },


                                  initialFirstRowIndex:currentPageIndex>0?currentPageIndex:0,

                                  columnSpacing: 30,
                                  columns: const [
                                    DataColumn(label: Text('Element ID')),
                                    DataColumn(label: Text('Part Num')),
                                    DataColumn(label: Text('Element Desc')),
                                    DataColumn(label: Text('Project')),
                                    DataColumn(label: Text('Status')),
                                  ],
                                  source: partElementList.isNotEmpty ?
                                  MyDataTableSource(partElementList, context)
                                      :
                                  MyDataTableSource(partElementList, context),
                                  )
                              )
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




