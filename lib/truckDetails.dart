import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'truck_model.dart';
import 'truckresource_model.dart';
import 'load_model.dart';


class TruckDetailsForm extends StatefulWidget {
  final bool isEdit;
  LoadData? truckDetails;
  TruckDetailsForm({super.key, required this.isEdit, this.truckDetails});

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
  Map<String, dynamic> truckDetails = {};
  Map<String, dynamic> resourceDetails = {};

  TruckDetails? getTruckDetailsFromJson(String truckID) {
    if (truckDetails.containsKey(truckID)) {
      return TruckDetails.fromJson(truckDetails[truckID]);
    }
    return null;
  }

  ResourceDetails? getResourceDetailsFromJson(String resourceID) {
    if (resourceDetails.containsKey(resourceID)) {
      return ResourceDetails.fromJson(resourceDetails[resourceID]);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    truckIdController.text = widget.truckDetails?.truckId ?? '';
    resourceIdController.text = widget.truckDetails?.resourceId ?? '';
    plateNumberController.text = widget.truckDetails?.plateNumber ?? '';
    driverNameController.text = widget.truckDetails?.driverName ?? '';
    driverNumberController.text = widget.truckDetails?.driverNumber ?? '';
    capacityController.text = widget.truckDetails?.resourceCapacity ?? '';
    lengthController.text = widget.truckDetails?.resourceLength ?? '';
    widthController.text = widget.truckDetails?.resourceWidth ?? '';
    heightController.text = widget.truckDetails?.resourceHeight ?? '';
    volumeController.text = widget.truckDetails?.resourceVolume ?? '';
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
                          child: DropdownButtonFormField(
                            hint: const Text('Truck ID'),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),

                              items: const [
                                DropdownMenuItem(
                                  value: 'Truck 1',
                                  child: Text('Truck 1'),
                                ),
                                DropdownMenuItem(
                                  value: 'Truck 2',
                                  child: Text('Truck 2'),
                                ),
                                DropdownMenuItem(
                                  value: 'Truck 3',
                                  child: Text('Truck 3'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  truckIdController.text = value.toString();
                                });
                                TruckDetails? truckDetails = getTruckDetailsFromJson(truckIdController.text);
                                debugPrint(truckDetails.toString());
                                if (truckDetails != null) {
                                  plateNumberController.text = truckDetails.plateNumber;
                                  transporterNameController.text = truckDetails.transporterName;
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
                        child: DropdownButtonFormField(
                          hint: const Text('Resource'),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
          
                            items: const [
                              DropdownMenuItem(
                                value: 'Trailer 1',
                                child: Text('Trailer 1'),
                              ),
                              DropdownMenuItem(
                                value: 'Trailer 2',
                                child: Text('Trailer 2'),
                              ),
                              DropdownMenuItem(
                                value: 'Trailer 3',
                                child: Text('Trailer 3'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                resourceIdController.text = value.toString();
                              });
                              ResourceDetails? resourceDetails = getResourceDetailsFromJson(resourceIdController.text);
                              if (resourceDetails != null) {
                                capacityController.text = resourceDetails.capacity;
                                lengthController.text = resourceDetails.length;
                                widthController.text = resourceDetails.width;
                                heightController.text = resourceDetails.height;
                                volumeController.text = resourceDetails.volume;
                              }
                            },
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
                        //add dropdown item list with label truck ID
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //add dropdown item list with label truck ID
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField(
                              hint: const Text('Foreman Name'),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),

                                items: const [
                                  DropdownMenuItem(
                                    value: 'Foreman 1',
                                    child: Text('Foreman 1'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Foreman 2',
                                    child: Text('Foreman 2'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Foreman 3',
                                    child: Text('Foreman 3'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    // foremanName = value.toString();
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
                              decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                  labelText: "Department"),
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
