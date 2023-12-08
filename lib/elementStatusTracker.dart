import 'package:flutter/material.dart';
import 'package:precast_demo/addTruckDetails.dart';

class ProjectDetails extends StatefulWidget {
  final int initialTabIndex;
  const ProjectDetails({super.key, required this.initialTabIndex});


  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> with SingleTickerProviderStateMixin{

  late TabController _tabController;
  TextEditingController dateController = TextEditingController();
  late DateTime _selectedDate;

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
        backgroundColor: Theme.of(context).primaryColor,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              const Text('Project Details', style: TextStyle(color: Colors.white)),
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
              text: 'Project Details',
            ),
            Tab(
              text: 'Element Details',
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
                //First Tab widget
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                            labelText: "Project ID"),
                        items: const [
                          DropdownMenuItem(
                            child: Text('Project 1'),
                            value: 'Project 1',
                          ),
                          DropdownMenuItem(
                            child: Text('Project 2'),
                            value: 'Project 2',
                          ),
                          DropdownMenuItem(
                            child: Text('Project 3'),
                            value: 'Project 3',
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            //value handler here
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
                                    dateController.text = "${date.day}/${date.month}/${date.year}";
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Date"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                  labelText: "Delivery Site",
                              ),
                              items: const [
                                DropdownMenuItem(
                                  child: Text('Site 1'),
                                  value: 'Site 1',
                                ),
                                DropdownMenuItem(
                                  child: Text('Site 2'),
                                  value: 'Site 2',
                                ),
                                DropdownMenuItem(
                                  child: Text('Site 3'),
                                  value: 'Site 3',
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  //value handler here
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddTruckDetails()),
                              );
                            },
                            child: const Text('Add Truck Details')),
                        ElevatedButton(
                            onPressed: () {},
                            child: const Text(
                              'Next',
                              style: TextStyle(color: Colors.green),
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              //Second Tab widget
              const SizedBox(

              ),
              //Third Tab Widget
              SizedBox(
                child: Card(
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  color: Colors.lightBlue.shade100,
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Project ID')),
                        DataColumn(label: Text('Delivery Date')),
                        DataColumn(label: Text('Delivery Site')),
                        DataColumn(label: Text('Truck Details')),
                      ],
                      rows: [],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ));
  }
}
