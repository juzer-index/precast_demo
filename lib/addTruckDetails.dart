import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precast_demo/indexAppBar.dart';

class TruckDetails {
  late final String plateNumber;
  late final String transporterName;
  TruckDetails({required this.plateNumber, required this.transporterName});

  factory TruckDetails.fromJson(Map<String, dynamic> json) {
    return TruckDetails(
      plateNumber: json['Plate'],
      transporterName: json['Transporter'],
    );
  }
}

class ResourceDetails {
  late final String capacity;
  late final String length;
  late final String width;
  late final String height;
  late final String volume;
  ResourceDetails({required this.capacity, required this.length, required this.width, required this.height, required this.volume});

  factory ResourceDetails.fromJson(Map<String, dynamic> json) {
    return ResourceDetails(
      capacity: json['Capacity'],
      length: json['Length'],
      width: json['Width'],
      height: json['Height'],
      volume: json['Volume'],
    );
  }
}

class AddTruckDetails extends StatefulWidget {
  const AddTruckDetails({super.key});

  @override
  State<AddTruckDetails> createState() => _AddTruckDetailsState();
}

class _AddTruckDetailsState extends State<AddTruckDetails> {
  late String truckId;
  late String resourceId;
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

  Future<void> fetchTruckDetails() async {
    String jsonString = await rootBundle.loadString('assets/truckDetails.json');
    Map<String, dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      truckDetails = jsonResponse;
    });
  }

  Future<void> fetchResourceDetails() async {
    String jsonString = await rootBundle.loadString('assets/resourceDetails.json');
    Map<String, dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      resourceDetails = jsonResponse;
    });
  }

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
    fetchTruckDetails();
    fetchResourceDetails();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndexAppBar(title: 'Add Truck Details',),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Truck Details',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade400)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                                truckId = value.toString();
                              });
                              TruckDetails? truckDetails = getTruckDetailsFromJson(truckId);
                              debugPrint(truckDetails.toString());
                              if (truckDetails != null) {
                                plateNumberController.text = truckDetails.plateNumber;
                                transporterNameController.text = truckDetails.transporterName;
                              }
                            },
                        ),
                      ),
                    ),
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
                                resourceId = value.toString();
                              });
                              ResourceDetails? resourceDetails = getResourceDetailsFromJson(resourceId);
                              debugPrint(resourceId);
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //add dropdown item list with label truck ID
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: plateNumberController,
                          decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(),
                              labelText: "Plate Number"),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: transporterNameController,
                          decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(),
                              labelText: "Transporter Name"),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Driver Details',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade400)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Truck Load',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade400)),
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
                          controller: widthController,
                          decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(),
                              labelText: "Width"),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: heightController,
                          decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(),
                              labelText: "Height"),
                        ),
                      )
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Foreman Details',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade400)),
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      String finalTruckDetails = '$truckId $resourceId ${plateNumberController.text} ${driverNameController.text} ${driverNumberController.text}';
                      //pop back to projectDetailTabs with truck details
                      Navigator.pop(context, finalTruckDetails);
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
