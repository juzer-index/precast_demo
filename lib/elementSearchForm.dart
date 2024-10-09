import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'part_model.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'element_model.dart';

import 'package:http/http.dart' as http;

class ElementSearchForm extends StatefulWidget {
  final Function(List<ElementData>, List<PartData>) onElementsSelected;
  final Function(ElementData) AddElement;
  List<ElementData>? arrivedElements = [];
  dynamic tenantConfig;
  bool isOffloading;
  dynamic Project;
  dynamic Warehouse;
  bool isInstalling = false;
  ElementSearchForm(
      {super.key,
      required this.onElementsSelected,
      this.arrivedElements,
      required this.isOffloading,
      this.Warehouse,
      required this.AddElement,
      this.Project,
      required this.tenantConfig,
      required this.isInstalling});

  @override
  State<ElementSearchForm> createState() => _ElementSearchFormState();
}

class _ElementSearchFormState extends State<ElementSearchForm> {
  TextEditingController elementNumberController = TextEditingController();
  TextEditingController elementDescriptionController = TextEditingController();
  TextEditingController erectionSeqController = TextEditingController();
  TextEditingController estErectionDateController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController volumeController = TextEditingController();
  TextEditingController onHandQtyController = TextEditingController();
  TextEditingController selectedQtyController = TextEditingController();
  TextEditingController uomController = TextEditingController();
  List<ElementData> selectedElements = [];
  List<PartData> selectedParts = [];
  TextEditingController lotNoController = TextEditingController();
  TextEditingController fromBin = TextEditingController();

  Map<String, dynamic> partData = {};
  List<dynamic> partValue = [];
  Map<String, dynamic> elementData = {};
  List<dynamic> elementValue = [];
  Map<String, dynamic> consumableData = {};
  List<dynamic> consumableValue = [];
  Map<String, dynamic> lotData = {};

  List<dynamic> consumables = [];
  List<dynamic> elements = [];
  List<dynamic> lots = [];
  Map<String, dynamic> elementListData = {};
  List<ElementData> totalElements = [];

  Barcode? elementResult;
  String elementResultCode = '';
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool isElement = false;
  bool isLoading = false;
  bool selectable = false;
  // bool isConsumable = false;

  // late Future _dataFuture;

  // var partURL = Uri.parse('${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/BaqSvc/IIT_P_PartDetails_V1(${widget.tenantConfig['company)');

  Future<void> getAllParts(String PartNum) async {
    String URL = widget.isInstalling
        ? '${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/BaqSvc/IIT_ElementErection(${widget.tenantConfig['company']})?\$filter=PartLot_Project_c  eq  \'${widget.Project}\''
        : '${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/BaqSvc/IIT_GetAllParts3Return_M1_ES(${widget.tenantConfig['company']})/?Part=$PartNum&Project=${widget.Project}&WAREHSE=${widget.Warehouse}';

    try {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';

      final response = await http.get(Uri.parse(URL), headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        partData = jsonDecode(response.body);
        if (partData['value'].isEmpty) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Part not found'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK',
                          style:
                              TextStyle(color: Theme.of(context).canvasColor)),
                    ),
                  ],
                );
              });
        } else {
          setState(
            () {
              partValue = partData['value'];
              if (widget.isInstalling) {
                setState(() {
                  isElement = true;
                  elementValue = partValue;
                  elements =
                      elementValue.map((e) => e['PartLot_LotNum']).toList();
                  isLoading = false;
                });
              } else {
                if (partValue[0]['Part_IsElementPart_c'] == true) {
                  isElement = true;
                  elementValue = partValue;
                  elements =
                      elementValue.map((e) => e['PartLot_LotNum']).toList();
                  isLoading = false;
                } else {
                  isElement = false;
                  elementDescriptionController.text =
                      partValue[0]['Part_PartDescription'];
                  uomController.text = partValue[0]['Part_IUM'];
                  onHandQtyController.text = partValue[0]
                          ['Calculated_Calculated_OnhandQty']
                      .toString();
                  fromBin.text = partValue[0]['PartBin_BinNum'];
                  isLoading = false;
                }
              }
            },
          );
        }

        debugPrint(partValue.length.toString());
      } else {
        debugPrint(response.statusCode.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  int specifyMaxChildKey() {
    List<ElementData> elements = this.totalElements;
    int max = 0;
    for (var i = 0; i < elements.length; i++) {
      if (int.parse(elements[i].ChildKey1) > max) {
        max = int.parse(elements[i].ChildKey1);
      }
    }
    return max;
  }

  Future<void> getLotForElements() async {
    try {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';

      setState(() {
        selectable = false;
      });
      String partNum = elementNumberController.text;
      var elementLotURL = Uri.parse(
          '${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/BaqSvc/IIT_PartAndLotNumber(${widget.tenantConfig['company']})?\$filter=PartLot_PartNum  eq  \'$partNum\''); //?\$filter=PartLot_LotNum eq \'$Param\'&\$top=$page&\$skip=$offset';
      final response = await http.get(elementLotURL, headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      if (response.statusCode == 200) {
        debugPrint(elements.toString());
      } else {
        debugPrint(response.statusCode.toString());
        setState(() {
          isLoading = false;
        });
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getElementDetailsFromLot(String lotNo, String partNum) async {
    try {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';

      final response = await http.get(
          Uri.parse(
              '${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates(${widget.tenantConfig['company']},$partNum,$lotNo)'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if (response.statusCode == 200) {
        lotData = jsonDecode(response.body);
        setState(() {
          lotNoController.text = lotNo;
          elementDescriptionController.text = lotData['PartLotDescription'];
          uomController.text = lotData['PartNumSalesUM'];
          erectionSeqController.text = lotData['ErectionSequence_c'].toString();
          weightController.text = lotData['Ton_c'];
          areaController.text = lotData['M2_c'];
          volumeController.text = lotData['M3_c'];
          fromBin.text = lotData["PartBin_BinNum"];
          estErectionDateController.text =
              lotData['ErectionPlannedDate_c'] != null
                  ? lotData['ErectionPlannedDate_c']
                  : '';
          onHandQtyController.text = '1';
          selectedQtyController.text = '1';
        });
        setState(() {
          selectable = true;
        });
      } else {
        debugPrint(response.statusCode.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getConsumableDetails(String partNum) async {
    try {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';

      var consumableURL = Uri.parse(
          '${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/BaqSvc/IIT_NonTrackPart/?\$filter=Part_PartNum eq \'$partNum\''); //?\$filter=PartLot_LotNum eq \'$Param\'&\$top=$page&\$skip=$offset';
      final response = await http.get(consumableURL, headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      if (response.statusCode == 200) {
        consumableData = jsonDecode(response.body);
        for (var i = 0; i < consumableData['value'].length; i++) {
          if (consumableData['value'][i]['Part_PartNum'] == partNum) {
            elementDescriptionController.text =
                consumableData['value'][i]['Part_PartDescription'];
            uomController.text = consumableData['value'][i]['Part_IUM'];
            onHandQtyController.text =
                consumableData['value'][i]['Calculated_OnHandQty'].toString();
            break;
          }
        }
      } else {
        debugPrint(response.statusCode.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getScannedElement(
      String partNum, String elementId, String companyId) async {
    try {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';

      final response = await http.get(
          Uri.parse(
              '${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates($companyId,$partNum,$elementId)'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if (response.statusCode == 200) {
        elementListData = jsonDecode(response.body);
      } else {
        debugPrint(response.statusCode.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isOffloading) {
      totalElements = widget.arrivedElements!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: elementNumberController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Part Num",
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : IconButton(
                      onPressed: () async {
                        elements.clear();
                        lotNoController.text = '';
                        if (!widget.isOffloading) {
                          if (elementNumberController.text.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                              lotNoController.text = '';
                              elementDescriptionController.text = '';
                              lotNoController.text = '';
                              uomController.text = '';
                              erectionSeqController.text = '';
                              weightController.text = '';
                              areaController.text = '';
                              volumeController.text = '';
                              estErectionDateController.text = '';
                            });
                            setState(() {
                              isElement = false;
                            });
                            await getAllParts(elementNumberController.text);
                            setState(() {
                              isLoading = false;
                            });

                            /*   if(partValue[0]['Part_IsElementPart_c'] == true){
                              isElement = true;
                              await getLotForElements();

                            }
                            else{
                              isElement = false;
                              await getConsumableDetails(elementNumberController.text);
                            }*/
                          }
                        }
                        if (widget.isOffloading) {
                          if (elementNumberController.text.isNotEmpty) {
                            for (var i = 0;
                                i < widget.arrivedElements!.length;
                                i++) {
                              if (widget.arrivedElements![i].partId
                                      .toLowerCase() ==
                                  elementNumberController.text.toLowerCase()) {
                                elements
                                    .add(widget.arrivedElements![i].elementId);
                                setState(() {
                                  isElement = true;
                                });
                              }
                            }
                          } else {
                            if (mounted) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text(
                                          'Part not found in arrived elements'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .canvasColor)),
                                        ),
                                      ],
                                    );
                                  });
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.search),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
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
                            height: MediaQuery.of(context).size.height * 0.6,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: QRView(
                                      key: qrKey,
                                      overlay: QrScannerOverlayShape(
                                        borderColor: Colors.red,
                                        borderRadius: 10,
                                        borderLength: 30,
                                        borderWidth: 10,
                                        cutOutSize: 300,
                                      ),
                                      onQRViewCreated: (qrController) {
                                        controller = qrController;
                                        controller!.scannedDataStream
                                            .listen((scanData) async {
                                          String elementId = '';
                                          String partNum = '';
                                          String companyId = '';
                                          String wareHouse = '';
                                          String projectId = '';
                                          controller!.pauseCamera();
                                          Navigator.pop(context);
                                          debugPrint(
                                              'this is the code ${scanData.code}');
                                          List<String> scanResult =
                                              scanData.code!.split('  ');
                                          if (scanResult.length >= 7) {
                                            elementId = scanResult[4];
                                            partNum = scanResult[3];
                                            companyId = scanResult[2];
                                            projectId = scanResult[5];
                                            wareHouse = scanResult.last;
                                            if (projectId != widget.Project) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Invalid Project'),
                                                      content: const Text(
                                                          'Please scan a valid QR code'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('OK',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .canvasColor)),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            } else if (wareHouse !=
                                                widget.Warehouse) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Invalid Warehouse'),
                                                      content: const Text(
                                                          'Please scan a valid QR code'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('OK',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .canvasColor)),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            } else {
                                              await getScannedElement(partNum,
                                                  elementId, companyId);
                                              setState(() {
                                                isElement = true;
                                                elementNumberController.text =
                                                    partNum;
                                                elementDescriptionController
                                                        .text =
                                                    elementListData[
                                                        'PartLotDescription'];
                                                lotNoController.text =
                                                    elementListData['LotNum'];
                                                uomController.text =
                                                    elementListData[
                                                        'PartNumSalesUM'];
                                                erectionSeqController
                                                    .text = elementListData[
                                                        'ErectionSequence_c']
                                                    .toString();
                                                weightController.text =
                                                    elementListData['Ton_c'];
                                                areaController.text =
                                                    elementListData['M2_c'];

                                                volumeController.text =
                                                    elementListData['M3_c'];
                                                estErectionDateController
                                                    .text = elementListData[
                                                        'ErectionPlannedDate_c'] ??
                                                    '';
                                                onHandQtyController.text = '1';
                                                elementResult = scanData;
                                                elementResultCode =
                                                    elementResult?.code ??
                                                        'Unknown';
                                                elementNumberController.text =
                                                    partNum;
                                                selectable = true;
                                              });
                                            }
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Invalid QR Code'),
                                                    content: const Text(
                                                        'Please scan a valid QR code'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('OK',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .canvasColor)),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  child: Center(
                                    child: Text('Data: $elementResultCode'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ),
          ],
        ),
        if (isElement)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(children: [
              DropdownSearch(
                enabled: elements.isNotEmpty,
                selectedItem: lotNoController.text,
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
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Lot No.",
                  ),
                ),
                items: elements.isNotEmpty ? elements : [],
                onChanged:

                    // await getElementDetailsFromLot(value, elementNumberController.text);
                    (value) async {
                  setState(() {
                    selectable = false;
                    dynamic element = widget.isOffloading
                        ? widget.arrivedElements!
                            .where((element) => element.elementId == value)
                            .first
                        : elementValue
                            .where(
                                (element) => element['PartLot_LotNum'] == value)
                            .first;

                    setState(() {
                      fromBin.text = widget.isOffloading
                          ? element.fromBin
                          : element['PartBin_BinNum'];
                      lotNoController.text = widget.isOffloading
                          ? element.elementId
                          : element['PartLot_LotNum'].toString();
                      elementDescriptionController.text = widget.isOffloading
                          ? element.elementDesc
                          : element['PartLot_PartLotDescription'];
                      uomController.text = widget.isOffloading
                          ? element.UOM
                          : element['Part_IUM'].toString();
                      erectionSeqController.text = widget.isOffloading
                          ? element.erectionSeq
                          : element['PartLot_ErectionSequence_c'].toString();
                      weightController.text = widget.isOffloading
                          ? element.weight
                          : element['PartLot_Ton_c'].toString();
                      areaController.text = widget.isOffloading
                          ? element.area
                          : element['PartLot_M2_c'].toString();
                      volumeController.text = widget.isOffloading
                          ? element.volume
                          : element['PartLot_M3_c'].toString();
                      estErectionDateController.text = widget.isOffloading
                          ? element.erectionDate
                          : element['ErectionPlannedDate_c'] ?? '';
                      onHandQtyController.text = '1';
                      selectedQtyController.text = '1';
                      selectable = true;
                    });
                  });
                },
              ),
              if (elements.isEmpty && elementListData.isEmpty)
                const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator())),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: elementDescriptionController,
            enabled: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Description",
            ),
          ),
        ),
        if (isElement)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: erectionSeqController,
                        enabled: false,
                        decoration: const InputDecoration(
                          label: Text('Erection Seq.'),
                          border: OutlineInputBorder(),
                          hintText: "Erection Seq.",
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: estErectionDateController,
                        enabled: false,
                        decoration: const InputDecoration(
                          label: Text('Est. Erection Date'),
                          border: OutlineInputBorder(),
                          hintText: "Est. Erection Date",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: weightController,
                        enabled: false,
                        decoration: const InputDecoration(
                          label: Text('Weight'),
                          border: OutlineInputBorder(),
                          hintText: "Weight",
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: areaController,
                        enabled: false,
                        decoration: const InputDecoration(
                          label: Text('Area'),
                          border: OutlineInputBorder(),
                          hintText: "Area",
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: volumeController,
                        enabled: false,
                        decoration: const InputDecoration(
                          label: Text('Volume'),
                          border: OutlineInputBorder(),
                          hintText: "Volume",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: uomController,
                  enabled: false,
                  decoration: const InputDecoration(
                    label: Text('UOM'),
                    border: OutlineInputBorder(),
                    hintText: "UOM",
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: onHandQtyController,
                  enabled: false,
                  decoration: const InputDecoration(
                    label: Text('Quantity'),
                    border: OutlineInputBorder(),
                    hintText: "Quantity",
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onChanged: (value) {
                    if (int.parse(selectedQtyController.text) <=
                            int.parse(onHandQtyController.text) ||
                        isElement) {
                      setState(() {
                        selectable = true;
                      });
                    } else {
                      setState(() {
                        selectable = false;
                      });
                    }
                    //
                  },
                  controller: selectedQtyController,
                  enabled: isElement ? false : true,
                  decoration: const InputDecoration(
                    label: Text('Selected Quantity'),
                    border: OutlineInputBorder(),
                    hintText: "Selected Quantity",
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: !selectable
                    ? () => null
                    : () {
                        String key = '';
                        if (widget.isOffloading) {
                          key = widget.arrivedElements!
                              .where((element) =>
                                  element.elementId == lotNoController.text)
                              .first
                              .ChildKey1;
                        }
                        if (isElement &&
                            totalElements
                                .where((element) =>
                                    element.elementId == lotNoController.text)
                                .isEmpty &&
                            lotNoController.text.isNotEmpty) {
                          setState(() {
                            selectedElements.add(ElementData(
                              partId: elementNumberController.text,
                              elementId: lotNoController.text,
                              elementDesc: elementDescriptionController.text,
                              erectionSeq: erectionSeqController.text,
                              erectionDate: estErectionDateController.text,
                              UOM: uomController.text,
                              weight: weightController.text,
                              area: areaController.text,
                              volume: volumeController.text,
                              quantity: onHandQtyController.text,
                              selectedQty: selectedQtyController.text,
                              ChildKey1: widget.isOffloading
                                  ? key.toString()
                                  : '${specifyMaxChildKey() + 1}',
                              fromBin: fromBin.text,
                            ));
                          });
                        }
                        if (!isElement) {
                          if (int.parse(onHandQtyController.text) <
                              int.parse(selectedQtyController.text)) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'Selected quantity cannot be greater than on hand quantity'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .canvasColor)),
                                      ),
                                    ],
                                  );
                                });
                          }
                          if (selectedQtyController.text == '') {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'Selected quantity cannot be empty'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .canvasColor)),
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            if (selectedParts.contains(PartData(
                                partNum: elementNumberController.text,
                                partDesc: elementDescriptionController.text,
                                uom: uomController.text,
                                qty: selectedQtyController.text))) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content:
                                          const Text('Part already selected'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .canvasColor)),
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              selectedParts.add(PartData(
                                  partNum: elementNumberController.text,
                                  partDesc: elementDescriptionController.text,
                                  uom: uomController.text,
                                  qty: selectedQtyController.text));
                            }
                          }
                        }
                        totalElements += selectedElements;
                        setState(() {
                          selectedElements.clear();
                        });

                        widget.onElementsSelected(totalElements, selectedParts);
                      },
                child: const Text('Select'),
                style: !selectable
                    ? ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
/*       */ /* }
        return const Center(child: CircularProgressIndicator());
      },*/ /*
    );*/
  }
}
