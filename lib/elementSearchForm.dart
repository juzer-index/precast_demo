import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:IIT_precast_app/part_model.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'element_model.dart';

import 'package:http/http.dart' as http;


class ElementSearchForm extends StatefulWidget {
  final Function(List<ElementData>, List<PartData>) onElementsSelected;
  List<ElementData>? arrivedElements = [];
  bool isOffloading;
  dynamic warehouse;
  ElementSearchForm({super.key, required this.onElementsSelected, this.arrivedElements, required this.isOffloading , this.warehouse });

  @override
  State<ElementSearchForm> createState() => _ElementSearchFormState();
}

class _ElementSearchFormState extends State<ElementSearchForm> {

  TextEditingController elementNumberController = TextEditingController();
  TextEditingController elementDescriptionController = TextEditingController();
  TextEditingController erectionSeqController = TextEditingController();
  TextEditingController estErectionDateController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController companyController =TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController volumeController = TextEditingController();
  TextEditingController onHandQtyController = TextEditingController();
  TextEditingController selectedQtyController = TextEditingController();
  TextEditingController uomController = TextEditingController();
  List<ElementData> selectedElements = [];
  List<PartData> selectedParts  = [];
  TextEditingController lotNoController = TextEditingController();

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

  final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:Adp@2023'))}';

  bool isElement = false;
  bool isLoading = false;

  var partURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_P_PartDetails_V1(158095)');
  Future<void> getAllParts(String partNum) async {
    try {

      final response = await http.get(
            Uri.parse(
               'https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_P_PartDetails_V1(158095)/?\$filter=Part_PartNum   eq    \'$partNum\''),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        partData = jsonDecode(response.body);
         setState(() {
            partValue = partData['value'];
         });



        debugPrint(partValue.length.toString());
      } else {
        debugPrint(response.statusCode.toString());
      }
    }
    on Exception catch (e) {
      debugPrint(e.toString());
    }
  }


  Future<void> getLotForElements() async {
    try {
       String partNum =elementNumberController.text;
      var elementLotURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_PartAndLotNumber(158095)?\$filter=PartLot_PartNum  eq  \'$partNum\'');//?\$filter=PartLot_LotNum eq \'$Param\'&\$top=$page&\$skip=$offset';
      final response = await http.get(
          elementLotURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      if (response.statusCode == 200) {
        elementData = jsonDecode(response.body);
        elementValue = elementData['value'];

        elements= elementValue.map((e) => e['PartLot_LotNum']).toList();

        debugPrint(elements.toString());
      } else {
        debugPrint(response.statusCode.toString());
      }
    }
    on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getElementDetailsFromLot(String lotNo, String partNum) async {
    try {
      final response = await http.get(
          Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates(158095,$partNum,$lotNo)'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
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
          estErectionDateController.text = lotData['ErectionPlannedDate_c'];
          onHandQtyController.text = '1';
          selectedQtyController.text = '1';
        });
      } else {
        debugPrint(response.statusCode.toString());
      }
    }
    on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getConsumableDetails(String partNum) async {
    try {
      var consumableURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_NonTrackPart/?\$filter=Part_PartNum eq \'$partNum\'');//?\$filter=PartLot_LotNum eq \'$Param\'&\$top=$page&\$skip=$offset';
      final response = await http.get(consumableURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      if (response.statusCode == 200) {
        consumableData = jsonDecode(response.body);
        for (var i = 0; i < consumableData['value'].length; i++) {
          if(consumableData['value'][i]['Part_PartNum'] == partNum){
            elementDescriptionController.text = consumableData['value'][i]['Part_PartDescription'];
            uomController.text = consumableData['value'][i]['Part_IUM'];
            onHandQtyController.text = consumableData['value'][i]['Calculated_OnHandQty'].toString();
            break;
          }
        }
      } else {
        debugPrint(response.statusCode.toString());
      }
    }
    on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> getScannedElement(String partNum, String elementId, String companyId) async {
    try {
      final response = await http.get(
          Uri.parse(
              'https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates($companyId,$partNum,$elementId)'),
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
    totalElements = widget.arrivedElements!;
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
                    child: isLoading? const Center(
                      child: CircularProgressIndicator(),
                    ) : IconButton(
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

                            if(partValue[0]['Part_IsElementPart_c'] == true){
                              isElement = true;
                              await getLotForElements();
                            }
                            else{
                              isElement = false;
                              await getConsumableDetails(elementNumberController.text);
                            }}
                          }
                       if(widget.isOffloading){
                          if(elementNumberController.text.isNotEmpty){
                            for(var i = 0; i < widget.arrivedElements!.length; i++) {
                              if (widget.arrivedElements![i].partId ==
                                  elementNumberController.text) {
                                elements.add(widget.arrivedElements![i]
                                    .elementId);
                                setState(() {
                                  isElement = true;
                                });
                              }
                            }
                          } else{
                                if (mounted) {
                                  showDialog(context: context, builder: (BuildContext context){
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text('Part not found in arrived elements'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  });
                                }
                              }
                            }
                        }
                      ,
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
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.6,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.8,
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
                                              controller!.scannedDataStream.listen((
                                                  scanData) async {
                                                String elementId = '';
                                                String partNum = '';
                                                String companyId = '';
                                                controller!.pauseCamera();
                                                Navigator.pop(context);
                                                debugPrint('this is the code ${scanData.code}');
                                                List<String> scanResult = scanData.code!.split('-');
                                                if (scanResult.length >= 4) {
                                                  elementId = scanResult.sublist(3).join("-");
                                                  partNum = scanResult[2];
                                                  companyId = scanResult[1];
                                                  await getScannedElement(partNum, elementId, companyId);
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
                                                await getScannedElement(partNum, elementId, companyId);
                                                setState(() {
                                                  isElement = true;
                                                  elementNumberController.text = partNum;
                                                  elementDescriptionController.text = elementListData['PartLotDescription'];
                                                  lotNoController.text = elementListData['LotNum'];
                                                  uomController.text = elementListData['PartNumSalesUM'];
                                                  erectionSeqController.text = elementListData['ErectionSequence_c'].toString();
                                                  weightController.text = elementListData['Ton_c'];
                                                  areaController.text = elementListData['M2_c'];
                                                  volumeController.text = elementListData['M3_c'];
                                                  estErectionDateController.text = elementListData['ErectionPlannedDate_c'] ?? '';
                                                  onHandQtyController.text = '1';
                                                  elementResult = scanData;
                                                  elementResultCode =
                                                  elementResult?.code ??
                                                      'Unknown';
                                                  elementNumberController.text =
                                                  partNum;
                                                });
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .height * 0.1,
                                        child: Center(
                                          child: Text(
                                              'Data: $elementResultCode'
                                          ),
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
                            }
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                    ),
                  ),
                ],
              ),
              if(isElement)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:Stack(children: [ DropdownSearch(
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
                    items: elements.isNotEmpty?elements:[],
                    onChanged: (value) async {

                      await getElementDetailsFromLot(value, elementNumberController.text);

                    },
                  ),
                    if(elements.isEmpty) const SizedBox(
                        height: 60,
                        child:Center(child: CircularProgressIndicator())
                    ),
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
              if(isElement)
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
                      onPressed: () {
                        if (isElement) {
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
                          ));
                        }
                        if (!isElement){
                          if(int.parse(onHandQtyController.text) < int.parse(selectedQtyController.text)){
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text('Selected quantity cannot be greater than on hand quantity'),
                                    actions: <Widget>[
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
                          }
                          if(selectedQtyController.text == ''){
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text('Selected quantity cannot be empty'),
                                    actions: <Widget>[
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
                          }
                          else{
                            if (selectedParts.contains(PartData(partNum: elementNumberController.text, partDesc: elementDescriptionController.text, uom: uomController.text, qty: selectedQtyController.text))) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text('Part already selected'),
                                      actions: <Widget>[
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
                            }
                            else {
                              selectedParts.add(PartData(
                                  partNum: elementNumberController.text,
                                  partDesc: elementDescriptionController.text,
                                  uom: uomController.text,
                                  qty: selectedQtyController.text));
                            }
                          }
                        }
                        totalElements += selectedElements;
                        widget.onElementsSelected(totalElements,selectedParts);
                      },
                      child: const Text('Select'),

                    ),
                  ),
                ],
              ),
            ],
          );
/*       *//* }
        return const Center(child: CircularProgressIndicator());
      },*//*
    );*/
  }
}
