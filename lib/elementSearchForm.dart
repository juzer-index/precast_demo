import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:precast_demo/part_model.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'element_model.dart';

import 'package:http/http.dart' as http;


class ElementSearchForm extends StatefulWidget {
  final Function(List<ElementData>) onElementsSelected;
  const ElementSearchForm({super.key, required this.onElementsSelected});

  @override
  State<ElementSearchForm> createState() => _ElementSearchFormState();
}

class _ElementSearchFormState extends State<ElementSearchForm> {

  TextEditingController elementNumberController = TextEditingController();
  TextEditingController elementDescriptionController = TextEditingController();
  TextEditingController erectionSeqController = TextEditingController();
  TextEditingController estErectionDateController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController volumeController = TextEditingController();
  TextEditingController onHandQtyController = TextEditingController();
  TextEditingController selectedQtyController = TextEditingController();
  List<ElementData> selectedElements = [];
  List<PartData> selectedParts = [];
  TextEditingController lotNoController = TextEditingController();

  Map<String, dynamic> partData = {};
  List<dynamic> partValue = [];
  List<dynamic> consumables = [];
  List<dynamic> elements = [];

  Barcode? elementResult;
  String elementResultCode = '';
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:manager'))}';

  bool isElement = false;

  var partURL = Uri.parse('https://77.92.189.102/IITPrecastVertical/api/v1/BaqSvc/IIT_P_PartDetails(Precast)');
  var elementBAQ = Uri.parse('https://77.92.189.102/IITPrecastVertical/api/v1/BaqSvc/IIT_Getallpart6(Precast)');

  Future<void> getAllParts() async {
    try {
      final response = await http.get(
          partURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      if (response.statusCode == 200) {
        partData = jsonDecode(response.body);
        partValue = partData['value'];
        // for (var i = 0; i < partValue.length; i++) {
        //   if(partValue[i]['Part_IsElementPart_c'] == false){
        //     consumables.add(partValue[i]);
        //   }
        //   else {
        //     elements.add(partValue[i]);
        //   }
        // }
        // debugPrint(partValue.length.toString());
      } else {
        debugPrint(response.statusCode.toString());
      }
    }
    on Exception catch (e) {
      debugPrint(e.toString());
    }
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAllParts(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
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
                          hintText: "Element ID / Part ID",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: IconButton(
                      onPressed: () {
                        if(elementNumberController.text.isNotEmpty){
                          for(var i = 0; i < partValue.length; i++){
                            if(partValue[i]['PartNum'] == elementNumberController.text && partValue[i]['Part_IsElementPart_c'] == true){
                              //fetch element information from lot master
                              setState(() {
                                isElement = true;
                              });
                              break;
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
                            builder: (BuildContext context){
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
                                            onQRViewCreated: (QRViewController ) {
                                              controller = QRViewController;
                                              controller!.scannedDataStream.listen((scanData) {
                                                setState(() {
                                                  elementResult = scanData;
                                                  elementResultCode = elementResult?.code ?? 'Unknown';
                                                  elementNumberController.text = elementResultCode;
                                                });
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.1,
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
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Lot No.",
                      ),
                    ),
                  ),
                ),
              if(!isElement)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    enabled: false,
                    controller: lotNoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Lot No.",
                    ),
                  ),
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
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: erectionSeqController,
                        enabled: false,
                        decoration: const InputDecoration(
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
                          border: OutlineInputBorder(),
                          hintText: "Area",
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
                        controller: volumeController,
                        enabled: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Volume",
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
                        enabled: false,
                        decoration: const InputDecoration(
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
                        selectedElements.add(ElementData(
                          elementId: elementNumberController.text,
                          elementDesc: elementDescriptionController.text,
                          erectionSeq: erectionSeqController.text,
                          erectionDate: estErectionDateController.text,
                          weight: weightController.text,
                          area: areaController.text,
                          volume: volumeController.text,
                          quantity: onHandQtyController.text,
                          selectedQty: selectedQtyController.text,
                        ));
                        // setElementData();
                        widget.onElementsSelected(selectedElements);
                      },
                      child: const Text('Select'),

                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
