import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'element_model.dart';

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

  Barcode? elementResult;
  String elementResultCode = '';
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');


  @override
  void initState() {
    super.initState();
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
                      hintText: "Element ID",
                    ),
                  ),
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                onPressed: () {
                  // setElementData();
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: elementDescriptionController,
            enabled: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Element description",
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
}
