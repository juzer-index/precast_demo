import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'part_model.dart';
import 'dart:convert';
import 'package:qr_code_scanner/qr_code_scanner.dart';


class PartSearchForm extends StatefulWidget {
  final Function(List<PartData>) onPartsSelected;
  const PartSearchForm({super.key, required this.onPartsSelected});

  @override
  State<PartSearchForm> createState() => _PartSearchFormState();
}

class _PartSearchFormState extends State<PartSearchForm> {

  List<PartData> selectedParts = [];
  List<int> selectedPartQty = [];
  TextEditingController partNumberController = TextEditingController();
  TextEditingController lotNoController = TextEditingController();
  TextEditingController partDescriptionController = TextEditingController();
  TextEditingController onHandQtyController = TextEditingController();
  TextEditingController uomController = TextEditingController();
  TextEditingController selectedQtyController = TextEditingController();
  Map<String, dynamic> fetchedPartData = {};
  List<dynamic> fetchedPartValue = [];



  Barcode? partResult;
  String partResultCode = '';
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Future<void> fetchPartDataFromJson() async {
    final jsonString = await rootBundle.loadString('assets/data_parts.json');
    setState(() {
      fetchedPartData = json.decode(jsonString);
      fetchedPartValue = fetchedPartData['value'];
    });
  }

  PartData? getPartObjectfromJson(String partNum){
    if(fetchedPartValue.isNotEmpty){
      PartData partData = PartData.fromJson(fetchedPartValue.where((element) => element['Part_PartNum'] == partNum).first);
      return partData;
    }
    return null;
  }

  @override
  void initState() {
    fetchPartDataFromJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height *
          0.4,
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: partNumberController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Part ID",),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                onPressed: () {
                  setPartData();
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
                                      onQRViewCreated: (controller) {
                                        setState(() {
                                          this.controller = controller;
                                        });
                                        controller.scannedDataStream.listen((scanData) {
                                          setState(() {
                                            partResult = scanData;
                                            partResultCode = partResult?.code ?? 'Unknown';
                                            partNumberController.text = partResult?.code ?? 'Unknown';
                                          });
                                          setPartData();
                                        });

                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.1,
                                  child: Center(
                                    child: Text(
                                        'Data: $partResultCode'
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
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
          ]),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    enabled: false,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Lot No."),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: partDescriptionController,
                    enabled: false,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Part Description"),
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
                    controller: onHandQtyController,
                    enabled: false,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "On Hand Qty"),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: uomController,
                    enabled: false,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "UOM"),
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
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Selected Qty"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedParts.add(PartData(partNum: partNumberController.text, partDesc: partDescriptionController.text, uom: uomController.text, qty: onHandQtyController.text, selectedQty: selectedQtyController.text));
                    });
                    widget.onPartsSelected(selectedParts);
                  },
                  child: const Text('Select'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void setPartData() {
    PartData parts = PartData.fromJson(fetchedPartValue.where((element) => element['Part_PartNum'] == partNumberController.text).first);
    setState(() {
      partDescriptionController.text = parts.partDesc;
      onHandQtyController.text = parts.qty;
      uomController.text = parts.uom;
    });
  }

}
