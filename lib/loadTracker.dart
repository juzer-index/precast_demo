import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'load_model.dart';

class loadTrack extends StatefulWidget {
  final int initialTabIndex;
  final dynamic tenantConfig;
  const loadTrack(
      {super.key, required this.initialTabIndex, required this.tenantConfig});

  @override
  State<loadTrack> createState() => _loadTrackState();
}

class _loadTrackState extends State<loadTrack>
    with SingleTickerProviderStateMixin {

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.044420, 31.235712),
    zoom: 14.4746,
  );
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  TextEditingController loadIDController = TextEditingController();
  TextEditingController loadDateController = TextEditingController();
  TextEditingController toWarehouseController = TextEditingController();
  TextEditingController fromWarehouseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> loadData = {};
  List<dynamic> loadValue = [];

  LoadData? loadInfo;
  bool isPrinting = false;

  Future<void> fetchLoadDataFromURL() async {
    final loadURL = Uri.parse(
        '${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/GetByID');
    Map<String, dynamic> body = {
      "key1": loadIDController.text,
      "key2": "",
      "key3": "",
      "key4": "",
      "key5": ""
    };
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';

    Completer<void> completer = Completer<void>();

    try {
      final response = await http.post(loadURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(body));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        setState(() {
          loadData = jsonResponse['returnObj'];
          loadValue = loadData['UD104'];
        });

        // Resolve the completer when the states are set
        completer.complete();
      } else {
        throw new Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    // Return the future associated with the completer
    return completer.future;
  }

  LoadData? getLoadObjectFromJson(String loadID) {
    if (loadValue.isNotEmpty) {
      LoadData loadObject = LoadData.fromJson(
          loadValue.where((element) => element['Key1'] == loadID).first);
      return loadObject;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height= MediaQuery.of(context).size.height;
    double width= MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Theme.of(context).shadowColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(),
                Text('Load Tracker', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          actions: const [],
        ),
        body: isPrinting
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Center(
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: loadIDController,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                      Theme.of(context).canvasColor),
                                ),
                                label: Text('Load ID'),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await fetchLoadDataFromURL();
                              /*                                await fetchElementDataFromURL();
                                  await fetchPartDataFromURL();*/
                              /*await fetchElementANDPartsDataFromURL();*/
                              String projectLoadID =
                                  loadIDController.text;
                              loadInfo =
                                  getLoadObjectFromJson(projectLoadID);
                              /*                                getElementObjectFromJson(projectLoadID);
                                  getPartObjectFromJson(projectLoadID);*/
                              if (loadInfo != null) {
                                if (loadInfo!.loadStatus == 'Closed') {
                                  if (mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Warning'),
                                          content: const Text(
                                              'This Load has already been delivered'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Close',
                                                  style: TextStyle(
                                                      color: Theme.of(
                                                          context)
                                                          .canvasColor)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                                setState(() {
                                  loadDateController.text =
                                      loadInfo!.loadDate;
                                  toWarehouseController.text =
                                      loadInfo!.toWarehouse;
                                  fromWarehouseController.text =
                                      loadInfo!.fromWarehouse;
                                });
                              } else {
                                if (mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Error'),
                                        content: const Text(
                                            'Load ID not found'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            },
                            icon: Icon(
                              Icons.search,
                              color: Theme.of(context).canvasColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: loadDateController,
                        enabled: false,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).canvasColor),
                          ),
                          label: Text('Load Date'),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: toWarehouseController,
                              enabled: false,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                      Theme.of(context).canvasColor),
                                ),
                                label: Text('To Warehouse'),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: fromWarehouseController,
                              enabled: false,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                      Theme.of(context).canvasColor),
                                ),
                                label: Text('From Warehouse'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        height: height * 0.5, // Provide a bounded height
                        width: width * 0.9, // Provide a bounded width
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).canvasColor,
                            width: 2,
                          ),
                        ),
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: _kGooglePlex,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          markers: {
                            Marker(
                              markerId: MarkerId('1'),
                              position: LatLng(30.044420, 31.235712),
                              infoWindow: InfoWindow(
                                title: 'Cairo',
                                snippet: 'Cairo, Egypt',
                              ),
                            ),
                          },
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            )));
  }
}
