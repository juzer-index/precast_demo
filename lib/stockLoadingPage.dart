import 'dart:async';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:precast_demo/elementTable.dart';
import 'package:precast_demo/partTable.dart';
import 'package:precast_demo/elementSearchForm.dart';
import 'package:precast_demo/stockOffloadingPage.dart';
import 'package:precast_demo/truckDetails.dart';
import 'package:precast_demo/truckresource_model.dart';
import 'dart:convert';
import 'load_model.dart';
import 'part_model.dart';
import 'element_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class StockLoading extends StatefulWidget {
  final int initialTabIndex;
  final bool isUpdate;
  const StockLoading({super.key, required this.initialTabIndex, required this.isUpdate});

  @override
  State<StockLoading> createState() => _StockLoadingState();
}

class _StockLoadingState extends State<StockLoading> with SingleTickerProviderStateMixin{

  late TabController _tabController;
  TextEditingController dateController = TextEditingController();
  TextEditingController loadTimeController = TextEditingController();
  TextEditingController truckController = TextEditingController();
  TextEditingController loadIDController = TextEditingController();
  String _selectedDate = '';
  String loadTypeValue = '';
  String loadConditionValue = '';
  String inputTypeValue = 'Manual';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _truckKey = GlobalKey<FormState>();
  TextEditingController projectIdController = TextEditingController();
  TextEditingController fromWarehouseController = TextEditingController();
  TextEditingController toWarehouseController = TextEditingController();
  TextEditingController toWarehouseNameController = TextEditingController();

  TextEditingController toBinController = TextEditingController();
  TextEditingController toBinNameController = TextEditingController();

  TextEditingController? poNumberController = TextEditingController();
  TextEditingController? poLineController = TextEditingController();
  TextEditingController? commentsController = TextEditingController();
  List<ElementData> selectedElements = [];
  List<PartData> selectedParts = [];
  String resourceId = '';

  Map<String, dynamic> fetchedProjectData = {};
  List<dynamic> fetchedProjectValue = [];

  Map<String, dynamic> fetchedWarehouseData = {};
  List<dynamic> fetchedWarehouseValue = [];

  Map<String, dynamic> fetchedBinData = {};
  List<dynamic> fetchedBinValue = [];

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
  TextEditingController loadedController = TextEditingController();
  Map<String, dynamic> truckDetails = {};
  ResourceDetails? resourceDetails;
  TextEditingController foremanId = TextEditingController();
  TextEditingController foremanName = TextEditingController();

  Map<String, dynamic> loadData = {};
  List<dynamic> loadValue = [];

  Map<String, dynamic> elementData = {};
  List<dynamic> elementValue = [];

  Map<String, dynamic> partData = {};
  List<dynamic> partValue = [];

  Map<String, dynamic> foremanData = {};
  List<dynamic> foremanValue = [];

  LoadData? offloadData;
  final loadURL = Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/Ice.BO.UD103Svc/UD103s');
  final detailsURL = Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/Ice.BO.UD103Svc/UD103As');

  var truckURL = Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/Ice.BO.UD102Svc/UD102s');
  var resourceURL = Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/Ice.BO.UD102Svc/UD102As');

  Map<String, dynamic> truckData = {};
  List<dynamic> truckValue = [];
  Map<String, dynamic> resourceData = {};
  List<dynamic>? resourceValue = [];
  List<dynamic> matchingResources = [];

  Map<String, dynamic> fetchedDriverData = {};
  List<dynamic> fetchedDriverValue = [];

  bool isTruckChanged = false;

  bool isLoaded = false;

  late int lastLoad = 50;
  late final int l1;
  late final int l2;
  late final String nextLoad;

  final basicAuth = 'Basic ${base64Encode(utf8.encode('manager:manager'))}';
  late final Future dataloaded;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this); // Change 3 to the number of tabs
    _tabController.index = widget.initialTabIndex;
    dataloaded=MakeSureDataLoaded();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    loadTimeController.text = DateFormat('HH:mm').format(DateTime.now());
    return DefaultTabController(
        length: 3,
        initialIndex: widget.initialTabIndex,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme
                .of(context)
                .primaryColor,
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(),
                  if(widget.isUpdate)
                    const Text('Edit Load', style: TextStyle(color: Colors.white)),
                  if(!widget.isUpdate)
                    const Text('Stock Loading', style: TextStyle(color: Colors.white)),
                  // ClipOval(
                  //   child: Image.network(
                  //     'https://media.licdn.com/dms/image/D4D03AQFpmZgzpRLrhg/profile-displayphoto-shrink_800_800/0/1692612499698?e=1711584000&v=beta&t=Ho-Wta1Gpc-aiWZMJrsni_83CG16TQeq_gtbIJBM7aI',
                  //     height: 35,
                  //     width: 35,
                  //   ),
                  // )
                ],
              ),
            ),
            actions: [
              PopupMenuButton(itemBuilder: (BuildContext context) {
                return [
                  if(widget.isUpdate)
                    PopupMenuItem(
                      child: ListTile(
                        title: const Text('Create New Load'),
                        leading: const Icon(Icons.edit_calendar),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const StockLoading(initialTabIndex: 0, isUpdate: false)));
                        },
                      ),
                    ),
                  if(!widget.isUpdate)
                    PopupMenuItem(
                      child: ListTile(
                        title: const Text('Edit a Load'),
                        leading: const Icon(Icons.edit_calendar),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const StockLoading(initialTabIndex: 0, isUpdate: true)));
                        },
                      ),
                    ),
                  PopupMenuItem(
                    child: ListTile(
                      title: const Text('Offload'),
                      leading: const Icon(Icons.playlist_remove),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const StockOffloading(initialTabIndex: 0)));
                      },
                    ),
                  ),
                ];
              }
              ) ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  text: 'Detail',
                ),
                Tab(
                  text: 'Line',
                ),
                Tab(
                  text: 'Summary',
                ),
              ],
            ),
          ),
          body: FutureBuilder(
            future: dataloaded,
              builder:(context,sapshot){
               if(fetchedProjectData.isEmpty){
                    return  Stack(
                      children: [
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ), // Show spinner when disabled
                        ),
                      ],
                    );
                  }

               return Padding(

                  padding: const EdgeInsets.all(8.0),
                  child: TabBarView(
                      controller: _tabController,
                      children: [
                        //Tab 1 Content
                        SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Center(
                              child: Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Load Details',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blue),
                                    ),
                                  ),
                                  if(!widget.isUpdate)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: loadIDController,
                                        enabled: false,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Load ID"),
                                      ),
                                    ),
                                  if(widget.isUpdate)
                                    Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                controller: loadIDController,
                                                decoration: const InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    labelText: "Load ID"),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              await fetchLoadDataFromURL();
                                              await fetchElementDataFromURL();
                                              await fetchPartDataFromURL();
                                              String projectLoadID = loadIDController.text;
                                              offloadData = getLoadObjectFromJson(projectLoadID);
                                              getElementObjectFromJson(projectLoadID);
                                              getPartObjectFromJson(projectLoadID);
                                              if (offloadData != null) {
                                                setState(() {
                                                  projectIdController.text = offloadData!.projectId;
                                                  dateController.text = offloadData!.loadDate;
                                                  toWarehouseController.text = offloadData!.toWarehouse;
                                                  toBinController.text = offloadData!.toBin;
                                                  loadTypeValue = offloadData!.loadType;
                                                  loadConditionValue = offloadData!.loadCondition;
                                                  fromWarehouseController.text = offloadData!.fromWarehouse;
                                                  isLoaded = true;
                                                });
                                              }
                                              else {
                                                if(mounted) {
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
                                            icon: const Icon(Icons.search),
                                          ),
                                        ]
                                    ),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FutureBuilder(

                                        future: getProjectList(),
                                        builder:(context,snapshot){
                                          if(fetchedProjectData.isEmpty){
                                            return  Stack(
                                              children: [
                                                DropdownSearch(
                                                  selectedItem: projectIdController.text,
                                                  enabled: false, // Disable the DropdownSearch
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
                                                  dropdownDecoratorProps: DropDownDecoratorProps(
                                                    dropdownSearchDecoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      labelText: "Project ID",
                                                    ),
                                                  ),
                                                  items: fetchedProjectValue.map((project) => project['Description']).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      projectIdController.text = fetchedProjectValue.firstWhere((project) => project['Description'] == value)['ProjectID'];
                                                    });
                                                  },
                                                ),

                                                Positioned.fill(
                                                  child:Center(
                                                    child: CircularProgressIndicator(
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                                    ), // Show spinner when disabled
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return DropdownSearch(
                                            selectedItem: projectIdController.text,
                                            enabled: !widget.isUpdate,
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
                                                labelText: "Project ID",
                                              ),
                                            ),
                                            items: fetchedProjectValue.map((project) => project['Description']).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                projectIdController.text = fetchedProjectValue.firstWhere((project) => project['Description'] == value)['ProjectID'];
                                              });
                                            },

                                          );
                                        },

                                      )

                                    /*DropdownSearch(
                                selectedItem: projectIdController.text,
                                enabled: !widget.isUpdate,
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
                                    labelText: "Project ID",
                                  ),
                                ),
                                asyncItems: Test_Moha,//fetchedProjectValue.map((project) => project['Description']).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    projectIdController.text = value.toString();
                                  });
                                },
                              ),*/
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            enabled: !widget.isUpdate,
                                            controller: dateController,
                                            onTap: () async {
                                              final DateTime? date = await showDatePicker(
                                                builder: (BuildContext context, Widget? child) {
                                                 return Theme(
                                                   data: ThemeData.light().copyWith(
                                                     colorScheme: ColorScheme.light(
                                                       primary :Theme.of(context).primaryColor,
                                                       background: Colors.white,
                                                       secondary: Theme.of(context).primaryColor,
                                                       outline: Colors.cyanAccent,




                                                     ),
                                                   ),
                                                   child: child!,
                                                 );
                                                },

                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2018),
                                                lastDate: DateTime(2030),
                                              );
                                              if (date != null) {
                                                setState(() {
                                                  dateController.text =
                                                  "${date.day}/${date.month}/${date
                                                      .year}";
                                                  _selectedDate = DateFormat('yyyy-MM-dd').format(date);
                                                });
                                              }
                                            },
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "Load Date"),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              enabled: !widget.isUpdate,
                                              onTap: () async {
                                                final TimeOfDay? time = await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                  builder:(context,child  ){
                                                    return Theme(
                                                      data:Theme.of(context).copyWith(
                                                        colorScheme: ColorScheme.light(
                                                          primary: Theme.of(context).primaryColor,
                                                          onPrimary: Colors.white,
                                                          secondary: Theme.of(context).primaryColor,
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );

                                                  }
                                                );
                                                if (time != null) {
                                                  setState(() {
                                                    loadTimeController.text =
                                                    "${time.hour}:${time.minute}";
                                                  });
                                                }
                                              },
                                              controller: loadTimeController,
                                              decoration: const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: "Load Time"),
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DropdownSearch(
                                            selectedItem: fromWarehouseController.text,
                                            enabled: !fetchedProjectData.isEmpty,
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
                                                labelText: "From Warehouse",
                                              ),
                                            ),
                                            items: fetchedWarehouseValue.map((warehouse) => warehouse['Description']).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                fromWarehouseController.text = fetchedWarehouseValue.firstWhere((warehouse) => warehouse['Description'] == value)['WarehouseCode'];
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownSearch(
                                              selectedItem: toWarehouseController.text,
                                              enabled:  !fetchedProjectData.isEmpty,
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
                                                  labelText: "To Warehouse",
                                                ),
                                              ),
                                              items: fetchedWarehouseValue.map((warehouse) => warehouse['Description']).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  toWarehouseController.text = fetchedWarehouseValue.firstWhere((warehouse) => warehouse['Description'] == value)['WarehouseCode'];
                                                  toWarehouseNameController.text = value.toString();
                                                });
                                                getBinsFromWarehouse(toWarehouseController.text);
                                              },
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownSearch(
                                      selectedItem: toBinController.text,
                                      enabled: fromWarehouseController.text.isNotEmpty&&toWarehouseController.text.isNotEmpty,
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
                                          labelText: "To Bin",
                                        ),
                                      ),
                                      items: fetchedBinValue.map((bin) => bin['Description']).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          toBinController.text = fetchedBinValue.firstWhere((bin) => bin['Description'] == value)['BinNum'];
                                          toBinNameController.text = value.toString();
                                        });
                                      },
                                    ),
                                  ),
                                  if(loadConditionValue == 'External')
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                controller: poNumberController,
                                                decoration: const InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    labelText: "PO Num"),
                                              ),
                                            )
                                        ),
                                        Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                controller: poLineController,
                                                decoration: const InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    labelText: "PO Line"),
                                              ),
                                            )
                                        ),
                                      ],
                                    ),
                                  Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Load Type',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                                RadioListTile(
                                                  title: const Text('Return Trip'),
                                                  value: 'Delivery',
                                                  groupValue: loadTypeValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      loadTypeValue =
                                                          value.toString();
                                                    });
                                                  },
                                                ),
                                                RadioListTile(
                                                  title: const Text('Delivery Trip'),
                                                  value: 'Return',
                                                  groupValue: loadTypeValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      loadTypeValue =
                                                          value.toString();
                                                    });
                                                  },
                                                ),
                                              ]
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Load Condition',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                                RadioListTile(
                                                  title: const Text('External'),
                                                  value: 'External',
                                                  groupValue: loadConditionValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      loadConditionValue =
                                                          value.toString();
                                                    });
                                                  },
                                                ),
                                                RadioListTile(
                                                  title: const Text('Internal'),
                                                  value: 'Internal',
                                                  groupValue: loadConditionValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      loadConditionValue =
                                                          value.toString();
                                                    });
                                                  },
                                                ),
                                                RadioListTile(
                                                  title: const Text('Ex-Factory'),
                                                  value: 'Ex-Factory',
                                                  groupValue: loadConditionValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      loadConditionValue =
                                                          value.toString();
                                                    });
                                                  },
                                                )
                                              ]
                                          ),
                                        ),
                                      ]
                                  ),
                                  const Padding(padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Truck Details',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blue),
                                    ),
                                  ),
                                  if(!widget.isUpdate)
                                    buildTruckDetailsFrom(true),
                                  if(widget.isUpdate)
                                    TruckDetailsForm(isEdit: true, truckDetails: offloadData,),
                                  const SizedBox(height: 20),
                                  if(widget.isUpdate)
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _tabController.animateTo(1);
                                        });
                                      },
                                      child: const Text('Next'),
                                    ),
                                  if(!widget.isUpdate)
                                    ElevatedButton(
                                        onPressed: () async {
                                          if (truckIdController.text.isEmpty || resourceIdController.text.isEmpty || projectIdController.text.isEmpty) {
                                            showDialog(context: context, builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Error'),
                                                content: const Text(
                                                    'Please fill all the required fields'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            }
                                            );
                                          } else {
                                            final newLoadId = 'I-${lastLoad + 1}';
                                            final loadDateFormat = '${_selectedDate}T00:00:00';
                                            await createNewLoad({
                                              "Key1": newLoadId,
                                              "Company": "EPIC06",
                                              "ShortChar07": plateNumberController.text,
                                              "ShortChar05": projectIdController.text,
                                              "ShortChar01": loadTypeValue,
                                              "ShortChar04": loadConditionValue,
                                              "ShortChar08": truckIdController.text,
                                              "ShortChar03": "Open",
                                              "Number01": loadedController.text.isNotEmpty ? loadedController.text : '0',
                                              "Number02": "0",
                                              "Number06": capacityController.text.isNotEmpty ? capacityController.text : '0',
                                              "Number07": volumeController.text.isNotEmpty ? volumeController.text : '0',
                                              "Number08": heightController.text.isNotEmpty ? heightController.text : '0',
                                              "Number09": widthController.text.isNotEmpty ? widthController.text : '0',
                                              "Number10": lengthController.text.isNotEmpty ? lengthController.text : '0',
                                              "Date01": loadDateFormat,
                                              "Character02": driverNameController.text,
                                              "Character03": driverNumberController.text,
                                              "Character04": toWarehouseNameController.text,
                                              "Character05": toBinNameController.text,
                                              "Character07": toWarehouseController.text,
                                              "Character08": toBinController.text,
                                              "Character06": fromWarehouseController.text,
                                              "Character09": resourceId,
                                            });
                                            if(isLoaded){
                                              if(mounted) {
                                                showDialog(context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text('Success'),
                                                        content: Text(
                                                            'Stock Loading details saved successfully, LoadID: $newLoadId'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                              _tabController.animateTo(1);
                                                            },
                                                            child: const Text('OK'),
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                );
                                              }
                                              setState(() {
                                                loadIDController.text = newLoadId;
                                              });
                                            }
                                          }
                                        },
                                        child: const Text(
                                          'Create Load',

                                        )),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        //Tab 2 Content
                        if(isLoaded)
                          SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Part Search Form',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.blue),
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElementSearchForm(onElementsSelected: updateElementInformation, isOffloading: false, Warehouse:fromWarehouseController.text  ),
                                        ),
                                      ),
                                      const SizedBox(height: 20,),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                    'Selected Elements',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue),
                                  ),
                                  ElementTable(selectedElements: selectedElements),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                    'Selected Parts',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue),
                                  ),
                                  PartTable(selectedParts: selectedParts),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _tabController.animateTo(2);
                                      });
                                    },
                                    child: const Text('Next'),
                                  )
                                ]),
                          ),
                        if(!isLoaded)
                          const Center(
                            child: Text('Please create a load first or Select a load to update'),
                          ),
                        //Tab 3 Content
                        SingleChildScrollView(
                          controller: ScrollController(),
                          child: Center(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Project Details', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blue),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    enabled: false,
                                    initialValue: loadIDController.text,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Load ID"),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    enabled: false,
                                    initialValue: projectIdController.text,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Project ID"),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          enabled: false,
                                          initialValue: dateController.text,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: "Load Date"),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            enabled: false,
                                            initialValue: loadTimeController.text,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "Load Time"),
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            enabled: false,
                                            initialValue: fromWarehouseController.text,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "From"),
                                          ),
                                        )
                                    ),
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            enabled: false,
                                            initialValue: toWarehouseController.text,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "To"),
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Truck Details', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blue),),
                                ),
                                if(!widget.isUpdate)
                                  buildTruckDetailsFrom(false),
                                if(widget.isUpdate)
                                  TruckDetailsForm(isEdit: true, truckDetails: offloadData,),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Selected Elements', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blue),),
                                ),
                                ElementTable(selectedElements: selectedElements),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Selected Parts', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blue),),
                                ),
                                PartTable(selectedParts: selectedParts),
                                const SizedBox(height: 20,),
                                ElevatedButton(
                                    onPressed: () async {
                                      debugPrint(selectedElements.length.toString());
                                      for(var e = 0; e < selectedElements.length; e++){
                                        debugPrint(selectedElements[e].toString());
                                        try {
                                          await updateUD103A({
                                            "Company": "EPIC06",
                                            "Key1": loadIDController.text,
                                            "Character01": selectedElements[e].partId,
                                            "Character02": selectedElements[e].elementId,
                                            "Character03": fromWarehouseController.text,
                                            "Character07": toWarehouseController.text,
                                            "Character08": toBinController.text,
                                            "Number01": selectedElements[e].selectedQty,
                                            "Number03": selectedElements[e].weight,
                                            "Number04": selectedElements[e].area,
                                            "Number05": selectedElements[e].volume,
                                            "Number06": selectedElements[e].erectionSeq,
                                            "ShortChar07": selectedElements[e].UOM,
                                            "CheckBox05":false,
                                            "CheckBox01":true,
                                            "CheckBox02":false,
                                            "CheckBox03":false,
                                            "CheckBox13": false,

                                          });
                                        } on Exception catch (e) {
                                          debugPrint(e.toString());
                                        }
                                      }
                                      for (var p = 0; p < selectedParts.length; p++){
                                        debugPrint(selectedParts[p].toString());
                                        // await updateUD103A({
                                        //   "Company": "EPIC06",
                                        //   "Key1": loadIDController.text,
                                        //   "Character01": selectedParts[p].partNum,
                                        //   "Character02": selectedParts[p].partDesc,
                                        //   "Character03": toWarehouseController.text,
                                        //   "Character04": toBinController.text,
                                        //   "Number01": selectedParts[p].qty,
                                        //   "ShortChar07": selectedParts[p].uom,
                                        //   "CheckBox13": true,
                                        // });
                                      }
                                      if (mounted) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Success'),
                                                content: Text(
                                                    'Stock Loading details saved successfully, LoadID: $loadIDController'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              );
                                            });
                                      }
                                    },
                                    child: const Text(
                                      'Save Load',

                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                );}
              ),
                              ),

                           /* Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      enabled: !widget.isUpdate,
                                      controller: dateController,
                                      onTap: () async {
                                        final DateTime? date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2018),
                                          lastDate: DateTime(2030),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            dateController.text =
                                            "${date.day}/${date.month}/${date
                                                .year}";
                                            _selectedDate = DateFormat('yyyy-MM-dd').format(date);
                                          });
                                        }
                                      },
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Load Date"),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        enabled: !widget.isUpdate,
                                        onTap: () async {
                                          final TimeOfDay? time = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );
                                          if (time != null) {
                                            setState(() {
                                              loadTimeController.text =
                                              "${time.hour}:${time.minute}";
                                            });
                                          }
                                        },
                                        controller: loadTimeController,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Load Time"),
                                      ),
                                    )
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: DropdownSearch(
                                        selectedItem: fromWarehouseController.text,
                                        enabled: !widget.isUpdate,
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
                                            labelText: "From Warehouse",
                                          ),
                                        ),
                                        items: fetchedWarehouseValue.map((warehouse) => warehouse['Description']).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            fromWarehouseController.text = fetchedWarehouseValue.firstWhere((warehouse) => warehouse['Description'] == value)['WarehouseCode'];
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: DropdownSearch(
                                        selectedItem: toWarehouseController.text,
                                        enabled: !widget.isUpdate,
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
                                            labelText: "To Warehouse",
                                          ),
                                        ),
                                        items: fetchedWarehouseValue.map((warehouse) => warehouse['Description']).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            toWarehouseController.text = fetchedWarehouseValue.firstWhere((warehouse) => warehouse['Description'] == value)['WarehouseCode'];
                                          });
                                          getBinsFromWarehouse(toWarehouseController.text);
                                        },
                                      ),
                                      )
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownSearch(
                                selectedItem: toBinController.text,
                                enabled: !widget.isUpdate,
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
                                    labelText: "To Bin",
                                  ),
                                ),
                                items: fetchedBinValue.map((bin) => bin['Description']).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    toBinController.text = fetchedBinValue.firstWhere((bin) => bin['Description'] == value)['BinNum'];
                                  });
                                },
                              ),
                            ),*/
    );



  }
  Future<void> MakeSureDataLoaded() async {
    await getProjectList();
    await getWarehouseList();
    await getTrucksFromURL();
    await getDriverList();
    await getLastLoadID();
  }
  Future<void> getProjectList() async {
    final String basicAuth = 'Basic ${base64Encode(
        utf8.encode('manager:manager'))}';
    try {
      final response = await http.get(
          Uri.parse(
              'https://77.92.189.102/iit_vertical_precast/api/v1/Erp.Bo.ProjectSvc/List/'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      if (response.statusCode == 200) {
        setState(() {
          fetchedProjectData = json.decode(response.body);
          fetchedProjectValue = fetchedProjectData['value'];
        });
      } else {
        throw Exception('Failed to load album');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getWarehouseList() async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:manager'))}';
    try {
      final response = await http.get(
          Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/Erp.Bo.WarehseSvc/Warehses'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      if (response.statusCode == 200) {
        setState(() {
          fetchedWarehouseData = json.decode(response.body);
          fetchedWarehouseValue = fetchedWarehouseData['value'];
        });
      } else {
        throw Exception('Failed to load album');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getBinsFromWarehouse (String warehouseCode) async {
    final String basicAuth = 'Basic ${base64Encode(
        utf8.encode('manager:manager'))}';
    try {
      final response = await http.get(
          Uri.parse("https://77.92.189.102/iit_vertical_precast/api/v1/Erp.BO.WhseBinSvc/WhseBins?\$filter=WarehouseCode eq '$warehouseCode'"),
          headers: {
      HttpHeaders.authorizationHeader: basicAuth,
      HttpHeaders.contentTypeHeader: 'application/json',
      });
      if (response.statusCode == 200) {
        setState(() {
          fetchedBinData = json.decode(response.body);
          fetchedBinValue = fetchedBinData['value'];
        });
      }
    }
    on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void updateElementInformation(List<ElementData> selectedElementsFromForm, List<PartData> selectedPartsFromForm){
    setState(() {
      selectedElements = selectedElementsFromForm;
      selectedParts = selectedPartsFromForm;
    });
  }

  Future<void> createNewLoad(Map<String, dynamic> loadItems) async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:manager'))}';
    try{
      final response = await http.post(
          Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/Ice.BO.UD103Svc/UD103s'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(loadItems)
      );
      debugPrint(response.body);
      if (response.statusCode == 201) {
        debugPrint(response.body);
        setState(() {
          isLoaded = true;





































































        });
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

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
    var urL = Uri.parse("https://77.92.189.102/iit_vertical_precast/api/v1/Ice.BO.UD102Svc/UD102As?\$filter=Key1 eq '$resourceID'");
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
        resourceDetails = ResourceDetails.fromJson(resourceValue!.first);
      });
    }
    on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getDriverList() async {
    try{
      final response = await http.get(
          Uri.parse('https://77.92.189.102/IITPrecastVertical/api/v1/BaqSvc/IIT_DriverName'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if (response.statusCode == 200) {
        setState(() {
          fetchedDriverData = json.decode(response.body);
          fetchedDriverValue = fetchedDriverData['value'];
        });
      } else {
        throw Exception('Failed to get Drivers');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getLastLoadID() async {
    try{
      final response = await http.get(
          Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/BaqSvc/IIT_UD103AutoGenerateNum_Test'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if(response.statusCode == 200){
        Map<String, dynamic> rp = json.decode(response.body);
        setState(() {
          lastLoad = rp['value'][0]['Calculated_AutoGen'];
        });
        debugPrint(lastLoad.toString());
      }
    }
    on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchPartDataFromURL() async {
    try {
      final response = await http.get(
          detailsURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      final jsonResponse = json.decode(response.body);
      setState(() {
        partData = jsonResponse;
        partValue = partData['value'].where((part) => part['CheckBox13'] == true).toList();
      });
      return jsonResponse;
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchElementDataFromURL() async {
    try {
      final response = await http.get(
          detailsURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      final jsonResponse = json.decode(response.body);
      setState(() {
        elementData = jsonResponse;
        elementValue = elementData['value'].where((element) => element['CheckBox13'] == false).toList();
      });
      debugPrint(elementValue.toString());
      return jsonResponse;
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
  
  Future<void> fetchLoadDataFromURL() async {
    try {
      final response = await http.get(
          loadURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      final jsonResponse = json.decode(response.body);
      setState(() {
        loadData = jsonResponse;
        loadValue = loadData['value'];
      });
      return jsonResponse;
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  LoadData? getLoadObjectFromJson(String loadID) {
    if (loadValue.isNotEmpty){
      LoadData loadObject = LoadData.fromJson(loadValue.where((element) => element['Key1'] == loadID).first);
      return loadObject;
    }
    return null;
  }

  ElementData? getElementObjectFromJson(String loadID) {
    if (elementValue.isNotEmpty){
      var matchingElement = elementValue.where((element) => element['Key1'] == loadID).toList();
      ElementData? elementObject;
      if (matchingElement.isNotEmpty){
        for (var v = 0; v<matchingElement.length; v++) {
          elementObject = ElementData.fromJson(matchingElement[v]);
          debugPrint(elementObject.elementId);
          selectedElements.add(elementObject);
        }
      }
    }
    return null;
  }

  PartData? getPartObjectFromJson(String loadID) {
    if (partValue.isNotEmpty){
      var matchingPart = partValue.where((part) => part['Key1'] == loadID).toList();
      if (matchingPart.isNotEmpty){
        for (var v = 0; v<matchingPart.length; v++) {
          PartData partObject = PartData.fromJson(matchingPart[v]);
          selectedParts.add(partObject);
        }
      }
    }
    return null;
  }

  Future<void> updateUD103A(Map<String, dynamic> ud103AData) async {
    try {
      final response = await http.post(
          Uri.parse('https://77.92.189.102/iit_vertical_precast/api/v1/Ice.BO.UD103Svc/UD103As'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(ud103AData)
      );
      if (response.statusCode == 201) {
        debugPrint(response.body);
      }
      else {
        debugPrint(response.body);
        debugPrint(response.statusCode.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget buildTruckDetailsFrom(bool isEditable) {
    return Column(
      children: [
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if(!isEditable)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: _truckKey,
                controller: truckIdController,
                enabled: isEditable,
                decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                    labelText: "Truck ID"),
              ),
            ),
          ),
        if(isEditable)
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
                },
              ),
            ),
          ),
        if(!isEditable)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                enabled: isEditable,
                controller: resourceIdController,
                decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                    labelText: "Resource"),
              ),
            ),
          ),
        if(isEditable)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                    resourceId = resourceValue!.where((element) => element['Character01'] == value).first['Key1'];
                  });
                  getResourceDetailsFromJson(resourceIdController.text);
                  if(resourceDetails != null){
                    setState(() {
                      capacityController.text = resourceDetails!.capacity;
                      lengthController.text = resourceDetails!.length;
                      widthController.text = resourceDetails!.width;
                      heightController.text = resourceDetails!.height;
                      volumeController.text = resourceDetails!.volume;
                      loadedController.text = resourceDetails!.loaded;
                    });
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
            enabled: isEditable,
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
            if(!isEditable)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    enabled: isEditable,
                    controller: driverNameController,
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                        labelText: "Driver Name"),
                  ),
                ),
              ),
            if(isEditable)
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
                  enabled: isEditable,
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
                      enabled: isEditable,
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
                      controller: loadedController,
                      enabled: isEditable,
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
                      enabled: isEditable,
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
                      enabled: isEditable,
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
                        enabled: isEditable,
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
                      enabled: isEditable,
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
                if(!isEditable)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: isEditable,
                        controller: foremanId,
                        decoration: const InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(),
                            labelText: "Foreman ID"),
                      ),
                    ),
                  ),
                if(isEditable)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField(
                        hint: const Text('Foreman ID'),
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
                      enabled: isEditable,
                      decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                          labelText: "Foreman Name"),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                enabled: isEditable,
                decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                    labelText: "Comments"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


