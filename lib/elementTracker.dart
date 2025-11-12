import 'dart:convert';
import 'dart:io';
import 'sideBarMenu.dart';
import 'dart:math';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'indexAppBar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'detailsPage.dart';
import 'Providers/tenantConfig.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'load_model.dart';

class ElementDataSource extends ChangeNotifier {
  List<dynamic> partElementList = [];

  void updateList(List<dynamic> newList) {
    partElementList = newList;
    notifyListeners();
  }
}

class ElementMaster extends StatefulWidget {
  dynamic tenantConfig;
  ElementMaster({super.key,required this.tenantConfig});

  @override
  State<ElementMaster> createState() => _ElementMasterState();
}

class MyDataTableSource extends DataTableSource{
  final List<dynamic> _elementData;
  final BuildContext dialogContext;
  bool hasMore = false;



  dynamic tenantConfig;

  MyDataTableSource(this._elementData, this.dialogContext,this.tenantConfig );

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
                  utf8.encode('${tenantConfig['userID']}:${tenantConfig['password']}'))}';
              try {
                final response = await http.get(
                  Uri.parse('${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates(${tenantConfig['company']},$partNum,$elementId)'),
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

  Map<String, dynamic> elementListData = {};
  List<dynamic> elementListValue = [];
  List<dynamic> partElementList = [];
  List<dynamic> filteredElementList = [];

  TextEditingController partNumController = TextEditingController();
  TextEditingController elementIdController = TextEditingController();
  TextEditingController projectController = TextEditingController();
  bool isSingleElement = false;
  bool isSearching = false;



  String elementResultCode = '';
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool isScanned = false;
  bool isElement = false;
  int offset = 0;
  int currentPageIndex = 0;
  bool SearchExpanded = false;

  final GlobalKey<PaginatedDataTableState> dataTablekey = GlobalKey();
  List<dynamic>projects=[];

  @override
  void initState()  {
     getProjectList(widget.tenantConfig);
    super.initState();

  }

  Future<void> getElementList(String param, bool isElement,int offset,final tenantConfig2) async {
    Uri url;
    int page = offset == 0 ? 11: 10;
    if(!isElement) {
      url = Uri.parse(
          '${tenantConfig2['httpVerbKey']}://${tenantConfig2['appPoolHost']}/${tenantConfig2['appPoolInstance']}/api/v1/BaqSvc/IIT_AllElement(${tenantConfig2['company']})?\$filter=PartLot_PartNum eq \'$param\' ${projectController.text.isEmpty?'':'and PartLot_Project_c eq \'${projectController.text}\''} &\$top=$page''&\$skip=$offset');
    }
    else {
      url = Uri.parse(
          '${tenantConfig2['httpVerbKey']}://${tenantConfig2['appPoolHost']}/${tenantConfig2['appPoolInstance']}/api/v1/BaqSvc/IIT_AllElement(${tenantConfig2['company']})?\$filter=PartLot_LotNum eq \'$param\' ${projectController.text.isEmpty?'':'and PartLot_Project_c eq \'${projectController.text}\''} &\$top=$page&\$skip=$offset');
      isElement = true;
    }
    try {
      final String basicAuth = 'Basic ${base64Encode(
          utf8.encode('${tenantConfig2['userID']}:${tenantConfig2['password']}'))}';
      final response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      if (response.statusCode == 200) {
        var elementListData = json.decode(response.body);
        var elementListValue = elementListData['value'];
        setState(() {
          partElementList+=elementListValue;
          filteredElementList = partElementList;
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
  Future<void> getProjectList(dynamic tenantConfigP) async {
    final String basicAuth = 'Basic ${base64Encode(
        utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final response = await http.get(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Erp.Bo.ProjectSvc/List/'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      if (response.statusCode == 200) {
        setState(() {
          projects = json.decode(response.body)['value'];
          projects = projects.map((e) => e['ProjectID']).toList();

        });
      } else {
        throw Exception('Failed to load Project');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> getScannedElement(String partNum, String elementId, String companyId) async {
    var url = Uri.parse('${context.read<tenantConfigProvider>().tenantConfig['httpVerbKey']}://${context.read<tenantConfigProvider>().tenantConfig['appPoolHost']}/${context.read<tenantConfigProvider>().tenantConfig['appPoolInstance']}/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates($companyId,$partNum,$elementId)');
    try {

       final String basicAuth = 'Basic ${base64Encode(utf8.encode('${context.read<tenantConfigProvider>().tenantConfig['userID']}:${context.read<tenantConfigProvider>().tenantConfig['password']}' ))}';
      final response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        elementListData = json.decode(response.body);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailsPage(elementId: elementId, elementDetails: elementListData, statusColor: Colors.transparent)),
          );
        }
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
            filteredElementList = partElementList;
          });
        }
      }
    }
    if(isSingleElement) {
      for(int i = 0; i < elementListValue.length; i++) {
        if (elementListValue[i]['PartLot_LotNum'] == partNum) {
          setState(() {
            partElementList.add(elementListValue[i]);
            filteredElementList = partElementList;
          });
        }
      }
    }
  }

  List<LoadData> loads = [];
  void addLoadData(LoadData load) {
    setState(() {
      for (int i = 0; i < loads.length; i++) {
        if (loads[i].loadID == load.loadID) {
          loads.removeAt(i);
          break;
        }
      }
    });
    setState(() {
      loads.add(load);
    });
  }



  @override
  Widget build(BuildContext context) {
    final tenantConfigP = context.watch<tenantConfigProvider>()?.tenantConfig;
    final width = MediaQuery.of(context).size.width;

    return projects.length > 0

        ? Scaffold(
            backgroundColor: Theme.of(context).shadowColor,
            appBar: const IndexAppBar(title: 'Element Tracker'),
            drawer: width>600?null:SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
            body: Row(
              children: [
              width > 600
              ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: SideBarMenu(context, loads, addLoadData, widget.tenantConfig))
              : const SizedBox(),
            Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                   // Detect desktop screens
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Card(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            elevation: 1,
                            color: Theme.of(context).indicatorColor,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          onTap: () {
                                            setState(() {
                                              elementIdController.clear();
                                              currentPageIndex = 0;
                                            });
                                          },
                                          controller: partNumController,
                                          decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Theme.of(context).indicatorColor),
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
                                          decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Theme.of(context).indicatorColor),
                                              ),
                                              labelText: "Element ID"),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: isSearching
                                          ? const CircularProgressIndicator()
                                          : IconButton(
                                              onPressed: () async {
                                                setState(() {
                                                  isSearching = true;
                                                });

                                          partElementList.clear();
                                          filteredElementList.clear();
                                          setState(() {
                                            currentPageIndex = 0;
                                          });
                                          dataTablekey.currentState?.pageTo(0);
                                          if(partNumController.text.isNotEmpty) {
                                            setState(() {
                                              isSingleElement = false;
                                            });

                                            await getElementList(partNumController.text, false, 0,tenantConfigP!);
                                          }
                                          if(elementIdController.text.isNotEmpty){
                                            setState(() {
                                              isSingleElement = true;
                                            });
                                            await getElementList(elementIdController.text, true,0,tenantConfigP!);
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
                                            child: MobileScanner(
                                              controller: MobileScannerController(
                                                facing: CameraFacing.back,
                                                torchEnabled: false,
                                              ),
                                              onDetect: (BarcodeCapture capture) async {
                                                final List<Barcode> barcodes = capture.barcodes;
                                                final Barcode barcode = barcodes.first;
                                                final String? code = barcode.rawValue;

                                                if (code != null) {
                                                  String elementId = '';
                                                  String partNum = '';
                                                  String companyId = '';
                                                  debugPrint('this is the code $code');

                                                  List<String> scanResult = code.split('  ');
                                                  if (scanResult.length >= 5) {
                                                    elementId = scanResult[4];
                                                    partNum = scanResult[3];
                                                    companyId = scanResult[2];

                                                    // Stop scanner before navigating
                                                    Navigator.pop(context);

                                                    await getScannedElement(partNum, elementId, companyId);
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text('Invalid QR Code'),
                                                          content: const Text('Please scan a valid QR code'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: Text('OK', style: TextStyle(color: Theme.of(context).canvasColor)),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                              },
                                            )
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

                          Row(
                            children: [
                              Expanded(child:SearchExpanded?
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: DropdownSearch(


                                  popupProps: const PopupProps.modalBottomSheet(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
                                        labelText: "Search",
                                      ),
                                    ),
                                  ),
                                  autoValidateMode: AutovalidateMode.onUserInteraction,
                                  selectedItem: projectController.text.isNotEmpty?projectController.text:null,
                                  dropdownDecoratorProps:  DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Project ID",
                                      filled: true,
                                      fillColor: Theme.of(context).shadowColor
                                    ),
                                  ),
                                  items: projects,
                                  onChanged: (value) {
                                    setState(() {
                                      projectController.text = value.toString();
                                      filteredElementList=partElementList.where((element) => element['PartLot_Project_c']==value).toList();
                                    });
                                  },

                                ),
                              ):Container(),
                              ),

                            ],
                          ),
                          //expanding button
                         Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                            IconButton(
                              padding: const EdgeInsets.all(0),
                              iconSize: 25,
                            icon : SearchExpanded? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down),
                              onPressed: () {
                                 setState(() {
                                   SearchExpanded = !SearchExpanded;
                                 })
                              ;
                            }
                            )
                           ],
                         )
                        ],
                      ),

                    ),
                  ),

                SizedBox(
                    child: Card(
                      color: Theme.of(context).indicatorColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),

                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: MediaQuery.of(context).size.width,
                                  ),
                                  child: PaginatedDataTable(
                                    key : dataTablekey,
                                    onPageChanged: (page) async {

                                      debugPrint(offset.toString());
                                      if(page>offset){
                                        offset=max(offset, page);
                                        isElement ? await getElementList(elementIdController.text, true, page,tenantConfigP!) : await getElementList(partNumController.text, false, page,tenantConfigP!);
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
                                    source: filteredElementList.isNotEmpty ?
                                    MyDataTableSource(filteredElementList, context,tenantConfigP!)
                                        :
                                    MyDataTableSource(filteredElementList, context,tenantConfigP!),
                                    ),
                                )
                              )
                        ),
                      ),

            ],
          ),
        );
                },
              ),
            ),
          ),
        ],
    ) ):Scaffold(
      backgroundColor: Theme.of(context).shadowColor,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}




