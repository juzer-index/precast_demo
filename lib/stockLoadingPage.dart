import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precast_demo/elementTable.dart';
import 'package:precast_demo/partTable.dart';
import 'package:precast_demo/truckDetails.dart';
import 'package:precast_demo/elementSearchForm.dart';
import 'package:precast_demo/partSearchForm.dart';
import 'dart:convert';
import 'part_model.dart';
import 'element_model.dart';
import 'truck_model.dart';
import 'truckresource_model.dart';

class StockLoading extends StatefulWidget {
  final int initialTabIndex;
  StockLoading({super.key, required this.initialTabIndex});


  @override
  State<StockLoading> createState() => _StockLoadingState();
}

class _StockLoadingState extends State<StockLoading> with SingleTickerProviderStateMixin{

  late TabController _tabController;
  TextEditingController dateController = TextEditingController();
  TextEditingController loadTimeController = TextEditingController();
  TextEditingController truckController = TextEditingController();
  TextEditingController loadIDController = TextEditingController();
  DateTime? _selectedDate;
  String loadTypeValue = '';
  String loadConditionValue = '';
  String inputTypeValue = 'Manual';
  final _formKey = GlobalKey<FormState>();
  TextEditingController projectIdController = TextEditingController();
  TextEditingController deliverySiteController = TextEditingController();
  List<ElementData> selectedElements = [];
  List<PartData> selectedParts = [];
  List<TruckDetails> truckDetails = [];

  void updatePartInformation(List<PartData> selectedPartsFromForm){
    setState(() {
      selectedParts = selectedPartsFromForm;
    });
  }

  void updateElementInformation(List<ElementData> selectedElementsFromForm){
    setState(() {
      selectedElements = selectedElementsFromForm;
    });
  }


  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this); // Change 3 to the number of tabs
    _tabController.index = widget.initialTabIndex;
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  const Text(
                      'Stock Loading', style: TextStyle(color: Colors.white)),
                  ClipOval(
                    child: Image.network(
                      'https://media.licdn.com/dms/image/D4D03AQFpmZgzpRLrhg/profile-displayphoto-shrink_200_200/0/1692612499698?e=1706140800&v=beta&t=WX4ydCp7VUP7AhXZOIDHIX3D3Ts5KfR-1YJJU6FmalI',
                      height: 35,
                      width: 35,
                    ),
                  )
                ],
              ),
            ),
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
          body: Padding(
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: TextFormField(
                                enabled: false,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Load ID"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Project ID"),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Project 1',
                                    child: Text('Project 1'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Project 2',
                                    child: Text('Project 2'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Project 3',
                                    child: Text('Project 3'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    //value handler here
                                    projectIdController.text = value.toString();
                                  });
                                },
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
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
                                            _selectedDate = date;
                                            dateController.text =
                                            "${date.day}/${date.month}/${date
                                                .year}";
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
                                        onTap: () async {
                                          final TimeOfDay? time = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );
                                          if (time != null) {
                                            setState(() {
                                              loadTimeController.text =
                                              "${loadTimeController.text} ${time
                                                  .hour}:${time.minute}";
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
                                      child: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "From"),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Site 1',
                                            child: Text('Site 1'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Site 2',
                                            child: Text('Site 2'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Site 3',
                                            child: Text('Site 3'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            //value handler here
                                            deliverySiteController.text =
                                                value.toString();
                                          });
                                        },
                                      )),
                                ),
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "To"),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Site 1',
                                            child: Text('Site 1'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Site 2',
                                            child: Text('Site 2'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Site 3',
                                            child: Text('Site 3'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            //value handler here
                                            deliverySiteController.text =
                                                value.toString();
                                          });
                                        },
                                      )),
                                ),
                              ],
                            ),
                            if(loadConditionValue == 'External')
                              Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          // controller: poNumberController,
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
                                          // controller: poLineController,
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
                            TruckDetailsForm(isEdit: true,),
                            const SizedBox(height: 20),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _tabController.animateTo(1);
                                  });
                                },
                                child: const Text(
                                  'Next',
                                  style: TextStyle(color: Colors.green),
                                )),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //Tab 2 Content
                  SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
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
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ExpansionTile(
                                  title: const Text('Element Parts'),
                                  children: [
                                    ElementSearchForm(onElementsSelected: updateElementInformation),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20,),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ExpansionTile(
                                  title: const Text('Non Element Parts'),
                                  children: [
                                    PartSearchForm(onPartsSelected: updatePartInformation,),
                                  ],
                                ),
                              ),
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
                                    initialValue: loadTimeController.text,
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
                                      initialValue: deliverySiteController.text,
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
                                      initialValue: deliverySiteController.text,
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
                          TruckDetailsForm(isEdit: false,),
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
                              onPressed: () {
                                showDialog(context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Success'),
                                        content: const Text(
                                            'Stock Loading details saved successfully, LoadID: ID-L1'),
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
                              },
                              child: const Text(
                                'Save',
                                style: TextStyle(color: Colors.green),
                              )),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ));
  }
}


