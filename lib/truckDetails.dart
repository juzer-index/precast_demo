import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'truck_model.dart';
import 'truckresource_model.dart';
import 'load_model.dart';
import 'package:http/http.dart' as http;


class TruckDetailsForm extends StatefulWidget {
  final bool isEdit;
  LoadData? truckDetails;
  TruckDetails? truckMasterDetails;
  final Function(LoadData)? onTruckDetailsSelected;
  TruckDetailsForm({super.key, required this.isEdit, this.truckDetails, this.truckMasterDetails, this.onTruckDetailsSelected});

  @override
  State<TruckDetailsForm> createState() => _TruckDetailsFormState();
}

class _TruckDetailsFormState extends State<TruckDetailsForm> {
  TextEditingController truckIdController = TextEditingController();
  TextEditingController resourceIdController = TextEditingController();
  TextEditingController driverNameController = TextEditingController();
  TextEditingController transporterNameController = TextEditingController();
  TextEditingController plateNumberController = TextEditingController();
  TextEditingController driverNumberController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController volumeController = TextEditingController();
  TextEditingController? foremanNameController;
  TextEditingController? foremanIdController;
  TextEditingController? commentsController;
  Map<String, dynamic> truckDetails = {};
  ResourceDetails? resourceDetails;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var truckURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD102Svc/UD102s');
  var resourceURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD102Svc/UD102As');
  Map<String, dynamic> truckData = {};
  List<dynamic> truckValue = [];
  Map<String, dynamic> resourceData = {};
  List<dynamic>? resourceValue = [];
  List<dynamic> matchingResources = [];

  Map<String, dynamic> fetchedDriverData = {};
  List<dynamic> fetchedDriverValue = [];

  bool isTruckChanged = false;

  ResourceDetails? getResourceDetailsFromJson(String resourceID) {
    debugPrint(resourceID);
    if (resourceValue != null) {
      if(resourceValue!.where((element) => element['Character01'] == resourceID).isNotEmpty){
        resourceDetails = ResourceDetails.fromJson(resourceValue!.where((element) => element['Character01'] == resourceID).first);
        return resourceDetails;
      }
    }
    return null;
  }

  Future<void> getTrucksFromURL() async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:Adp@2023'))}';
    try {
      final response = await http.get(
          truckURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      final jsonResponse = json.decode(response.body);
      setState(() {
        truckData = jsonResponse;
        truckValue = truckData['value'];
      });
    }
    on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getResourceForTrucks(String resourceID) async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:Adp@2023'))}';
    var urL = Uri.parse("https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD102Svc/UD102As?\$filter=Key1 eq '$resourceID'");
    try {
      final response = await http.get(
          urL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      final jsonResponse = json.decode(response.body);
      setState(() {
        resourceData = jsonResponse;
        resourceValue = resourceData['value'];
        debugPrint(resourceValue.toString());
        // for (var element in resourceValue) {
        //   if (element['Key1'] == truckValue.where((element) => element['Character01'] == truckIdController.text).first['Key1']) {
        //     matchingResources.add(element);
        //   }
        // }
      });
    }
    on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getDriverList() async {
    final basicAuth = 'Basic ${base64Encode(utf8.encode('manager:Adp@2023'))}';
    try{
      final response = await http.get(
          Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_DriverName'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if (response.statusCode == 200) {
        setState(() {
          fetchedDriverData = json.decode(response.body);
          fetchedDriverValue = fetchedDriverData['value'];
        });
        debugPrint(fetchedDriverValue.toString());
      } else {
        throw Exception('Failed to load album');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getDriverList();
    getTrucksFromURL();
  }


  @override
  Widget build(BuildContext context) {
    if(widget.truckDetails != null && widget.truckMasterDetails == null){
      truckIdController.text = widget.truckDetails?.truckId.toString() ?? '';
      resourceIdController.text = widget.truckDetails?.resourceId.toString() ?? '';
      plateNumberController.text = widget.truckDetails?.plateNumber.toString() ?? '';
      driverNameController.text = widget.truckDetails?.driverName.toString() ?? '';
      driverNumberController.text = widget.truckDetails?.driverNumber.toString() ?? '';
      capacityController.text = widget.truckDetails?.resourceCapacity.toString() ?? '';
      lengthController.text = widget.truckDetails?.resourceLength.toString() ?? '';
      widthController.text = widget.truckDetails?.resourceWidth.toString() ?? '';
      heightController.text = widget.truckDetails?.resourceHeight.toString() ?? '';
      volumeController.text = widget.truckDetails?.resourceVolume.toString() ?? '';
      foremanNameController?.text = widget.truckDetails?.foremanName.toString() ?? '';
      foremanIdController?.text = widget.truckDetails?.foremanId.toString() ?? '';
    }
    if(widget.truckMasterDetails !=null){

    }
    return Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if(!widget.isEdit)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: truckIdController,
                            enabled: widget.isEdit,
                            decoration: const InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                labelText: "Truck ID"),
                          ),
                        ),
                      ),
                    if(widget.isEdit)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownSearch(
                            selectedItem: truckIdController.text,
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
                                labelText: "Truck",
                              ),
                            ),
                            items: truckValue
                                .map((value) => value['Character01'])
                                .toList(),
                            onChanged: (value) async {
                              setState(() {
                                truckIdController.text = value.toString();
                                resourceIdController.text = truckValue
                                    .where((element) =>
                                        element['Character01'] ==
                                        truckIdController.text)
                                    .first['Key1'];
                              });
                              plateNumberController.text = truckValue
                                  .where((element) =>
                                      element['Character01'] ==
                                      truckIdController.text)
                                  .first['Character02'];
                              await getResourceForTrucks(resourceIdController.text);
                              if (resourceValue != null) {
                                _formKey.currentState?.reset();
                              }
                            },
                          ),
                        ),
                      ),
                    if(!widget.isEdit)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            enabled: widget.isEdit,
                            controller: resourceIdController,
                            decoration: const InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                labelText: "Resource"),
                          ),
                        ),
                      ),
                    if(widget.isEdit)
                      Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: DropdownSearch(
                            selectedItem: resourceIdController.text,
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
                                labelText: "Resource",
                              ),
                            ),
                            items: resourceValue?.map((value) => value['Character01'])
                                .toList() ?? [],
                            onChanged: (value) async {
                              setState(() {
                                resourceIdController.text = value.toString();
                              });
                              await getResourceForTrucks(resourceIdController.text);
                              debugPrint(resourceIdController.text);
                              if(resourceDetails != null){
                                      setState(() {
                                        capacityController.text = resourceDetails!.capacity;
                                        lengthController.text = resourceDetails!.length;
                                        widthController.text = resourceDetails!.width;
                                        heightController.text = resourceDetails!.height;
                                        volumeController.text = resourceDetails!.volume;
                                      });
                                    }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    enabled: widget.isEdit,
                    controller: plateNumberController,
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                        labelText: "Plate Number"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //add dropdown item list with label truck ID
                    if(!widget.isEdit)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            enabled: widget.isEdit,
                            controller: driverNameController,
                            decoration: const InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                labelText: "Driver Name"),
                          ),
                        ),
                      ),
                    if(widget.isEdit)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownSearch(
                            selectedItem: driverNameController.text,
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
                                labelText: "Driver Name",
                              ),
                            ),
                            items: fetchedDriverValue
                                .map((value) => value['Driver_Name'])
                                .toList(),
                            onChanged: (value) async {
                              setState(() {
                                driverNameController.text = value.toString();
                              });
                            },
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          enabled: widget.isEdit,
                          controller: driverNumberController,
                          decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(),
                              labelText: "Driver Contact"),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ExpansionTile(
                  title: const Text('Truck Load'),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: widget.isEdit,
                              controller: capacityController,
                              decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                  labelText: "Capacity"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: widget.isEdit,
                              decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                  labelText: "Loaded"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //add dropdown item list with label truck ID
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: widget.isEdit,
                              controller: lengthController,
                              decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                  labelText: "Length"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: widget.isEdit,
                              controller: widthController,
                              decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                  labelText: "Width"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //add dropdown item list with label truck ID
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                enabled: widget.isEdit,
                                controller: heightController,
                                decoration: const InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(),
                                    labelText: "Height"),
                              ),
                            )
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: widget.isEdit,
                              controller: volumeController,
                              decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                  labelText: "Volume"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ExpansionTile(
                  title: const Text('Foreman Details'),
                  children: [
                    Row(
                      children: [
                        //add dropdown item list with label truck ID
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: foremanNameController,
                              enabled: widget.isEdit,
                              decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                  labelText: "Foreman ID"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            maxLines: 3,
                            enabled: widget.isEdit,
                            decoration: const InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                labelText: "Comments"),
                          ),
                        )
                        ),
                      ],
                    ),
                  ],
                ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       String finalTruckDetails = '$truckId $resourceId ${plateNumberController.text} ${driverNameController.text} ${driverNumberController.text}';
                  //       //pop back to projectDetailTabs with truck details
                  //       Navigator.pop(context, finalTruckDetails);
                  //     },
                  //     child: const Text('Submit'),
                  //   ),
                  // ),
              ],
            ),
          );
  }
}
