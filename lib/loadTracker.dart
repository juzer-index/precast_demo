import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points_plus/flutter_polyline_points_plus.dart';
import 'package:google_maps_directions/google_maps_directions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'load_model.dart';

class loadTrack extends StatefulWidget {
  final dynamic tenantConfig;
  const loadTrack(
      {super.key, required this.tenantConfig});
  @override
  State<loadTrack> createState() => _loadTrackState();
}

class _loadTrackState extends State<loadTrack>
    with SingleTickerProviderStateMixin {

  Map<String, dynamic> fetchedWarehouseData = {};
  List<dynamic> fetchedWarehouseValue = [];
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30, 30),
    zoom: 5,
  );

  double? fromLatitude = 30;
  double? fromLongtude = 30;
  double? toLatitude = 29;
  double? toLongtude = 31;

  TextEditingController loadIDController = TextEditingController();
  TextEditingController loadDateController = TextEditingController();
  TextEditingController toWarehouseController = TextEditingController();
  TextEditingController fromWarehouseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> loadData = {};
  List<dynamic> loadValue = [];
  LoadData? loadInfo;
  bool isPrinting = false;
  AddressPoint _destination = AddressPoint(lat: 30, lng: 30);
  Directions? _directions;
  String? _googleAPiKey;
  AddressPoint _origin = AddressPoint(lat: 31, lng: 29);
  List<Polyline>? _polylines;
  Set<Marker> markers = {};

  Future<void> _setupRoutes(AddressPoint p1, AddressPoint p2) async {
    _polylines = [];

    try {
      Directions directions = await getDirections(
          p1.lat,
          p1.lng,
          p2.lat,
          p2.lng,
          language: "fr_FR",
          googleAPIKey: "AIzaSyA_ugbgaUJZV5BeR1weSqxwJGZ78GUXCcE"
      );
      _directions = directions;

      List<LatLng> results = PolylinePoints().decodePolyline(
        directions.shortestRoute.overviewPolyline.points,
      ).map((PointLatLng point) {
        return LatLng(point.latitude, point.longitude);
      }).toList();
      LatLng origin = LatLng(p1.lat, p1.lng);
      LatLng destination = LatLng(p2.lat, p2.lng);
      final MarkerId originMarkerId = MarkerId(origin.toString());
      final MarkerId destinationMarkerId = MarkerId(destination.toString());

      setState(() {
        markers.add(
          Marker(
              markerId: originMarkerId,
              position: origin,
              infoWindow: InfoWindow(
                title: 'Origin',
                snippet: 'This is the origin',)
          ),
        );
        markers.add(
          Marker(
            markerId: destinationMarkerId,
            position: destination,
            infoWindow: InfoWindow(
              title: 'Destination',
              snippet: 'This is the destination',
            ),
          ),
        );
      });

      if (results.isNotEmpty) {
        setState(() {
          _polylines!.add(
            Polyline(
              width: 5,
              polylineId: PolylineId("${p1.lat}-${p1.lng}_${p2.lat}-${p2.lng}"),
              color: Colors.green,
              points: results
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList(),
            ),
          );

        });
      }
    } catch (e) {
      throw new Exception(e.toString());
    }
  }

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

  Future<void> getWarehouseList(dynamic tenantConfigP) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final response = await http.get(
        Uri.parse(
            '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/BaqSvc/Warehouse'
        ),
        headers: {
          HttpHeaders.authorizationHeader: basicAuth,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          fetchedWarehouseData = json.decode(response.body);
          fetchedWarehouseValue = fetchedWarehouseData['value'];
        });
        var fromWarehouse = fetchedWarehouseValue.firstWhere(
              (warehouse) => warehouse['Warehse_WarehouseCode'] == loadValue[0]['Character06'],
          orElse: () => null,
        );
        var toWarehouse = fetchedWarehouseValue.firstWhere(
              (warehouse) => warehouse['Warehse_WarehouseCode'] == loadValue[0]['Character07'],
          orElse: () => null,
        );

        if (fromWarehouse != null) {
          fromLongtude = double.parse(fromWarehouse['Warehse_Longitude_c']);
          fromLatitude = double.parse(fromWarehouse['Warehse_Latitude_c']);
        } else {
          print('From Warehouse not found');
        }
        if (toWarehouse != null) {
          toLongtude = double.parse(toWarehouse['Warehse_Longitude_c']);
          toLatitude = double.parse(toWarehouse['Warehse_Latitude_c']);
        } else {
          print('From Warehouse not found');
        }
        setState(() {
          markers.add(
              Marker(
                markerId: MarkerId('1'),
                position: LatLng(fromLatitude!, fromLongtude!),
                infoWindow: InfoWindow(
                  title: 'Cairo',
                  snippet: 'Cairo, Egypt',
                ),
              ));
          markers.add(
              Marker(
                markerId: MarkerId('2'),
                position: LatLng(toLatitude!, toLongtude!),
                infoWindow: InfoWindow(
                  title: 'Cairo',
                  snippet: 'Cairo, Egypt',
                ),
              ));
        });
        _origin = AddressPoint(lat: fromLatitude!, lng: fromLongtude!);
        _destination = AddressPoint(lat: toLatitude!, lng: toLongtude!);
        _setupRoutes(_origin, _destination);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
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
                              await getWarehouseList(widget.tenantConfig);
                              String projectLoadID =
                                  loadIDController.text;
                              loadInfo =
                                  getLoadObjectFromJson(projectLoadID);
                              if (loadInfo != null) {
                                setState(() {
                                  loadDateController.text =
                                      loadInfo!.loadDate;
                                  toWarehouseController.text =
                                      loadInfo!.toWarehouse;
                                  fromWarehouseController.text =
                                      loadInfo!.fromWarehouse;
                                });
                                await _setupRoutes(
                                  _origin,
                                  _destination,
                                );
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
                          markers:markers,
                          polylines: _polylines != null
                              ? Set<Polyline>.from(_polylines!)
                              : {},
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            )));
  }
}