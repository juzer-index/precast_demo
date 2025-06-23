import 'dart:async';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'elementTable.dart';
import 'partTable.dart';
import 'elementSearchForm.dart';
import 'stockOffloadingPage.dart';
import 'truckDetails.dart';
import 'truck_resource_model.dart';
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

import 'Providers/UserManagement.dart';
import 'Providers/tenantConfig.dart';
import 'Widgets/DropDown.dart';
import 'package:toggle_switch/toggle_switch.dart';
import './Providers/ArchitectureProvider.dart';
import './Widgets/SalesOrderSearch.dart';
import 'Widgets/ProjectSearch.dart';
import 'utils/APIProviderV2.dart';
import './element_model.dart';
import'./Models/CustomerShipment.dart';
import '../Providers/LoadStateProvider.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:location/location.dart';

class StockLoading extends StatefulWidget {
  final int initialTabIndex;
  final bool isUpdate;
  final List<LoadData> loadDataList;
  final dynamic addLoadData;
  final String historyLoadID;

  const StockLoading(
      {super.key,
      required this.initialTabIndex,
      required this.isUpdate,
      required this.loadDataList,
      required this.addLoadData,
      this.historyLoadID = ''});

  @override
  State<StockLoading> createState() => _StockLoadingState();
}

class _StockLoadingState extends State<StockLoading>
    with SingleTickerProviderStateMixin {
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
  bool toBinLoading = false;
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

  //final detailsURL = Uri.parse('${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/UD104As');

  //var truckURL = Uri.parse('${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Ice.BO.UD102Svc/UD102s');
  //var resourceURL = Uri.parse('${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Ice.BO.UD102Svc/UD102As');

  Map<String, dynamic> truckData = {};
  List<dynamic> truckValue = [];
  Map<String, dynamic> resourceData = {};
  List<dynamic>? resourceValue = [];
  List<dynamic> matchingResources = [];

  Map<String, dynamic> fetchedDriverData = {};
  List<dynamic> fetchedDriverValue = [];

  bool isTruckChanged = false;

  bool isLoaded = false;
  List<dynamic> deletedSavedElements = [];

  late int lastLoad = 50;
  late int lastCustShip = 0;
  late int custNum = 0;
  late final int l1;
  late final int l2;
  late final String nextLoad;

// final basicAuth = 'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
  late final Future dataLoaded;
   String ErrorMessage="";
  bool isPrinting = false;
  int pdfCount = 0;
  @override
  void initState() {
    _tabController =
        TabController(length: 3, vsync: this); // Change 3 to the number of tabs
    _tabController.index = widget.initialTabIndex;

    if (!widget.isUpdate) {
      dataLoaded =
          makeSureDataLoaded(context.read<tenantConfigProvider>().tenantConfig);

      entryPersonController?.text =
          context.read<UserManagementProvider>().userManagement!.firstName!;
    } else if (widget.isUpdate && widget.historyLoadID != '') {
      setState(() {
        loadIDController.text = widget.historyLoadID;
      });

      dataLoaded = fetchLoadDataFromURL(widget.historyLoadID,
              context.read<tenantConfigProvider>().tenantConfig)
          .then((value) => {
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
    } else {
      dataLoaded = Future.value(true);
      setState(() {
        isLoaded = true;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tenantConfigP = context.watch<tenantConfigProvider>().tenantConfig;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (_tabController.index > 0) {
            _tabController.animateTo(_tabController.index - 1);
          } else {
            showAlertDialog(BuildContext context) {
              // Init
              AlertDialog dialog = AlertDialog(
                title: const Text("Are you sure you want to exit?",
                    style: TextStyle(color: Colors.red)),
                content: const Text("All unsaved data will be lost"),
                actions: [
                  TextButton(
                      child: Text("Yes",
                          style:
                              TextStyle(color: Theme.of(context).canvasColor)),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }),
                  TextButton(
                      child: Text("No",
                          style:
                              TextStyle(color: Theme.of(context).canvasColor)),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              );

              // Show the dialog
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return dialog;
                  });
            }

            showAlertDialog(context);
          }
        }
      },
      child: DefaultTabController(
        length: 3,
        initialIndex: widget.initialTabIndex,
        child: Scaffold(
          backgroundColor: Color(0xffF0F0F0),
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(),
                  if (widget.isUpdate)
                    const Text('Edit Load',
                        style: TextStyle(color: Colors.white)),
                  if (!widget.isUpdate)
                    const Text('Stock Loading',
                        style: TextStyle(color: Colors.white)),
                  // ClipOval(
                  //   child: Image.network(
                  //     '${tenantConfigP['httpVerbKey']}://media.licdn.com/dms/image/D4D03AQFpmZgzpRLrhg/profile-displayphoto-shrink_800_800/0/1692612499698?e=1711584000&v=beta&t=Ho-Wta1Gpc-aiWZMJrsni_83CG16TQeq_gtbIJBM7aI',
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
                  if (widget.isUpdate)
                    PopupMenuItem(
                      child: ListTile(
                        title: const Text('Create New Load'),
                        leading: const Icon(Icons.edit_calendar),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StockLoading(
                                        initialTabIndex: 0,
                                        isUpdate: false,
                                        loadDataList: widget.loadDataList,
                                        addLoadData: widget.addLoadData,
                                      )));
                        },
                      ),
                    ),
                  if (!widget.isUpdate)
                    PopupMenuItem(
                      child: ListTile(
                        title: const Text('Edit a Load'),
                        leading: const Icon(Icons.edit_calendar),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StockLoading(
                                        initialTabIndex: 0,
                                        isUpdate: true,
                                        loadDataList: widget.addLoadData,
                                        addLoadData: widget.addLoadData,
                                      )));
                        },
                      ),
                    ),
                  PopupMenuItem(
                    child: ListTile(
                      title: const Text('Offload'),
                      leading: const Icon(Icons.playlist_remove),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StockOffloading(
                                      initialTabIndex: 0,
                                      tenantConfig: tenantConfigP,
                                    )));
                      },
                    ),
                  ),
                ];
              })
            ],
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
          body: isPrinting
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : FutureBuilder(
                  future: dataLoaded,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Stack(
                        children: [
                          Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                            ), // Show spinner when disabled
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (width > 600)
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  child: SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
                                ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      color: Theme.of(context).primaryColor,
                                      child: TabBar(
                                        controller: _tabController,
                                        tabs: widget.LinesOriented
                                            ? [
                                                Tab(text: 'Line'),
                                                Tab(text: 'Details'),
                                                Tab(text: 'Summary'),
                                              ]
                                            : [
                                                Tab(text: 'Details'),
                                                Tab(text: 'Line'),
                                                Tab(text: 'Summary'),
                                              ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: width > 600
                                            ? const EdgeInsets.fromLTRB(100, 10, 100, 10)
                                            : const EdgeInsets.all(8),
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: widget.LinesOriented
                                              ? [
                                                  if (isLoaded ||widget.LinesOriented|| widget.isUpdate)
                                                    SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets.all(8.0),
                                                                child: Text(
                                                                  'Part Search Form',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 18,
                                                                      color:
                                                                      Theme.of(context).canvasColor),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: Theme.of(context).indicatorColor,
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: !widget.LinesOriented? ElementSearchForm(
                                                                    onElementsSelected:
                                                                    updateElementInformation,
                                                                    arrivedElements:
                                                                    selectedElements.isNotEmpty
                                                                        ? selectedElements
                                                                        : [],
                                                                    isOffloading: false,
                                                                    Warehouse: fromWarehouseController.text??'',
                                                                    AddElement: _addElement,
                                                                    Project: projectIdController.text,
                                                                    tenantConfig: tenantConfigP,
                                                                    isInstalling: false,
                                                                  ) : SizedBox(
                                                                    height: 50,
                                                                    child: Center(
                                                                      child: Text('Lines Oriented',
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                            MediaQuery.of(context)
                                                                                .size
                                                                                .height *
                                                                                0.022,
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Text(
                                                            'Selected Elements',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 18,
                                                                color: Theme.of(context).canvasColor),
                                                          ),
                                                          Row(
                                                            children: [
                                                              ElementTable(
                                                                selectedElements: widget.LinesOriented? widget.passedElements: selectedElements,
                                                                DeletededSaveElements: widget.isUpdate
                                                                    ? deletedSavedElements
                                                                    : null,
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Text(
                                                            'Consumables',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 18,
                                                                color: Theme.of(context).canvasColor),
                                                          ),
                                                          PartTable(selectedParts: selectedParts),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _tabController.animateTo(_tabController.index+1);
                                                              });
                                                            },
                                                            child: const Text('Next'),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  if (!widget.isUpdate&&!isLoaded && !widget.LinesOriented)
                                                    const Center(
                                                      child: Text(
                                                          'Please create a load first or Select a load to update'),
                                                    ),
                                                  //Tab 1 Content
                                                  SingleChildScrollView(
                                                    child: Form(
                                                      key: _formKey,
                                                      child: Center(
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child: Text(
                                                                'Load Details',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 18,
                                                                    color:
                                                                    Theme.of(context).primaryColor),
                                                              ),
                                                            ),
                                                            if (!widget.isUpdate)
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
                                                            if (widget.isUpdate)
                                                              Row(children: [
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
                                                                    //  await makeSureDataLoaded(tenantConfigP);
                                                                    // await fetchLoadDataFromURL(loadIDController.text,tenantConfigP);
                                                                    // await fetchElementDataFromURL();
                                                                    //await fetchPartDataFromURL();
                                                                    await loadLoadAndData(tenantConfigP);
                                                                    String projectLoadID =
                                                                        loadIDController.text;
                                                                    offloadData = getLoadObjectFromJson(
                                                                        projectLoadID);
                                                                    getElementObjectFromJson(
                                                                        projectLoadID);
                                                                    getPartObjectFromJson(projectLoadID);
                                                                    if (offloadData != null) {
                                                                      setState(() {
                                                                        projectIdController.text =
                                                                            offloadData!.projectId;
                                                                        dateController.text =
                                                                            offloadData!.loadDate;
                                                                        toWarehouseController.text =
                                                                            offloadData!.toWarehouse;
                                                                        toBinController.text =
                                                                            offloadData!.toBin;
                                                                        loadTypeValue =
                                                                            offloadData!.loadType;
                                                                        loadConditionValue =
                                                                            offloadData!.loadCondition;
                                                                        fromWarehouseController.text =
                                                                            offloadData!.fromWarehouse;
                                                                        isLoaded = true;
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
                                                                                    Navigator.pop(
                                                                                        context);
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
                                                                  },
                                                                  icon: const Icon(Icons.search),
                                                                ),
                                                              ]),
                                                            Padding(padding: EdgeInsets.all(8.0),
                                                                child: ToggleSwitch(
                                                                  minWidth: 150,
                                                                  initialLabelIndex: archLabelIndex,
                                                                  totalSwitches: 2,
                                                                  labels: ['Stand-alone SO','Project based' ],
                                                                  onToggle: (index) {
                                                                    context.read<ArchitectureProvider>().toggleArchitecure();
                                                                    setState(() {
                                                                      archLabelIndex = index??0;
                                                                    });
                                                                  },
                                                                )
                                                            ),
                                                            context.watch<ArchitectureProvider>().architecure == 'Project'?
                                                            ProjectSearch(isUpdate: widget.isUpdate):SalesOrderSearch(),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: TextFormField(
                                                                      readOnly: true,  // Make the field read-only so it can still respond to taps
                                                                      controller: dateController,
                                                                      onTap: () async {
                                                                        final DateTime? date = await showDatePicker(
                                                                          builder: (BuildContext context, Widget? child) {
                                                                            return Theme(
                                                                              data: ThemeData.light().copyWith(
                                                                                colorScheme: ColorScheme.light(
                                                                                  primary: Theme.of(context).primaryColor,
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
                                                                            dateController.text = "${date.day}/${date.month}/${date.year}";
                                                                            _selectedDate = DateFormat('yyyy-MM-dd').format(date);
                                                                          });
                                                                        }
                                                                      },
                                                                      decoration: const InputDecoration(
                                                                        border: OutlineInputBorder(),
                                                                        labelText: "Load Date",
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: TextFormField(
                                                                        enabled: !widget.isUpdate,
                                                                        onTap: () async {
                                                                          final TimeOfDay? time =
                                                                          await showTimePicker(
                                                                              context: context,
                                                                              initialTime:
                                                                              TimeOfDay.now(),
                                                                              builder: (context, child) {
                                                                                return Theme(
                                                                                  data: Theme.of(context)
                                                                                      .copyWith(
                                                                                    colorScheme:
                                                                                    ColorScheme.light(
                                                                                      primary: Theme.of(
                                                                                          context)
                                                                                          .primaryColor,
                                                                                      onPrimary:
                                                                                      Colors.white,
                                                                                      secondary: Theme.of(
                                                                                          context)
                                                                                          .primaryColor,
                                                                                    ),
                                                                                  ),
                                                                                  child: child!,
                                                                                );
                                                                              });
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
                                                                    )),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: DropdownSearch(
                                                                      selectedItem:
                                                                      fromWarehouseController.text,
                                                                      enabled: true,
                                                                      popupProps: const PopupProps
                                                                          .modalBottomSheet(
                                                                        showSearchBox: true,
                                                                        searchFieldProps: TextFieldProps(
                                                                          decoration: InputDecoration(
                                                                            suffixIcon:
                                                                            Icon(Icons.search),
                                                                            border: OutlineInputBorder(),
                                                                            labelText: "Search",
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      autoValidateMode: AutovalidateMode
                                                                          .onUserInteraction,
                                                                      dropdownDecoratorProps:
                                                                      const DropDownDecoratorProps(
                                                                        dropdownSearchDecoration:
                                                                        InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          labelText: "From Warehouse",
                                                                        ),
                                                                      ),
                                                                      items: fetchedWarehouseValue.map((warehouse) =>
                                                                      warehouse['Description'])
                                                                          .toList(),
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          fromWarehouseController
                                                                              .text = fetchedWarehouseValue
                                                                              .firstWhere(
                                                                                  (warehouse) =>
                                                                              warehouse[
                                                                              'Description'] ==
                                                                                  value)[
                                                                          'WarehouseCode'];
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),

                                                              ],
                                                            ),



                                                            if (loadConditionValue == 'External')
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
                                                                      )),
                                                                  Expanded(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: TextFormField(
                                                                          controller: poLineController,
                                                                          decoration: const InputDecoration(
                                                                              border: OutlineInputBorder(),
                                                                              labelText: "PO Line"),
                                                                        ),
                                                                      )),
                                                                ],
                                                              ),
                                                            Row(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Column(children: [
                                                                      Padding(
                                                                        padding: EdgeInsets.all(8.0),
                                                                        child: Text(
                                                                          'Load Type',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 18,
                                                                              color: Theme.of(context)
                                                                                  .canvasColor),
                                                                        ),
                                                                      ),
                                                                      RadioListTile(
                                                                        title: Text('Return Trip',
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                              MediaQuery.of(context)
                                                                                  .size
                                                                                  .height *
                                                                                  0.022,
                                                                            )),
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
                                                                        title: Text('Delivery Trip',
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                              MediaQuery.of(context)
                                                                                  .size
                                                                                  .height *
                                                                                  0.022,
                                                                            )),
                                                                        value: 'Issue Load',
                                                                        groupValue: loadTypeValue,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            loadTypeValue =
                                                                                value.toString();
                                                                          });
                                                                        },
                                                                      ),
                                                                    ]),
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(children: [
                                                                      Padding(
                                                                        padding: EdgeInsets.all(8.0),
                                                                        child: Text(
                                                                          'Truck Type',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 18,
                                                                              color: Theme.of(context)
                                                                                  .canvasColor),
                                                                        ),
                                                                      ),
                                                                      RadioListTile(
                                                                        title: Text('External',
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                              MediaQuery.of(context)
                                                                                  .size
                                                                                  .height *
                                                                                  0.022,
                                                                            )),
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
                                                                        title: Text('Internal',
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                              MediaQuery.of(context)
                                                                                  .size
                                                                                  .height *
                                                                                  0.022,
                                                                            )),
                                                                        value: 'Internal Truck',
                                                                        groupValue: loadConditionValue,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            loadConditionValue =
                                                                                value.toString();
                                                                          });
                                                                        },
                                                                      )
                                                                    ]),
                                                                  ),
                                                                ]),
                                                            Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child: Text(
                                                                'Truck Details',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 18,
                                                                    color: Theme.of(context).canvasColor),
                                                              ),
                                                            ),
                                                            if (!widget.isUpdate)
                                                              buildTruckDetailsFrom(true),
                                                            if (widget.isUpdate)
                                                              TruckDetailsForm(
                                                                isEdit: true,
                                                                truckDetails: offloadData,
                                                              ),
                                                            const SizedBox(height: 20),
                                                            if (widget.isUpdate)
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    _tabController.animateTo(_tabController.index+1);
                                                                  });
                                                                },
                                                                child: const Text('Next'),
                                                              ),
                                                            if (!widget.isUpdate)
                                                              ElevatedButton(
                                                                  onPressed: () async {
                                                                    if(!CreateLoadLoading){
                                                                      setState(() {
                                                                        CreateLoadLoading = true;
                                                                      });
                                                                      if (truckIdController.text.isEmpty ||
                                                                          resourceIdController
                                                                              .text.isEmpty ||

                                                                          loadTimeController.text.isEmpty ||
                                                                          dateController.text.isEmpty
                                                                      ) {
                                                                        showDialog(
                                                                            context: context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return AlertDialog(
                                                                                title: const Text('Error'),
                                                                                content: const Text(
                                                                                    'Please fill all the required fields'),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.of(context)
                                                                                          .pop();
                                                                                    },
                                                                                    child: const Text('OK'),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            });
                                                                      } else {
                                                                        final newLoadId =
                                                                            'I-${lastLoad + 1}';
                                                                        final loadDateFormat =
                                                                            '${_selectedDate}T00:00:00';
                                                                        debugPrint(toBinController.text);
                                                                        await createNewLoad({
                                                                          "Key1": newLoadId,
                                                                          "Company":
                                                                          "${tenantConfigP['company']}",
                                                                          "ShortChar07":
                                                                          plateNumberController.text,
                                                                          "ShortChar05":context.read<ArchitectureProvider>().architecure,
                                                                          "ShortChar01": loadTypeValue,
                                                                          "ShortChar04": loadConditionValue,
                                                                          "ShortChar08":
                                                                          truckIdController.text,
                                                                          "ShortChar03": "Open",

                                                                          "Number01": loadedController
                                                                              .text.isNotEmpty
                                                                              ? loadedController.text
                                                                              : '0',
                                                                          "Number02": "0",
                                                                          "Number03": context.read<ArchitectureProvider>().SO.toString(),
                                                                          "Number06": capacityController
                                                                              .text.isNotEmpty
                                                                              ? capacityController.text
                                                                              : '0',
                                                                          "Number07": volumeController
                                                                              .text.isNotEmpty
                                                                              ? volumeController.text
                                                                              : '0',
                                                                          "Number08": heightController
                                                                              .text.isNotEmpty
                                                                              ? heightController.text
                                                                              : '0',
                                                                          "Number09": widthController
                                                                              .text.isNotEmpty
                                                                              ? widthController.text
                                                                              : '0',
                                                                          "Number10": lengthController
                                                                              .text.isNotEmpty
                                                                              ? lengthController.text
                                                                              : '0',
                                                                          "Number11":
                                                                          (lastCustShip + 1).toString(),
                                                                          "Number12": context.read<ArchitectureProvider>().custNum.toString(),
                                                                          "Date01": loadDateFormat,

                                                                          "Character02":
                                                                          driverNameController.text,
                                                                          "Character03":
                                                                          driverNumberController.text,
                                                                          "Character04": context.read<ArchitectureProvider>().CustomerId,

                                                                          "Character07":context.read<ArchitectureProvider>().SO.toString(),
                                                                          "Character08":context.read<ArchitectureProvider>().selectedShipment,


                                                                          "Character09": resourceId,
                                                                          //  "Createdby_c": entryPersonController?.text.toString().trim(),
                                                                          //  "Deviceid_c":  deviceIDController?.text.toString().trim(),
                                                                        }, tenantConfigP);
                                                                        debugPrint(
                                                                            toWarehouseNameController.text);
                                                                        if (isLoaded) {
                                                                          if (mounted) {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder:
                                                                                    (BuildContext context) {
                                                                                      return AlertDialog(
                                                                                        title: const Text(
                                                                                            'Success'),
                                                                                        content: Text(

                                                                                            'Delivery ticket created successfully, LoadID: $newLoadId, customer shimpent: ${lastCustShip + 1}'),

                                                                                        actions: [
                                                                                          TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(
                                                                                                  context)
                                                                                                  .pop();
                                                                                              _tabController
                                                                                                  .animateTo(1);
                                                                                            },
                                                                                            child: Text('OK',
                                                                                                style: TextStyle(
                                                                                                    color: Theme.of(
                                                                                                        context)
                                                                                                        .canvasColor)),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    });
                                                                          }
                                                                          setState(() {
                                                                            loadIDController.text =
                                                                                newLoadId;
                                                                          });
                                                                        }
                                                                      }
                                                                      setState(() {
                                                                        CreateLoadLoading = false;
                                                                      });
                                                                    }
                                                                  },
                                                                  child: CreateLoadLoading
                                                                      ? Padding(
                                                                    padding: const EdgeInsets.fromLTRB(22.0,0,22.0,0),
                                                                    child: Container(
                                                                      height: 20,
                                                                      width: 20,
                                                                      child: const CircularProgressIndicator(
                                                                        valueColor:
                                                                        AlwaysStoppedAnimation<Color>(
                                                                            Colors.white),
                                                                      ),
                                                                    ),
                                                                  )

                                                                      : const Text('Create Load')),
                                                            const SizedBox(height: 20),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  //Tab 2 Content

                                                  //Tab 3 Content
                                                  SingleChildScrollView(
                                                    controller: ScrollController(),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.all(8.0),
                                                            child: Text(
                                                              'Project Details',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18,
                                                                  color: Theme.of(context).canvasColor),
                                                            ),
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
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
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
                                                                  )),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: TextFormField(
                                                                      enabled: false,
                                                                      initialValue:
                                                                      fromWarehouseController.text,
                                                                      decoration: const InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          labelText: "From"),
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: TextFormField(
                                                                      enabled: false,
                                                                      initialValue:
                                                                      toWarehouseController.text,
                                                                      decoration: const InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          labelText: "To"),
                                                                    ),
                                                                  )),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.all(8.0),
                                                            child: Text(
                                                              'Truck Details',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18,
                                                                  color: Theme.of(context).primaryColor),
                                                            ),
                                                          ),
                                                          if (!widget.isUpdate)
                                                            buildTruckDetailsFrom(false),
                                                          if (widget.isUpdate)
                                                            TruckDetailsForm(
                                                              isEdit: true,
                                                              truckDetails: offloadData,
                                                            ),
                                                          Padding(
                                                            padding: EdgeInsets.all(8.0),
                                                            child: Text(
                                                              'Selected Elements',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18,
                                                                  color: Theme.of(context).canvasColor),
                                                            ),
                                                          ),
                                                          ElementTable(
                                                              selectedElements: widget.LinesOriented?widget.passedElements: selectedElements),
                                                          Padding(
                                                            padding: EdgeInsets.all(8.0),
                                                            child: Text(
                                                              'Selected Parts',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18,
                                                                  color: Theme.of(context).canvasColor),
                                                            ),
                                                          ),
                                                          PartTable(selectedParts: selectedParts),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          ElevatedButton(

                                                              onPressed: () async {
                                                                if(!SaveLinesLoading){
                                                                  debugPrint(
                                                                      selectedElements.length.toString());
                                                                  setState(() {
                                                                    SaveLinesLoading = true;
                                                                  });
                                                                  for (var e = 0;
                                                                  e < selectedElements.length;
                                                                  e++) {
                                                                    debugPrint(
                                                                        selectedElements[e].toString());
                                                                    try {
                                                                      await updateUD104A(ElementData.fromJson({
                                                                        "Company":
                                                                        "${tenantConfigP['company']}",

                                                                        "ChildKey1":
                                                                        (e+1).toString(),
                                                                        "Key1": loadIDController.text,
                                                                        "Character01":
                                                                        selectedElements[e].partId,
                                                                        "Character02":
                                                                        selectedElements[e].elementId,
                                                                        "Character03":
                                                                        fromWarehouseController.text,
                                                                        "Character04":
                                                                        selectedElements[e].fromBin,
                                                                        "Character07":
                                                                        toWarehouseController.text,
                                                                        "Character05": toBinController.text,
                                                                        "Number01": selectedElements[e]
                                                                            .selectedQty
                                                                            .toString()
                                                                            .isNotEmpty
                                                                            ? selectedElements[e]
                                                                            .selectedQty
                                                                            .toString()
                                                                            : '0',
                                                                        "Number03": selectedElements[e]
                                                                            .weight
                                                                            .toString()
                                                                            .isNotEmpty
                                                                            ? selectedElements[e].weight.toString()
                                                                            : '0',
                                                                        "Number04": selectedElements[e]
                                                                            .area
                                                                            .toString()
                                                                            .isNotEmpty
                                                                            ? selectedElements[e].area.toString()
                                                                            : '0',
                                                                        "Number05": selectedElements[e]
                                                                            .volume
                                                                            .toString()
                                                                            .isNotEmpty
                                                                            ? selectedElements[e].volume.toString()
                                                                            : '0',
                                                                        "Number06": selectedElements[e]
                                                                            .erectionSeq
                                                                            .toString()
                                                                            .isNotEmpty
                                                                            ? selectedElements[e]
                                                                            .erectionSeq.toString()
                                                                            : '0',
                                                                        "ShortChar07":
                                                                        selectedElements[e].UOM,
                                                                        "CheckBox05": false,
                                                                        "CheckBox01": true,
                                                                        "CheckBox02": false,
                                                                        "CheckBox03": false,
                                                                        "CheckBox07": false,
                                                                        "CheckBox13": false,
                                                                        "Character08":
                                                                        selectedElements[e].Revision,
                                                                        "Character09":
                                                                        selectedElements[e].UOMClass
                                                                      }), tenantConfigP);
                                                                      updateInTransit(
                                                                          selectedElements[e].partId,
                                                                          selectedElements[e].elementId,
                                                                          tenantConfigP);
                                                                      childCount++;
                                                                      LineStatus[selectedElements[e].elementId]='Success';

                                                                    } on HttpException  catch (error) {

                                                                      setState(() {
                                                                        LineStatus[selectedElements[e].elementId]= "Error: ${(e+1).toString()}. "+error.message;
                                                                      });

                                                                    }
                                                                  }
                                                                  for (int i = 0;
                                                                  i < deletedSavedElements.length;
                                                                  i++) {
                                                                    try {
                                                                      await deleteUD104A(
                                                                          deletedSavedElements[i],
                                                                          tenantConfigP);
                                                                      LineStatus[deletedSavedElements[i].elementId]='deleted Successfully';
                                                                    } catch (e) {
                                                                      setState(() {
                                                                        LineStatus[deletedSavedElements[i].elementId]= "Error: ${(i+1).toString()}. "+ e.toString()+" \n";
                                                                      });
                                                                    }
                                                                  }
                                                                  for (var p = 0;
                                                                  p < selectedParts.length;
                                                                  p++) {
                                                                    debugPrint(selectedParts[p].toString());
                                                                    await updateUD104A(ElementData.fromJson({
                                                                      "ChildKey1":
                                                                      (p + 1).toString(),
                                                                      "Company":
                                                                      "${tenantConfigP['company']}",
                                                                      "Key1": loadIDController.text,
                                                                      "Character01":
                                                                      selectedParts[p].partNum,
                                                                      "Character02":
                                                                      selectedParts[p].partDesc,
                                                                      "Character03":
                                                                      toWarehouseController.text,
                                                                      "Character04": toBinController.text,
                                                                      "Number01": selectedParts[p].qty,
                                                                      "ShortChar07": selectedParts[p].uom,
                                                                      "CheckBox13": true,
                                                                    }), tenantConfigP);
                                                                  }
                                                                  if (mounted) {
                                                                    String resultMessage=LineStatus.map((key, value) => MapEntry(key, value)).values.join('\n');
                                                                    showDialog(context: context, builder:
                                                                        (BuildContext context) {
                                                                      return AlertDialog(
                                                                        title: const Text('Result'),
                                                                        content: Text(resultMessage),
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
                                                                  }}
                                                                setState(() {
                                                                  SaveLinesLoading = false;
                                                                });
                                                              },
                                                              child: SaveLinesLoading?
                                                              Padding(

                                                                padding: const EdgeInsets.fromLTRB(22.0,0,22.0,0),
                                                                child: Container(
                                                                  height: 20,
                                                                  width: 20,
                                                                  child: CircularProgressIndicator(
                                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                                        Theme.of(context).shadowColor),
                                                                  ),
                                                                ),
                                                              )
                                                                  :const Text(
                                                                'Load Lines',
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                              : [
                                                  //Tab 1 Content
                                                  SingleChildScrollView(
                                                    child: Form(
                                                      key: _formKey,
                                                      child: Center(
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child: Text(
                                                                'Load Details',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 18,
                                                                    color:
                                                                    Theme.of(context).primaryColor),
                                                              ),
                                                            ),
                                                            if (!widget.isUpdate)
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
                                                            if (widget.isUpdate)
                                                              Row(children: [
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
                                                                    //  await makeSureDataLoaded(tenantConfigP);
                                                                    // await fetchLoadDataFromURL(loadIDController.text,tenantConfigP);
                                                                    // await fetchElementDataFromURL();
                                                                    //await fetchPartDataFromURL();
                                                                    await loadLoadAndData(tenantConfigP);
                                                                    String projectLoadID =
                                                                        loadIDController.text;
                                                                    offloadData = getLoadObjectFromJson(
                                                                        projectLoadID);
                                                                    getElementObjectFromJson(
                                                                        projectLoadID);
                                                                    getPartObjectFromJson(projectLoadID);
                                                                    if (offloadData != null) {
                                                                      setState(() {
                                                                        projectIdController.text =
                                                                            offloadData!.projectId;
                                                                        dateController.text =
                                                                            offloadData!.loadDate;
                                                                        toWarehouseController.text =
                                                                            offloadData!.toWarehouse;
                                                                        toBinController.text =
                                                                            offloadData!.toBin;
                                                                        loadTypeValue =
                                                                            offloadData!.loadType;
                                                                        loadConditionValue =
                                                                            offloadData!.loadCondition;
                                                                        fromWarehouseController.text =
                                                                            offloadData!.fromWarehouse;
                                                                        isLoaded = true;
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
                                                                                    Navigator.pop(
                                                                                        context);
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
                                                                  },
                                                                  icon: const Icon(Icons.search),
                                                                ),
                                                              ]),
                                                            Padding(padding: EdgeInsets.all(8.0),
                                                                child: ToggleSwitch(
                                                                  minWidth: 150,
                                                                  initialLabelIndex: archLabelIndex,
                                                                  totalSwitches: 2,
                                                                  labels: ['Stand-alone SO','Project based' ],
                                                                  onToggle: (index) {
                                                                    context.read<ArchitectureProvider>().toggleArchitecure();
                                                                    setState(() {
                                                                      archLabelIndex = index??0;
                                                                    });
                                                                  },
                                                                )
                                                            ),
                                                            context.watch<ArchitectureProvider>().architecure == 'Project'?
                                                            ProjectSearch(isUpdate: widget.isUpdate):SalesOrderSearch(),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: TextFormField(
                                                                      readOnly: true,  // Make the field read-only so it can still respond to taps
                                                                      controller: dateController,
                                                                      onTap: () async {
                                                                        final DateTime? date = await showDatePicker(
                                                                          builder: (BuildContext context, Widget? child) {
                                                                            return Theme(
                                                                              data: ThemeData.light().copyWith(
                                                                                colorScheme: ColorScheme.light(
                                                                                  primary: Theme.of(context).primaryColor,
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
                                                                            dateController.text = "${date.day}/${date.month}/${date.year}";
                                                                            _selectedDate = DateFormat('yyyy-MM-dd').format(date);
                                                                          });
                                                                        }
                                                                      },
                                                                      decoration: const InputDecoration(
                                                                        border: OutlineInputBorder(),
                                                                        labelText: "Load Date",
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: TextFormField(
                                                                        enabled: !widget.isUpdate,
                                                                        onTap: () async {
                                                                          final TimeOfDay? time =
                                                                          await showTimePicker(
                                                                              context: context,
                                                                              initialTime:
                                                                              TimeOfDay.now(),
                                                                              builder: (context, child) {
                                                                                return Theme(
                                                                                  data: Theme.of(context)
                                                                                      .copyWith(
                                                                                    colorScheme:
                                                                                    ColorScheme.light(
                                                                                      primary: Theme.of(
                                                                                          context)
                                                                                          .primaryColor,
                                                                                      onPrimary:
                                                                                      Colors.white,
                                                                                      secondary: Theme.of(
                                                                                          context)
                                                                                          .primaryColor,
                                                                                    ),
                                                                                  ),
                                                                                  child: child!,
                                                                                );
                                                                              });
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
                                                                    )),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: DropdownSearch(
                                                                      selectedItem:
                                                                      fromWarehouseController.text,
                                                                      enabled: true,
                                                                      popupProps: const PopupProps
                                                                          .modalBottomSheet(
                                                                        showSearchBox: true,
                                                                        searchFieldProps: TextFieldProps(
                                                                          decoration: InputDecoration(
                                                                            suffixIcon:
                                                                            Icon(Icons.search),
                                                                            border: OutlineInputBorder(),
                                                                            labelText: "Search",
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      autoValidateMode: AutovalidateMode
                                                                          .onUserInteraction,
                                                                      dropdownDecoratorProps:
                                                                      const DropDownDecoratorProps(
                                                                        dropdownSearchDecoration:
                                                                        InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          labelText: "From Warehouse",
                                                                        ),
                                                                      ),
                                                                      items: fetchedWarehouseValue.map((warehouse) =>
                                                                      warehouse['Description'])
                                                                          .toList(),
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          fromWarehouseController
                                                                              .text = fetchedWarehouseValue
                                                                              .firstWhere(
                                                                                  (warehouse) =>
                                                                              warehouse[
                                                                              'Description'] ==
                                                                                  value)[
                                                                          'WarehouseCode'];
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),

                                                              ],
                                                            ),


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
                                      ),*/
                                  ReDropDown(
                                    enabled: toWarehouseController.text != "",
                                    data: fetchedBinValue
                                        .map((bin) => bin['Description'])
                                        .toList(),
                                    label: "To Bin",
                                    loading: toBinLoading,
                                    controller: toBinController,
                                    dataMap: fetchedBinValue,
                                  ),
                                  if (loadConditionValue == 'External')
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
                                        )),
                                        Expanded(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: poLineController,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "PO Line"),
                                          ),
                                        )),
                                      ],
                                    ),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(children: [
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Load Type',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Theme.of(context)
                                                        .canvasColor),
                                              ),
                                            ),
                                            RadioListTile(
                                              title: Text('Return Trip',
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.022,
                                                  )),
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
                                              title: Text('Delivery Trip',
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.022,
                                                  )),
                                              value: 'Issue Load',
                                              groupValue: loadTypeValue,
                                              onChanged: (value) {
                                                setState(() {
                                                  loadTypeValue =
                                                      value.toString();
                                                });
                                              },
                                            ),
                                          ]),
                                        ),
                                        Expanded(
                                          child: Column(children: [
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Load Condition',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Theme.of(context)
                                                        .canvasColor),
                                              ),
                                            ),
                                            RadioListTile(
                                              title: Text('External',
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.022,
                                                  )),
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
                                              title: Text('Internal',
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.022,
                                                  )),
                                              value: 'Internal Truck',
                                              groupValue: loadConditionValue,
                                              onChanged: (value) {
                                                setState(() {
                                                  loadConditionValue =
                                                      value.toString();
                                                });
                                              },
                                            )
                                          ]),
                                        ),
                                      ]),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Truck Details',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Theme.of(context).canvasColor),
                                    ),
                                  ),
                                  if (!widget.isUpdate)
                                    buildTruckDetailsFrom(true),
                                  if (widget.isUpdate)
                                    TruckDetailsForm(
                                      isEdit: true,
                                      truckDetails: offloadData,
                                    ),
                                  const SizedBox(height: 20),
                                  if (widget.isUpdate)
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _tabController.animateTo(1);
                                        });
                                      },
                                      child: const Text('Next'),
                                    ),
                                  if (!widget.isUpdate)
                                    ElevatedButton(
                                        onPressed: () async {
                                          if (truckIdController.text.isEmpty ||
                                              resourceIdController
                                                  .text.isEmpty ||
                                              projectIdController
                                                  .text.isEmpty) {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('Error'),
                                                    content: const Text(
                                                        'Please fill all the required fields'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          } else {
                                            final newLoadId =
                                                'I-${lastLoad + 1}';
                                            final loadDateFormat =
                                                '${_selectedDate}T00:00:00';
                                            debugPrint(toBinController.text);
                                            await createNewLoad({
                                              "Key1": newLoadId,
                                              "Company":
                                                  "${tenantConfigP['company']}",
                                              "ShortChar07":
                                                  plateNumberController.text,
                                              "ShortChar05":
                                                  projectIdController.text,
                                              "ShortChar01": loadTypeValue,
                                              "ShortChar04": loadConditionValue,
                                              "ShortChar08":
                                                  truckIdController.text,
                                              "ShortChar03": "Open",

                                              "Number01": loadedController
                                                      .text.isNotEmpty
                                                  ? loadedController.text
                                                  : '0',
                                              "Number02": "0",
                                              "Number06": capacityController
                                                      .text.isNotEmpty
                                                  ? capacityController.text
                                                  : '0',
                                              "Number07": volumeController
                                                      .text.isNotEmpty
                                                  ? volumeController.text
                                                  : '0',
                                              "Number08": heightController
                                                      .text.isNotEmpty
                                                  ? heightController.text
                                                  : '0',
                                              "Number09": widthController
                                                      .text.isNotEmpty
                                                  ? widthController.text
                                                  : '0',
                                              "Number10": lengthController
                                                      .text.isNotEmpty
                                                  ? lengthController.text
                                                  : '0',
                                              "Number11":
                                                  (lastCustShip + 1).toString(),
                                              "Number12": custNum.toString(),
                                              "Date01": loadDateFormat,

                                              "Character02":
                                                  driverNameController.text,
                                              "Character03":
                                                  driverNumberController.text,
                                              "Character04":
                                                  toWarehouseNameController
                                                      .text,
                                              "Character05":
                                                  toBinController.text,
                                              "Character07":
                                                  toWarehouseController.text,
                                              "Character08":
                                                  toBinController.text,
                                              "Character06":
                                                  fromWarehouseController.text,
                                              "Character09": resourceId,
                                              //  "Createdby_c": entryPersonController?.text.toString().trim(),
                                              //  "Deviceid_c":  deviceIDController?.text.toString().trim(),
                                            }, tenantConfigP);
                                            debugPrint(
                                                toWarehouseNameController.text);
                                            if (isLoaded) {
                                              if (mounted) {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Success'),
                                                        content: Text(
                                                            'Stock Loading details saved successfully, LoadID: $newLoadId'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              _tabController
                                                                  .animateTo(1);
                                                            },
                                                            child: Text('OK',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .canvasColor)),
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              }
                                              setState(() {
                                                loadIDController.text =
                                                    newLoadId;
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
                        if (isLoaded)
                          SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Part Search Form',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color:
                                                Theme.of(context).canvasColor),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).indicatorColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElementSearchForm(
                                          onElementsSelected:
                                              updateElementInformation,
                                          arrivedElements:
                                              selectedElements.isNotEmpty
                                                  ? selectedElements
                                                  : [],
                                          isOffloading: false,
                                          Warehouse: fromWarehouseController.text??'',
                                          AddElement: _addElement,
                                          Project: projectIdController.text,
                                          tenantConfig: tenantConfigP,
                                          isInstalling: false,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Selected Elements',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context).canvasColor),
                                ),
                                ElementTable(
                                  selectedElements: selectedElements,
                                  DeletededSaveElements: widget.isUpdate
                                      ? deletedSavedElements
                                      : null,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Selected Parts',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context).canvasColor),
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
                              ],
                            ),
                          ),
                        if (!isLoaded)
                          const Center(
                            child: Text(
                                'Please create a load first or Select a load to update'),
                          ),
                        //Tab 3 Content
                        SingleChildScrollView(
                          controller: ScrollController(),
                          child: Center(
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Project Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context).canvasColor),
                                  ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                    )),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        enabled: false,
                                        initialValue:
                                            fromWarehouseController.text,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "From"),
                                      ),
                                    )),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        enabled: false,
                                        initialValue:
                                            toWarehouseController.text,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "To"),
                                      ),
                                    )),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Truck Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                if (!widget.isUpdate)
                                  buildTruckDetailsFrom(false),
                                if (widget.isUpdate)
                                  TruckDetailsForm(
                                    isEdit: true,
                                    truckDetails: offloadData,
                                  ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Selected Elements',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context).canvasColor),
                                  ),
                                ),
                                ElementTable(
                                    selectedElements: selectedElements),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Selected Parts',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context).canvasColor),
                                  ),
                                ),
                                PartTable(selectedParts: selectedParts),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      debugPrint(
                                          selectedElements.length.toString());
                                      for (var e = 0;
                                          e < selectedElements.length;
                                          e++) {
                                        debugPrint(
                                            selectedElements[e].toString());
                                        try {
                                          await updateUD104A({
                                            "Company":
                                                "${tenantConfigP['company']}",
                                            "ChildKey1":
                                                selectedElements[e].ChildKey1,
                                            "Key1": loadIDController.text,
                                            "Character01":
                                                selectedElements[e].partId,
                                            "Character02":
                                                selectedElements[e].elementId,
                                            "Character03":
                                                fromWarehouseController.text,
                                            "Character04":
                                                selectedElements[e].fromBin,
                                            "Character07":
                                                toWarehouseController.text,
                                            "Character05": toBinController.text,
                                            "Number01": selectedElements[e]
                                                    .selectedQty
                                                    .toString()
                                                    .isNotEmpty
                                                ? selectedElements[e]
                                                    .selectedQty
                                                    .toString()
                                                : '0',
                                            "Number03": selectedElements[e]
                                                    .weight
                                                    .toString()
                                                    .isNotEmpty
                                                ? selectedElements[e].weight
                                                : '0',
                                            "Number04": selectedElements[e]
                                                    .area
                                                    .toString()
                                                    .isNotEmpty
                                                ? selectedElements[e].area
                                                : '0',
                                            "Number05": selectedElements[e]
                                                    .volume
                                                    .toString()
                                                    .isNotEmpty
                                                ? selectedElements[e].volume
                                                : '0',
                                            "Number06": selectedElements[e]
                                                    .erectionSeq
                                                    .toString()
                                                    .isNotEmpty
                                                ? selectedElements[e]
                                                    .erectionSeq
                                                : '0',
                                            "ShortChar07":
                                                selectedElements[e].UOM,
                                            "CheckBox05": false,
                                            "CheckBox01": true,
                                            "CheckBox02": false,
                                            "CheckBox03": false,
                                            "CheckBox07": false,
                                            "CheckBox13": false,
                                          }, tenantConfigP);
                                          updateInTransit(
                                              selectedElements[e].partId,
                                              selectedElements[e].elementId,
                                              tenantConfigP);
                                          childCount++;
                                        } on Exception catch (e) {
                                          setState(() {
                                            ErrorMessage=e.toString();
                                          });

                                        }
                                      }
                                      for (int i = 0;
                                          i < deletedSavedElements.length;
                                          i++) {
                                        try {
                                          await deleteUD104A(
                                              deletedSavedElements[i],
                                              tenantConfigP);
                                        } catch (e) {
                                          setState(() {
                                            ErrorMessage=e.toString();
                                          });
                                        }
                                      }
                                      for (var p = 0;
                                          p < selectedParts.length;
                                          p++) {
                                        debugPrint(selectedParts[p].toString());
                                        await updateUD104A({
                                          "Company":
                                              "${tenantConfigP['company']}",
                                          "Key1": loadIDController.text,
                                          "Character01":
                                              selectedParts[p].partNum,
                                          "Character02":
                                              selectedParts[p].partDesc,
                                          "Character03":
                                              toWarehouseController.text,
                                          "Character04": toBinController.text,
                                          "Number01": selectedParts[p].qty,
                                          "ShortChar07": selectedParts[p].uom,
                                          "CheckBox13": true,
                                        }, tenantConfigP);
                                      }
                                      if (mounted) {
                                        if(ErrorMessage.isEmpty){
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
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('OK',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .canvasColor)),
                                                  ),
                                                ],
                                              );
                                            });}
                                        else{
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Error',style: TextStyle(
                                                      color: Colors.red
                                                  ),),
                                                  content: Text(
                                                      'error happened while updating the line '+ErrorMessage.toString()),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('OK',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                  context)
                                                                  .canvasColor)),
                                                    ),
                                                  ],
                                                );
                                              });
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Save Load',
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    );
                  }),
        ),
      ),
    );
  }

  Future<void> makeSureDataLoaded(dynamic tenantConfigP) async {
    await Future.wait([
      getProjectList(tenantConfigP),
      getTrucksFromURL(tenantConfigP),
      getDriverList(tenantConfigP),
      getLastLoadID(tenantConfigP),
      getWarehouseList(tenantConfigP),
      getLastCustomerShipment(tenantConfigP)
    ]);
  }

  void _addElement(ElementData element) {
    setState(() {
      selectedElements.add(element);
    });
  }

  Future<bool> submitReport(tenantConfigP) async {
    dynamic body = {
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
            "RptPageSettings":
                "Color=True,Landscape=False,AutoRotate=False,PaperSize=[Kind=\"Custom\" PaperName=\"Custom\" Height=0 Width=0],PaperSource=[SourceName=\"Automatically Select\" Kind=\"Custom\"],PrinterResolution=[]",
            "RptPrinterSettings":
                "PrinterName=\"Microsoft Print to PDF\",Copies=1,Collate=False,Duplex=Default,FromPage=1,ToPage=0",
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
            "Company": "${tenantConfigP['company']}",
            "ReportID": "IIT_DeliveryNot",
            "StyleNum": 1002,
            "StyleDescription": "Delivery Note Report - SSRS",
            "RptTypeID": "SSRS",
            "PrintProgram":
                "Reports/CustomReports/IIT_DeliveryNot/IIT_Delivery_v2",
            "PrintProgramOptions": "",
            "RptDefID": "IIT_DeliveryNot",
            "CompanyList": "${tenantConfigP['company']}",
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
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final submitReportURL = Uri.parse(
          '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Ice.RPT.BAQReportSvc/TransformAndSubmit');
      final response = await http.post(submitReportURL,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(body));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<dynamic> fetchPDFCounts(dynamic tenantConfigP) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final pdfCountsURL = Uri.parse(
          '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/BaqSvc/IIT_getDN(${tenantConfigP['company']})');
      final response = await http.get(pdfCountsURL, headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse['value'];
      } else {
        return null;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getProjectList(dynamic tenantConfigP) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final response = await http.get(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Erp.Bo.ProjectSvc/List/'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
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

  Future<Uint8List> deliveryNote(String base64String) async {
    Uint8List decodedBytes = base64.decode(base64String);
    final pdf = pw.Document();
    final directory = await getApplicationDocumentsDirectory();
    final output =
        File('${directory.path}/DeliveryNote${loadIDController.text}.pdf');

    await pdf.save();
    await output.writeAsBytes(decodedBytes, flush: true);

    return output.readAsBytesSync();
  }

  Future<void> getWarehouseList(dynamic tenantConfigP) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final response = await http.get(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Erp.Bo.WarehseSvc/Warehses'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
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

  Future<void> getBinsFromWarehouse(
      dynamic tenantConfigP, String warehouse) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final response = await http.get(
          Uri.parse(
              "${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Erp.BO.WhseBinSvc/WhseBins?\$filter=WarehouseCode eq '$warehouse'"),
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
    } on Exception catch (e) {
      debugPrint(e.toString());
      setState(() {
        toBinLoading = false;
      });
    }
  }

  void updateElementInformation(List<ElementData> selectedElementsFromForm,
      List<PartData> selectedPartsFromForm) {
    setState(() {
      selectedElements = selectedElementsFromForm;
      selectedParts = selectedPartsFromForm;
    });
  }

  Future<void> createNewLoad(
      Map<String, dynamic> loadItems, tenantConfigP) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final response = await http.post(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/UD104s'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(loadItems));
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
      if (resourceValue!
          .where((element) => element['Character01'] == resourceID)
          .isNotEmpty) {
        resourceDetails = ResourceDetails.fromJson(resourceValue!
            .where((element) => element['Character01'] == resourceID)
            .first);
        return resourceDetails;
      }
    }
    return null;
  }

  Future<void> getTrucksFromURL(dynamic tenantConfigP) async {
    try {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

      var truckURL = Uri.parse(
          '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Ice.BO.UD102Svc/UD102s');

      final response = await http.get(truckURL, headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      final jsonResponse = json.decode(response.body);
      setState(() {
        truckData = jsonResponse;
        truckValue = truckData['value'];
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getResourceForTrucks(String resourceID, tenantConfigP) async {
    resourceValue = [];
    var urL = Uri.parse(
        "${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Ice.BO.UD102Svc/UD102As?\$filter=Key1 eq '$resourceID'");
    try {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

      final response = await http.get(urL, headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.contentTypeHeader: 'application/json',
      });
      final jsonResponse = json.decode(response.body);
      setState(() {
        resourceData = jsonResponse;
        resourceValue = resourceData['value'];
        if (resourceValue!.isNotEmpty) {
          resourceDetails = ResourceDetails.fromJson(resourceValue!.first);
        }
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getDriverList(dynamic tenantConfigP) async {
    try {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

      final response = await http.get(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/BaqSvc/IIT_DriverName(${tenantConfigP['company']})'),
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

  Future<void> getLastLoadID(dynamic tenantConfigP) async {
    try {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

      final response = await http.get(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/BaqSvc/IIT_UD104AutoGenerateNum(${tenantConfigP['company']})'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if (response.statusCode == 200) {
        Map<String, dynamic> rp = json.decode(response.body);
        setState(() {
          lastLoad = rp['value'][0]['Calculated_AutoGen'];
        });
        debugPrint(lastLoad.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getLastCustomerShipment(dynamic tenantConfigP) async {
    try {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

      final response = await http.get(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/BaqSvc/IIT_MaxShip(${tenantConfigP['company']})'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if (response.statusCode == 200) {
        Map<String, dynamic> rp = json.decode(response.body);
        setState(() {
          lastCustShip = rp['value'][0]['Calculated_Max_packNum'];
        });
        debugPrint(lastCustShip.toString());
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> fetchLoadDataFromURL(
      String loadId, dynamic tenantConfigP) async {
    try {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

      Map<String, dynamic> body = {
        "Company": tenantConfigP["company"],
        "key1": loadId,
        "key2": "",
        "key3": "",
        "key4": "",
        "key5": ""
      };
      final url = Uri.parse(
          "${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/GetByID");
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
        loadValue = loadData['UD104'];
        currentLoad = LoadData.fromJson(loadValue[0]);

        elementValue = loadData['UD104A']
            .where((element) => element['CheckBox13'] == false)
            .toList();
        partValue = loadData['UD104A']
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
    if (loadValue.isNotEmpty) {
      LoadData loadObject = LoadData.fromJson(loadValue[0]);
      return loadObject;
    }
    return null;
  }

  ElementData? getElementObjectFromJson(String loadID) {
    if (elementValue.isNotEmpty) {
      var matchingElement =
          elementValue.where((element) => element['Key1'] == loadID).toList();
      ElementData? elementObject;
      setState(() {
        selectedElements.clear();
      });
      if (matchingElement.isNotEmpty) {
        for (var v = 0; v < matchingElement.length; v++) {
          elementObject = ElementData.fromJson(matchingElement[v]);
          debugPrint(elementObject.elementId);
          selectedElements.add(elementObject);
        }
      }
    }
    return null;
  }

  PartData? getPartObjectFromJson(String loadID) {
    if (partValue.isNotEmpty) {
      var matchingPart =
          partValue.where((part) => part['Key1'] == loadID).toList();
      if (matchingPart.isNotEmpty) {
        for (var v = 0; v < matchingPart.length; v++) {
          PartData partObject = PartData.fromJson(matchingPart[v]);
          selectedParts.add(partObject);
        }
      }
    }
    return null;
  }

  Future<void> deleteUD104A(String childKey1, dynamic tenantConfigP) async {
    try {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

      final response = await http.delete(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/UD104As(${tenantConfigP['company']},${loadIDController.text},,,,,$childKey1,,,,)'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if (response.statusCode == 200) {
        widget.addLoadData(currentLoad);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateUD104A(
      Map<String, dynamic> UD104AData, dynamic tenantConfigP) async {
    try {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

      final response = await http.post(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Ice.BO.UD104Svc/UD104As'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(UD104AData));
      if (response.statusCode >=200 && response.statusCode<300) {
        debugPrint(response.body);
        setState(() {
          widget.addLoadData(currentLoad);
        });
      } else {
        throw new Exception(response.body.toString());
      }
    } on Exception catch (e) {
      throw new Exception(e);
    }
  }

  Future<void> updateInTransit(
      String partNum, String elementId, dynamic tenantConfigP) async {
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

    final response = await http.post(
        Uri.parse(
            '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Erp.BO.LotSelectUpdateSvc/LotSelectUpdates'),
        headers: {
          HttpHeaders.authorizationHeader: basicAuth,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({
          "Company": "${tenantConfigP['company']}",
          "PartNum": partNum,
          "LotNum": elementId,
          "ElementStatus_c": "In-Transit"
        }));
    if (response.statusCode == 200) {
      debugPrint(response.body);
    } else {
      debugPrint(response.body);
      debugPrint(response.statusCode.toString());
    }
  }



  Future<void> loadLoadAndData(dynamic tenantConfigP) async {
    await fetchLoadDataFromURL(loadIDController.text, tenantConfigP);
    offloadData = getLoadObjectFromJson(widget.historyLoadID);
    getElementObjectFromJson(widget.historyLoadID);
    getPartObjectFromJson(widget.historyLoadID);
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
    await getWarehouseList(tenantConfigP);
    await getBinsFromWarehouse(tenantConfigP, offloadData!.toWarehouse);
    await getResourceForTrucks(offloadData!.resourceId, tenantConfigP);
    await getResourceDetailsFromJson(offloadData!.resourceId);
    if (resourceDetails != null) {
      setState(() {
        capacityController.text = resourceDetails!.capacity ?? "";
        lengthController.text = resourceDetails!.length ?? "";
        widthController.text = resourceDetails!.width ?? "";
        heightController.text = resourceDetails!.height ?? "";
        volumeController.text = resourceDetails!.volume ?? "";
        loadedController.text = resourceDetails!.loaded ?? "";
      });
    }
  }

  Widget buildTruckDetailsFrom(bool isEditable) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (!isEditable)
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
            if (isEditable)
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
                              element['Character01'] == truckIdController.text)
                          .first['Character02'];
                      await getResourceForTrucks(resourceIdController.text,
                          context.read<tenantConfigProvider>().tenantConfig);
                    },
                  ),
                ),
              ),
            if (!isEditable)
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
            if (isEditable)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownSearch(
                    enabled: resourceValue?.isNotEmpty ?? false,
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
                        labelText: "Truck Attachment",
                      ),
                    ),
                    items: resourceValue
                            ?.map((value) => value['Character01'])
                            .toList() ??
                        [],
                    onChanged: (value) async {
                      setState(() {
                        resourceIdController.text = value.toString();
                        resourceId = resourceValue!
                            .where((element) => element['Character01'] == value)
                            .first['ChildKey1'];
                      });
                      getResourceDetailsFromJson(resourceIdController.text);
                      if (resourceDetails != null) {
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
            enabled: false,
            controller: plateNumberController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: "Plate Number"),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //add dropdown item list with label truck ID
            if (!isEditable)
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
            if (isEditable)
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
                        driverNumberController.text = fetchedDriverValue
                            .where((element) =>
                                element['Driver_Name'] == value.toString())
                            .first['Driver_Contact_c'];
                      });
                    },
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  enabled: false,
                  controller: driverNumberController,
                  decoration: const InputDecoration(
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
                )),
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

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      enabled: false,
                      initialValue: context
                          .watch<UserManagementProvider>()
                          .userManagement
                          ?.id
                          .toString(),
                      decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                          labelText: "Foreman ID"),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: context
                          .watch<UserManagementProvider>()
                          .userManagement
                          ?.firstName
                          .toString(),
                      enabled: false,
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
