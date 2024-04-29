import 'dart:async';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:IIT_precast_app/elementTable.dart';
import 'package:IIT_precast_app/partTable.dart';
import 'package:IIT_precast_app/elementSearchForm.dart';
import 'package:IIT_precast_app/stockOffloadingPage.dart';
import 'package:IIT_precast_app/truckDetails.dart';
import 'package:IIT_precast_app/truck_resource_model.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'load_model.dart';
import 'part_model.dart';
import 'element_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'Providers/UserManagement.dart';
import 'Models/UserManagement.dart';
import 'package:provider/provider.dart';


class StockLoading extends StatefulWidget {
  final int initialTabIndex;
  final bool isUpdate;
   List <LoadData> loadDataList;
   dynamic addLoadData;
   String historyLoadID;
   dynamic userManagement;
   StockLoading({super.key, required this.initialTabIndex, required this.isUpdate, required this.loadDataList,required this.addLoadData , this.historyLoadID='',this.userManagement}) ;

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
  String loadTypeValue = 'Issue Load';
  String loadConditionValue = 'Internal Truck';
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
  TextEditingController? entryPersonController = TextEditingController();
  TextEditingController? deviceIDController = TextEditingController();
  List<ElementData> selectedElements = [];
  List<PartData> selectedParts = [];
  String resourceId = '';
  LoadData? currentLoad;
  int childCount = 1;

  Map<String, dynamic> fetchedProjectData = {};
  List<dynamic> fetchedProjectValue = [];
  bool back = false;
  Map<String, dynamic> fetchedWarehouseData = {};
  List<dynamic> fetchedWarehouseValue = [];

  Map<String, dynamic> fetchedBinData = {};
  List<dynamic> fetchedBinValue = [];
  List<dynamic> subfetchedBinValue = [];



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
  bool canGetBack = false;
  Map<String, dynamic> partData = {};
  List<dynamic> partValue = [];

  Map<String, dynamic> foremanData = {};
  List<dynamic> foremanValue = [];

  LoadData? offloadData;
  final loadURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD103Svc/UD103s');
  final detailsURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD103Svc/UD103As');

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

  bool isLoaded = false;
  List<dynamic> deletedSavedElements=[];

  late int lastLoad = 50;
  late final int l1;
  late final int l2;
  late final String nextLoad;

  final basicAuth = 'Basic ${base64Encode(utf8.encode('manager:Adp@2023'))}';
  late final Future dataLoaded;
  bool isPrinting = false ;
  int pdfCount =0;
  @override
  void initState()  {
    fromWarehouseController.text='Default';
    toWarehouseController.text='Site';
    toWarehouseNameController.text='Site';
    _tabController = TabController(length: 3, vsync: this); // Change 3 to the number of tabs
    _tabController.index = widget.initialTabIndex;
    if(!widget.isUpdate) {
      dataLoaded=makeSureDataLoaded();
      getDeviceID();
      entryPersonController?.text=context.read<UserManagementProvider>().userManagement!.firstName!;
    }else if(widget.isUpdate&&widget.historyLoadID!=''){
      setState(() {
        loadIDController.text = widget.historyLoadID;
      });

      dataLoaded=fetchLoadDataFromURL(widget.historyLoadID).then((value) => {

           offloadData = getLoadObjectFromJson(widget.historyLoadID),
           getElementObjectFromJson(widget.historyLoadID),
           getPartObjectFromJson(widget.historyLoadID),
           setState(() {
             projectIdController.text = offloadData!.projectId;
             dateController.text = offloadData!.loadDate;
             toWarehouseController.text = offloadData!.toWarehouse;
             toBinController.text = offloadData!.toBin;
             loadTypeValue = offloadData!.loadType;
             loadConditionValue = offloadData!.loadCondition;
             fromWarehouseController.text = offloadData!.fromWarehouse;
             isLoaded = true;
           }),


    });


    }
    else{
      dataLoaded = Future.value(true);
      setState(() {
        isLoaded = true;
      });
    };
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
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
           if(_tabController.index > 0) {
             _tabController.animateTo(_tabController.index - 1);
           }


          else{

             showAlertDialog(BuildContext context) {
               // Init
               AlertDialog dialog = AlertDialog(
                 title: const Text("Are you sure you want to exit?"),
                 actions: [
                   ElevatedButton(
                       child: const Text("Yes"),
                       onPressed: () {
                         Navigator.pop(context);
                         Navigator.pop(context);
                       }
                   ),
                    ElevatedButton(
                        child: const Text("No"),
                        onPressed: () {
                          Navigator.pop(context);
                        }
                    ),
                 ],
               );

               // Show the dialog
               showDialog(
                   context: context,
                   builder: (BuildContext context) {
                     return dialog;
                   }
               );
             }
             showAlertDialog(context);
          }}

        },

      child: DefaultTabController(
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  StockLoading(initialTabIndex: 0, isUpdate: false,loadDataList:widget.loadDataList,addLoadData: widget.addLoadData,)));
                          },
                        ),
                      ),
                    if(!widget.isUpdate)
                      PopupMenuItem(
                        child: ListTile(
                          title: const Text('Edit a Load'),
                          leading: const Icon(Icons.edit_calendar),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => StockLoading(initialTabIndex: 0, isUpdate: true,loadDataList:widget.addLoadData,addLoadData: widget.addLoadData,)));
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
            body:      isPrinting?
              const Center(
                child: CircularProgressIndicator(),
             ) : FutureBuilder(
                future: dataLoaded,
                  builder:(context,snapshot){
                   if(snapshot.connectionState == ConnectionState.waiting){
                        return  const Stack(
                          children: [
                            Center(
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
                                                  await fetchLoadDataFromURL(loadIDController.text);
                                                 // await fetchElementDataFromURL();
                                                  //await fetchPartDataFromURL();
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
                                                items: fetchedProjectValue.map((project) => project['Project_ProjectID']).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    projectIdController.text = fetchedProjectValue.firstWhere((project) => project['Project_ProjectID'] == value)['Project_ProjectID'];
                                                  });
                                                },
                                              );
                                            },
                                          )
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
                                                enabled: true,
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
                                                items: fetchedWarehouseValue.where((warehouse) => warehouse['FinishGoods_c'] == true).map((warehouse) => warehouse['Description']).toList(),
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
                                                  enabled:  false,
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
                                                      subfetchedBinValue = fetchedBinValue.where((bin) => bin['WarehouseCode'] == toWarehouseController.text).toList();
                                                    });

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
                                          items: subfetchedBinValue.map((bin) => bin['Description']).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              toBinController.text = subfetchedBinValue.firstWhere((bin) => bin['Description'] == value)['BinNum'];
                                              toBinNameController.text = value.toString();
                                            });
                                            debugPrint(toBinController.text);
                                            debugPrint(toBinNameController.text);
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
                                                      title: Text('Return Trip', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)),
                                                      value: 'Return',
                                                      groupValue: loadTypeValue,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          loadTypeValue =
                                                              value.toString();
                                                        });
                                                      },
                                                    ),
                                                    RadioListTile(
                                                      title: Text('Delivery Trip', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)),
                                                      value: 'Issue Load',
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
                                                      title: Text('External', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)),
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
                                                      title: Text('Internal', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)),
                                                      value: 'Internal Truck',
                                                      groupValue: loadConditionValue,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          loadConditionValue =
                                                              value.toString();
                                                        });
                                                      },
                                                    ),
                                                    RadioListTile(
                                                      title: Text('Ex-Factory', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022,)),
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
                                                final newLoadId = 'I-${lastLoad!=50?lastLoad + 1:50}';
                                                final loadDateFormat = '${_selectedDate}T00:00:00';
                                                await createNewLoad({
                                                  "Key1": newLoadId,
                                                  "Company": "158095",
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
                                                  "Character05": toBinController.text,
                                                  "Character07": toWarehouseController.text,
                                                  // "Character08": ,
                                                  "Character06": fromWarehouseController.text,
                                                  "Character09": resourceId,
                                                  "Createdby_c": entryPersonController?.text.toString().trim(),
                                                  "Deviceid_c":  deviceIDController?.text.toString().trim(),
                                                });
                                                debugPrint(toWarehouseNameController.text);
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
                                              child: ElementSearchForm(onElementsSelected: updateElementInformation,arrivedElements:selectedElements.isNotEmpty?selectedElements:[],isOffloading: false, Warehouse:fromWarehouseController.text!=''?fromWarehouseController.text:null , AddElement:_AddElement,Project:projectIdController.text),
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
                                      ElementTable(selectedElements: selectedElements ?? [],DeletededSaveElements: widget.isUpdate?deletedSavedElements:null,),
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
                                                "Company": "158095",
                                                "ChildKey1": selectedElements[e].ChildKey1,
                                                "Key1": loadIDController.text,
                                                "Character01": selectedElements[e].partId,
                                                "Character02": selectedElements[e].elementId,
                                                "Character03": fromWarehouseController.text,
                                                "Character07": toWarehouseController.text,
                                                "Character08": toBinController.text,
                                                "Number01": selectedElements[e].selectedQty.toString().isNotEmpty? selectedElements[e].selectedQty.toString() : '0',
                                                "Number03": selectedElements[e].weight.toString().isNotEmpty ? selectedElements[e].weight : '0',
                                                "Number04": selectedElements[e].area.toString().isNotEmpty ? selectedElements[e].area : '0',
                                                "Number05": selectedElements[e].volume.toString().isNotEmpty ? selectedElements[e].volume : '0',
                                                "Number06": selectedElements[e].erectionSeq.toString().isNotEmpty  ? selectedElements[e].erectionSeq : '0',
                                                "ShortChar07": selectedElements[e].UOM,
                                                "CheckBox05":false,
                                                "CheckBox01":true,
                                                "CheckBox02":false,
                                                "CheckBox03":false,
                                                "CheckBox13": false,
                                              });
                                              updateInTransit(selectedElements[e].partId, selectedElements[e].elementId);
                                              childCount++;
                                            } on Exception catch (e) {
                                              debugPrint(e.toString());
                                            }
                                          }
                                          for(int i=0;i<deletedSavedElements.length;i++){
                                            try{
                                              await deleteUD103A(deletedSavedElements[i]);
                                            }catch(e){
                                              debugPrint(e.toString());
                                            }

                                          }
                                          for (var p = 0; p < selectedParts.length; p++){
                                            debugPrint(selectedParts[p].toString());
                                             await updateUD103A({
                                               "Company": "158095",
                                               "Key1": loadIDController.text,
        /*                                           "ChildKey1": "${++ChildCount}",*/
                                               "Character01": selectedParts[p].partNum,
                                               "Character02": selectedParts[p].partDesc,
                                               "Character03": toWarehouseController.text,
                                               "Character04": toBinController.text,
                                               "Number01": selectedParts[p].qty,
                                               "ShortChar07": selectedParts[p].uom,
                                               "CheckBox13": true,
                                            });
                                          }
                                          if (mounted) {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('Success'),
                                                    content: Text(
                                                        'Stock Loading details saved successfully, LoadID: ${loadIDController.text}'),
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
      ),
    );
  }

  Future<void> makeSureDataLoaded() async {
    if(!widget.isUpdate) {
      await Future.wait([
        getProjectList(),
        getBinsFromWarehouse(),
        getTrucksFromURL(),
        getDriverList(),
        getLastLoadID(),
        getWarehouseList()
      ]);
    }


  }
  void _AddElement(ElementData element){
    setState(() {
      selectedElements.add(element);
    });
  }
  Future<bool> submitReport() async {
    dynamic body={

    "ds": {
    "extensionTables": [],
    "BAQReportParam": [
    {

    "Summary": false,
    "BAQRptID": "",
    "ReportID": "IIT_DeliveryNot",
    "Option01": loadIDController.text,
    "SysRowID": "00000000-0000-0000-0000-000000000000",
    "AutoAction": "SSRSGenerate",
    "PrinterName": "Microsoft Print to PDF",
    "AgentSchedNum": 0,
    "AgentID": "",
    "AgentTaskNum": 0,
    "RecurringTask": false,
    "RptPageSettings": "Color=True,Landscape=False,AutoRotate=False,PaperSize=[Kind=\"Custom\" PaperName=\"Custom\" Height=0 Width=0],PaperSource=[SourceName=\"Automatically Select\" Kind=\"Custom\"],PrinterResolution=[]",
    "RptPrinterSettings": "PrinterName=\"Microsoft Print to PDF\",Copies=1,Collate=False,Duplex=Default,FromPage=1,ToPage=0",
    "RptVersion": "",
    "ReportStyleNum": 1002,
    "WorkstationID": "web_Manager",
    "AttachmentType": "PDF",
    "ReportCurrencyCode": "USD",
    "ReportCultureCode": "en-US",
    "SSRSRenderFormat": "PDF",
    "UIXml": "",
    "PrintReportParameters": false,
    "SSRSEnableRouting": false,
    "DesignMode": false,
    "RowMod": "A"
    }
    ],
    "ReportStyle": [

    {
    "Company": "158095",
    "ReportID": "IIT_DeliveryNot",
    "StyleNum": 1002,
    "StyleDescription": "Delivery Note Report - SSRS",
    "RptTypeID": "SSRS",
    "PrintProgram": "Reports/CustomReports/IIT_DeliveryNot/IIT_Delivery_v2",
    "PrintProgramOptions": "",
    "RptDefID": "IIT_DeliveryNot",
    "CompanyList": "158095",
    "ServerNum": 0,
    "OutputLocation": "Database",
    "OutputEDI": "",
    "SystemFlag": false,
    "CGCCode": "",
    "SysRevID": 93280823,
    "SysRowID": "724b1ca9-4a67-4db8-840a-24b73be01b80",
    "RptCriteriaSetID": null,
    "RptStructuredOutputDefID": null,
    "StructuredOutputEnabled": false,
    "RequireSubmissionID": false,
    "AllowResetAfterSubmit": false,
    "CertificateID": null,
    "LangNameID": "",
    "FormatCulture": "",
    "StructuredOutputCertificateID": null,
    "StructuredOutputAlgorithm": null,
    "HasBAQOrEI": false,
    "RoutingRuleEnabled": false,
    "CertificateIsAllComp": false,
    "CertificateIsSystem": false,
    "CertExpiration": null,
    "Status": 0,
    "StatusMessage": "",
    "RptDefSystemFlag": false,
    "LangNameIDDescription": "",
    "IsBAQReport": false,
    "StructuredOutputCertificateIsAllComp": false,
    "StructuredOutputCertificateIsSystem": false,
    "StructuredOutputCertificateExpirationDate": null,
    "AllowGenerateEDI": false,
    "BitFlag": 0,
    "ReportRptDescription": "",
    "RptDefRptDescription": "",
    "RptTypeRptTypeDescription": "",
    "RowMod": "",
    "SSRSRenderFormat": "PDF"
    }

    ]
    },
    "agentID": "",
    "agentSchedNum": 0,
    "agentTaskNum": 0,
    "maintProgram": "Ice.UIRpt.IIT_DeliveryNot"
    };
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:Adp@2023'))}';
    try {
      final SumbitReportURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.RPT.BAQReportSvc/TransformAndSubmit');
      final response = await http.post(
          SumbitReportURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(body)
      );
      if(response.statusCode == 200){
        return true;
      }
      else {
        return false;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<dynamic> fetchPDFCounts() async {
    final String basicAuth = 'Basic ${base64Encode(
        utf8.encode('manager:Adp@2023'))}';
    try {
      final PDFCountsURL = Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_getDN(158095)');
      final response = await http.get(
          PDFCountsURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse['value'];
      }
      else {
        return null;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> getProjectList() async {
    final String basicAuth = 'Basic ${base64Encode(
        utf8.encode('manager:Adp@2023'))}';
    try {
      final response = await http.get(
          Uri.parse(
              'https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_projectList'),
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
        throw Exception('Failed to load Project');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<Uint8List> DeliveryNote(String base64String) async {
    Uint8List decodedBytes = base64.decode(base64String);
    final pdf = pw.Document();
    final directory = await getApplicationDocumentsDirectory();
    final output = File('${directory.path}/DeliveryNote${loadIDController.text}.pdf');

    await pdf.save();
    await output.writeAsBytes(decodedBytes, flush: true);

    return output.readAsBytesSync();
  }
  Future<void> getWarehouseList() async {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:Adp@2023'))}';
    try {
      final response = await http.get(
          Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Erp.Bo.WarehseSvc/Warehses'),
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

  Future<void> getBinsFromWarehouse () async {
    final String basicAuth = 'Basic ${base64Encode(
        utf8.encode('manager:Adp@2023'))}';
    try {
      final response = await http.get(
          Uri.parse("https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Erp.BO.WhseBinSvc/WhseBins"),
          headers: {
      HttpHeaders.authorizationHeader: basicAuth,
      HttpHeaders.contentTypeHeader: 'application/json',
      });
      if (response.statusCode == 200) {
        setState(() {
          fetchedBinData = json.decode(response.body);
          fetchedBinValue = fetchedBinData['value'];
          subfetchedBinValue = fetchedBinValue.where((bin) => bin['WarehouseCode'] == toWarehouseController.text).toList();

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
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('manager:Adp@2023'))}';
    try{
      final response = await http.post(
          Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD103Svc/UD103s'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(loadItems)
      );
      if (response.statusCode == 201) {
        debugPrint(response.body);
        LoadData load = LoadData.fromJson(json.decode(response.body));
        setState(() {
          isLoaded = true;
          currentLoad = load;
          widget.addLoadData(load);
        });
        debugPrint(widget.loadDataList.toString());
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
          Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_DriverName(158095)'),
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
          Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/BaqSvc/IIT_UD103AutoGenerateNum_Test(158095)'),
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

  Future<dynamic> fetchLoadDataFromURL(String loadId) async {
    try {
      Map<String, dynamic> body = {
        "key1": loadId,
        "key2": "",
        "key3": "",
        "key4": "",
        "key5": ""
      };
      final url = Uri.parse(
          "https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD103Svc/GetByID");
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: basicAuth,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode(body),
      );

      final jsonResponse = json.decode(response.body);

      setState(() {
        loadData = jsonResponse['returnObj'];
        loadValue = loadData['UD103'];
        currentLoad = LoadData.fromJson(loadValue[0]);

        elementValue = loadData['UD103A']
            .where((element) => element['CheckBox13'] == false)
            .toList();
        partValue = loadData['UD103A']
            .where((part) => part['CheckBox13'] == true)
            .toList();
      });
      return jsonResponse;
    } catch (e) {
      debugPrint(e.toString());
      // You may want to handle errors here or return some indication of failure
      // For now, I'll return null to indicate failure
      return null;
    }
  }

  LoadData? getLoadObjectFromJson(String loadID) {
    if (loadValue.isNotEmpty){

    LoadData loadObject = LoadData.fromJson(loadValue[0]);
      return loadObject;
    }
    return null;
  }

  ElementData? getElementObjectFromJson(String loadID) {
    if (elementValue.isNotEmpty){
      var matchingElement = elementValue.where((element) => element['Key1'] == loadID).toList();
      ElementData? elementObject;
      setState(() {
        selectedElements.clear();
      });
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
  Future<void> deleteUD103A(String childKey1) async {
    try {
      final response = await http.delete(
          Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD103Svc/UD103As(158095,${loadIDController.text},,,,,${childKey1},,,,)'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          }
      );
      if (response.statusCode == 200) {
        widget.addLoadData(currentLoad);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> updateUD103A(Map<String, dynamic> ud103AData) async {
    try {
      final response = await http.post(
          Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Ice.BO.UD103Svc/UD103As'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(ud103AData)
      );
      if (response.statusCode == 201) {
        debugPrint(response.body);
        setState(() {
          widget.addLoadData(currentLoad);
        });
      }
      else {
        debugPrint(response.body);
        debugPrint(response.statusCode.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateInTransit(String partNum, String elementId) async {
   final response = await http.post(
       Uri.parse('https://abudhabiprecast-pilot.epicorsaas.com/server/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates'),
       headers: {
         HttpHeaders.authorizationHeader: basicAuth,
         HttpHeaders.contentTypeHeader: 'application/json',
       },
       body: jsonEncode({
         "Company": "158095",
         "PartNum": partNum,
         "LotNum": elementId,
         "ElementStatus_c": "In-Transit"
       })
   );
    if(response.statusCode == 200){
      debugPrint(response.body);
    }
    else {
      debugPrint(response.body);
      debugPrint(response.statusCode.toString());
    }
  }

  Future<void> getDeviceID () async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {

        final AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
        debugPrint('Running on ${build.model}');
        setState(() {
          deviceIDController?.text = build.model;
        });

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


