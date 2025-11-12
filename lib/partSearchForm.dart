import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'part_model.dart';
import 'dart:convert';
/*Deprecated*/

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



  // Barcode? partResult;
  String partResultCode = '';
  // QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Future<void> fetchPartDataFromJson() async {
    final jsonString = await rootBundle.loadString('assets/data_parts.json');
    setState(() {
      fetchedPartData = json.decode(jsonString);
      List<dynamic> raw = fetchedPartData['value'] ?? [];
      // Determine if any status-like field exists in the dataset
      bool hasStatusField = raw.any((e) => e is Map && (e.containsKey('Status') || e.containsKey('ElementStatus_c') || e.containsKey('Part_Status_c')));
      if (hasStatusField) {
        // Keep only parts where any status field equals 'Casted'
        fetchedPartValue = raw.where((e) {
          if (e is! Map) return false;
          final status = (e['Status'] ?? e['ElementStatus_c'] ?? e['Part_Status_c'])?.toString();
          return status == 'Casted';
        }).toList();
      } else {
        // No status field in the source; leave results as-is to avoid empty list in dev data
        fetchedPartValue = raw;
      }
    });
  }

  PartData? getPartObjectfromJson(String partNum){
    if(fetchedPartValue.isNotEmpty){
      final match = fetchedPartValue.where((element) => element['Part_PartNum'] == partNum);
      if (match.isEmpty) return null;
      PartData partData = PartData.fromJson(match.first);
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
    // Search only within the filtered dataset
    final match = fetchedPartValue.where((element) => element['Part_PartNum'] == partNumberController.text);
    if (match.isEmpty) {
      // Show a friendly message if not found or filtered out due to status
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Not Found'),
          content: const Text('No part found with status Casted for this Part ID.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }
    PartData parts = PartData.fromJson(match.first);
    setState(() {
      partDescriptionController.text = parts.partDesc;
      onHandQtyController.text = parts.qty;
      uomController.text = parts.uom;
    });
  }

}
