import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'Models/NotFoundException.dart';
import 'load_model.dart';
import '../utils/APIProviderV2.dart';
import 'package:provider/provider.dart';
import '../Providers/tenantConfig.dart';

class LoadTrack extends StatefulWidget {
  final dynamic tenantConfig;
  const LoadTrack({super.key, required this.tenantConfig});

  @override
  State<LoadTrack> createState() => _LoadTrackState();
}

class _LoadTrackState extends State<LoadTrack> {
  // Map controller for flutter_map
  final MapController _mapController = MapController();

  // Helper: format any incoming date string to YYYY-MM-DD (date only)
  String _formatDateOnly(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      String two(int n) => n < 10 ? '0$n' : '$n';
      return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
    } catch (_) {
      // Fallback: if it looks like "YYYY-MM-DD ...", take first 10 chars
      return raw.length >= 10 ? raw.substring(0, 10) : raw;
    }
  }

  // Coordinates storage
  List<LatLng> polylineCoordinates = [];
  List<Polyline> _polylines = [];
  List<Marker> markers = [];

  // Location data (defaults)
  double fromLatitude = 30.027756;
  double fromLongitude = 31.403733;
  double toLatitude = 30.050059;
  double toLongitude = 31.387759;

  Map<String, dynamic> fetchedWarehouseData = {};
  List<dynamic> fetchedWarehouseValue = [];
  Map<String, dynamic> fetchedSiteData = {};
  List<dynamic> fetchedSiteValue = [];

  // Initial map position
  final LatLng _initialPosition = const LatLng(30.027756, 31.403733);
  double _initialZoom = 13;

  // Form controllers
  final TextEditingController loadIDController = TextEditingController();
  final TextEditingController loadDateController = TextEditingController();
  final TextEditingController siteAddress = TextEditingController();      // Will show Address1 (To)
  final TextEditingController fromWarehouseController = TextEditingController();    // Will keep showing From code/name if desired
  final TextEditingController customerSiteController = TextEditingController();
  // NEW: status controller to show load status next to date
  final TextEditingController loadStatusController = TextEditingController();

  // NEW: controllers for coordinates row (third row)
  final TextEditingController longitudeController = TextEditingController(); // To location longitude
  final TextEditingController latitudeController = TextEditingController();  // To location latitude

  final _formKey = GlobalKey<FormState>();

  // Data storage
  Map<String, dynamic> loadData = {};
  List<dynamic> loadValue = [];
  LoadData? loadInfo;
  bool isPrinting = false;

  @override
  void initState() {
    super.initState();
    // _setupMarkers();
  }

  void _setupMarkers() {
    setState(() {
      markers = [
        Marker(
          point: LatLng(fromLatitude, fromLongitude),
          width: 40.0,
          height: 40.0,
          child: const Icon(Icons.location_pin, color: Colors.red),
        ),
        Marker(
          point: LatLng(toLatitude, toLongitude),
          width: 40.0,
          height: 40.0,
          child: const Icon(Icons.location_pin, color: Colors.blue),
        ),
      ];
    });
  }

  Future<void> _setupRoutes(LatLng origin, LatLng destination) async {
    try {
      final url =
          'http://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final points = coords
            .map<LatLng>((c) => LatLng(c[1] as double, c[0] as double))
            .toList();
        setState(() {
          _polylines = [
            Polyline(
              points: points,
              color: Colors.green,
              strokeWidth: 4.0,
            )
          ];
        });
      } else {
        throw Exception('Failed to fetch route');
      }
    } catch (e) {
      debugPrint('Error setting up routes: $e');
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

    try {
      final response = await http.post(
        loadURL,
        headers: {
          HttpHeaders.authorizationHeader: basicAuth,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          loadData = jsonResponse['returnObj'];
          loadValue = loadData['UD104'];
        });
        await getSiteList(widget.tenantConfig);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// UPDATED: Fetches ShipTo list and fills Address1 (To) + Longitude/Latitude (third row)
  Future<void> getSiteList(dynamic tenantConfigP) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final response = await http.get(
        Uri.parse(
            '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Erp.BO.ShipToSvc/ShipToes'),
        headers: {
          HttpHeaders.authorizationHeader: basicAuth,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        setState(() {
          fetchedSiteData = decoded;
          fetchedSiteValue = fetchedSiteData['value'] ?? [];
        });

        // If we have load info, attempt to map From/To to ShipTo entries
        // Assumptions:
        // - loadInfo!.fromWarehouse and loadInfo!.toWarehouse hold identifiers
        //   that match ShipToNum (preferred) or Name.
        String projectLoadID = loadIDController.text;
        loadInfo = getLoadObjectFromJson(projectLoadID);

        if (loadInfo != null) {
          final String fromKey = (loadInfo!.fromWarehouse).toString().trim();
          final String toKey = (loadInfo!.toWarehouse).toString().trim();

          Map<String, dynamic>? siteFrom = _findShipTo(fromKey);
          Map<String, dynamic>? siteTo = _findShipTo(toKey);

          // Fill the UI fields:
          // Second row RIGHT field: Address1 for the "To" location
          siteAddress.text = (siteTo?['Address1'] ?? '').toString();

          // Second row LEFT field can still show From code/name (up to you)
          fromWarehouseController.text = siteFrom != null
              ? (siteFrom['Name']?.toString().isNotEmpty == true
              ? siteFrom['Name'].toString()
              : fromKey)
              : fromKey;

          // Third row: Longitude & Latitude (show "To" coordinates as requested)
          final double? toLon = _toDouble(siteTo?['Longitude_c']);
          final double? toLat = _toDouble(siteTo?['Latitude_c']);
          longitudeController.text = toLon?.toString() ?? '';
          latitudeController.text = toLat?.toString() ?? '';

          // Update internal coords and map markers/route if available
          if (siteFrom != null) {
            final double? fLon = _toDouble(siteFrom['Longitude_c']);
            final double? fLat = _toDouble(siteFrom['Latitude_c']);
            if (fLon != null && fLat != null) {
              fromLongitude = fLon;
              fromLatitude = fLat;
            }
          }

          if (toLon != null && toLat != null) {
            toLongitude = toLon;
            toLatitude = toLat;
          }

          // Refresh map with the new points (if both are valid)
          if (!_anyNull([fromLatitude, fromLongitude, toLatitude, toLongitude])) {
            _setupMarkers();
            await _setupRoutes(
              LatLng(fromLatitude, fromLongitude),
              LatLng(toLatitude, toLongitude),
            );
            setState(() {
              _initialZoom = 9;
            });
          }
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Map<String, dynamic>? _findShipTo(String key) {
    if (key.isEmpty) return null;

    // 1) Prefer ShipToNum exact match
    try {
      return fetchedSiteValue.firstWhere(
            (s) => (s['ShipToNum']?.toString().trim() ?? '') == key,
      );
    } catch (_) {
      // 2) Fallback by Name
      try {
        return fetchedSiteValue.firstWhere(
              (s) => (s['Name']?.toString().trim() ?? '').toLowerCase() ==
              key.toLowerCase(),
        );
      } catch (_) {
        return null;
      }
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  bool _anyNull(List<double> xs) {
    for (final x in xs) {
      if (x.isNaN) return true;
    }
    return false;
  }

  LoadData? getLoadObjectFromJson(String loadID) {
    if (loadValue.isNotEmpty) {
      return LoadData.fromJson(
          loadValue.where((element) => element['Key1'] == loadID).first);
    }
    return null;
  }

  Future<void> _openMapDirections() async {
    final url = 'https://www.google.com/maps/dir/?api=1'
        '&origin=$fromLatitude,$fromLongitude'
        '&destination=$toLatitude,$toLongitude'
        '&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    loadIDController.dispose();
    loadDateController.dispose();
    loadStatusController.dispose();
    siteAddress.dispose();
    fromWarehouseController.dispose();
    customerSiteController.dispose();
    longitudeController.dispose();
    latitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).shadowColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Center(
          child: Text('Load Tracker', style: TextStyle(color: Colors.white)),
        ),
      ),
      body: isPrinting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
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
                              label: const Text('Load ID'),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await fetchLoadDataFromURL();
                            await getSiteList(widget.tenantConfig);
                            final String projectLoadID =
                                loadIDController.text;
                            loadInfo =
                                getLoadObjectFromJson(projectLoadID);
                            if (loadInfo != null) {
                              setState(() {
                                loadDateController.text =
                                    _formatDateOnly(loadInfo!.loadDate);
                                loadStatusController.text =
                                    (loadInfo!.loadStatus ?? '').toString();
                                // fromWarehouseController will be set inside getSiteList
                                // toWarehouseController will be Address1 set in getSiteList
                                customerSiteController.text =
                                    loadInfo!.toWarehouse;
                              });
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
                  // NEW: Load Date + Status in the same row
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
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
                              label: const Text('Load Date'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: loadStatusController,
                            enabled: false,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).canvasColor),
                              ),
                              label: const Text('Load Status'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // SECOND ROW: Left = From (name/code), Right = Address1 (To)
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
                              label: const Text('From Location'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: siteAddress,
                            enabled: false,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                    Theme.of(context).canvasColor),
                              ),
                              // UPDATED: show Address1 for the "To" site
                              label: const Text('To Address 1'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: TextFormField(
                  //           controller: longitudeController,
                  //           enabled: false,
                  //           decoration: InputDecoration(
                  //             fillColor: Colors.white,
                  //             filled: true,
                  //             border: OutlineInputBorder(
                  //               borderSide: BorderSide(
                  //                   color:
                  //                   Theme.of(context).canvasColor),
                  //             ),
                  //             label: const Text('Longitude'),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: TextFormField(
                  //           controller: latitudeController,
                  //           enabled: false,
                  //           decoration: InputDecoration(
                  //             fillColor: Colors.white,
                  //             filled: true,
                  //             border: OutlineInputBorder(
                  //               borderSide: BorderSide(
                  //                   color:
                  //                   Theme.of(context).canvasColor),
                  //             ),
                  //             label: const Text('Latitude'),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      height: height * 0.5,
                      width: width * 0.9,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).canvasColor,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _initialPosition,
                              initialZoom: _initialZoom,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                'com.IndexInfoTech.GoTrack',
                              ),
                              MarkerLayer(markers: markers),
                              PolylineLayer(polylines: _polylines),
                            ],
                          ),
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: FloatingActionButton(
                              onPressed: _openMapDirections,
                              backgroundColor:
                              Theme.of(context).primaryColor,
                              child: const Icon(Icons.directions),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
