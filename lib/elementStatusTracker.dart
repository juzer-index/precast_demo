import 'package:flutter/material.dart';
import 'package:precast_demo/indexAppBar.dart';
import 'package:precast_demo/elementStatusViewer.dart';
import 'package:precast_demo/elementMaster.dart';
import 'package:precast_demo/homepage.dart';
import 'themeData.dart';

class ElementStatusTracker extends StatefulWidget {
  final int initialTabIndex;
  const ElementStatusTracker({super.key, required this.initialTabIndex});


  @override
  State<ElementStatusTracker> createState() => _ElementStatusTrackerState();
}

class _ElementStatusTrackerState extends State<ElementStatusTracker> with SingleTickerProviderStateMixin{

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Change 3 to the number of tabs
    _tabController.index = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              const Text('Element Status Tracker', style: const TextStyle(color: Colors.white)),
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
        bottom: const TabBar(
          tabs: [
            Tab(

              text: 'Tab 1',
            ),
            Tab(
              text: 'Tab 2',
            ),
            Tab(
              text: 'Tab 3',
            ),
          ],
        ),
      ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBarView(
              controller: _tabController, children: [
                //First Tab widget
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: 'Project ID',
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black),
                        underline: Container(
                          height: 2,
                          color: Colors.blue,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            // dropdownValue = newValue!;
                          });
                        },
                        items: <String>['Project ID', 'Element ID', 'Part Number', 'Element Type']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              onTap: () {
                                showDialog(context: context, builder: (BuildContext context){
                                  return DatePickerDialog(
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2018),
                                    lastDate: DateTime(2030),
                                  );
                                });
                              },
                              initialValue: DateTime.now().toString(),
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.calendar_today, color: Colors.blue,),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  labelText: "Date"),
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
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  labelText: "Delivery Site"),

                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                          suffixIcon: const Icon(
                            Icons.car_crash,
                            color: Colors.blue,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: "Truck Details"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(onPressed: () {}, child: Text('Add'))
                  ],
                ),
              ),
              //Second Tab widget
              const SizedBox(

              ),
              //Third Tab Widget
              const SizedBox(),
            ]),
          ),
        ));
  }
}
