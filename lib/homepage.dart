import 'package:GoCastTrack/elementInstallationPg.dart';
import 'package:GoCastTrack/stockOffloadingPage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'stockLoadingPage.dart';
import 'indexAppBar.dart';
import 'sideBarMenu.dart';
import 'package:provider/provider.dart';
import 'elementTracker.dart';
import 'load_model.dart';
import 'Providers/UserManagement.dart';
import 'package:fl_chart/fl_chart.dart';
import './ElementPieChart.dart';
import './Providers/ArchitectureProvider.dart';
import 'DIspatchSchedule.dart';

class HomePage extends StatefulWidget {
  final dynamic userManagement;
  final dynamic tenantConfig;
  const HomePage({super.key, required this.tenantConfig, this.userManagement});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  List<LoadData> loads = [];
  void addLoadData(LoadData load) {
    setState(() {
      for (int i = 0; i < loads.length; i++) {
        if (loads[i].loadID == load.loadID) {
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
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).shadowColor,
      appBar: const IndexAppBar(
        title: 'Home Page',
      ),

      drawer: width>600?null:SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
      body: Row(
        children: [
          width > 600
              ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
              child: SideBarMenu(context, loads, addLoadData, widget.tenantConfig))
              : const SizedBox(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Welcome, ${context.watch<UserManagementProvider>().userManagement?.firstName}  ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
            
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      color: Theme.of(context).indicatorColor,
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
                                        'ID: ${context.watch<UserManagementProvider>().userManagement?.id}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Department: Sales ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade800),
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
                                                            const EdgeInsets.all(
                                                                12.0),
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
                                                              const SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                'Name: ${context.watch<UserManagementProvider>().userManagement?.firstName} ${context.watch<UserManagementProvider>().userManagement?.lastName}',
                                                                style: const TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                'ID: ${context.watch<UserManagementProvider>().userManagement?.id}',
                                                                style: const TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                'tenant ID: ${context.watch<UserManagementProvider>().userManagement?.tenantId}',
                                                                style: const TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                'Email: ${context.watch<UserManagementProvider>().userManagement?.userFileEMailAddress}',
                                                                style: const TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                            ]))));
                                          });
                                    },
                                    icon: const Icon(
                                      Icons.info,
                                      color: Colors.white,
                                    )))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElementPieChart(),
            
                    width>600
                        ? const SizedBox()
                        :
            
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          Card(
                            elevation: 1,
                            color: Theme.of(context).indicatorColor,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ElementMaster(
                                      tenantConfig: widget.tenantConfig,
                                    ),
                                  ),
                                );
                              },
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Structure Tracker',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            elevation: 1,
                            color: Theme.of(context).indicatorColor,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StockLoading(
                                        initialTabIndex: 0,
                                        isUpdate: false,
                                        loadDataList: loads,
                                        addLoadData: addLoadData),
                                  ),
                                );
                              },
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Loading',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            elevation: 1,
                            color: Theme.of(context).indicatorColor,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StockOffloading(
                                        initialTabIndex: 0,
                                        tenantConfig: widget.tenantConfig),
                                  ),
                                );
                              },
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment_turned_in,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Offloading',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            elevation: 1,
                            color: Theme.of(context).indicatorColor,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StockLoading(
                                        initialTabIndex: 0,
                                        isUpdate: true,
                                        loadDataList: loads,
                                        addLoadData: addLoadData),
                                  ),
                                );
                              },
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment_late,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Edit Load',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            //
                            elevation: 1,
                            color: Theme.of(context).indicatorColor,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ElementInstallation(
                                      tenantConfig: widget.tenantConfig,
                                    ),
                                  ),
                                );
                              },
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.install_desktop_sharp,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    textAlign: TextAlign.center,
                                    'Structure Installation',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            //
                            elevation: 1,
                            color: Theme.of(context).indicatorColor,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DispatchSchedule()
                                  ),
                                );
                              },
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Dispatch schedule',
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
          ),
        ],
      ),
    );
  }
}
