import 'package:flutter/material.dart';
import 'package:IIT_precast_app/stockLoadingPage.dart';
import 'package:IIT_precast_app/indexAppBar.dart';
import 'package:IIT_precast_app/sideBarMenu.dart';
import 'package:IIT_precast_app/stockOffloadingPage.dart';
import 'elementMaster.dart';
import 'load_model.dart';

class HomePage extends StatefulWidget {
  dynamic userManagement;
   HomePage({super.key, required this.userManagement}) ;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }
  List<LoadData> loads = [];
  void AddLoadData(LoadData load) {
    setState(() {
      for(int i=0;i<loads.length;i++)
        {
          if(loads[i].loadID==load.loadID)
            {
              loads.removeAt(i);
              break;
            }
        }
    });
    setState(() {
      loads.add(load);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IndexAppBar(
        title: 'Home Page',
      ),
      drawer: SideBarMenu(context, loads, AddLoadData),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Welcome, ${widget.userManagement['firstName']}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade400,),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.12,
                child: Card(
                  elevation: 1,
                  color: Colors.lightBlue.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // ClipRRect(
                            //   borderRadius: BorderRadius.circular(10.0),
                            //   child: Image.network(
                            //     'https://media.licdn.com/dms/image/D4D03AQFpmZgzpRLrhg/profile-displayphoto-shrink_800_800/0/1692612499698?e=1711584000&v=beta&t=Ho-Wta1Gpc-aiWZMJrsni_83CG16TQeq_gtbIJBM7aI',
                            //     height: 40,
                            //     width: 40,
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                  'ID: ${widget.userManagement['id']}',
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Department: Sales ',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey.shade800),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                                onPressed: () {
                                  //display a popup with rounded borders and half screen size
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)),
                                            child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(12.0),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Profile Information',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(height: 10),
                                                          Text(
                                                            'Name: ${widget.userManagement['firstName']} ${widget.userManagement['lastName']}',
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(height: 10),
                                                          Text(
                                                            'ID: ${widget.userManagement['id']}',
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(height: 10),
                                                          Text(
                                                            'tenant ID: ${widget.userManagement['tenantId']}',
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ),
                                                          const SizedBox(height: 10),
                                                          Text(
                                                            'Email: ${widget.userManagement['userFile_EMailAddress']}',
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ),
                                                          const SizedBox(height: 10),
                                                        ]
                                                    )
                                                )
                                            )
                                        );
                                      }
                                      );
                                },
                                icon: Icon(
                                  Icons.info,
                                  color: Colors.blueGrey.shade800,
                                )))
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    Card(
                      elevation: 1,
                      color: Colors.lightBlue.shade100,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ElementMaster(),
                            ),
                          );
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.settings,
                              size: 50,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Element Master',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      color: Colors.lightBlue.shade100,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockLoading(initialTabIndex: 0, isUpdate: false,loadDataList: loads,addLoadData: AddLoadData,userManagement: widget.userManagement,),
                            ),
                          );
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment,
                              size: 50,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Stock Loading',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      color: Colors.lightBlue.shade100,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StockOffloading(initialTabIndex: 0,),
                            ),
                          );
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_turned_in,
                              size: 50,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Stock Offloading',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      color: Colors.lightBlue.shade100,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StockLoading(initialTabIndex: 0, isUpdate: true, loadDataList: loads, addLoadData: AddLoadData,),
                            ),
                          );
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_late,
                              size: 50,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Edit Stock Load',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
