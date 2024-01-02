import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockOffloading extends StatefulWidget {
  final int initialTabIndex;

  const StockOffloading({super.key, required this.initialTabIndex});

  @override
  State<StockOffloading> createState() => _StockOffloadingState();
}

class _StockOffloadingState extends State<StockOffloading>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String loadTypeValue = '';
  String loadConditionValue = '';
  String inputTypeValue = 'Manual';

  @override
  void initState() {
    _tabController =
        TabController(length: 3, vsync: this); // Change 3 to the number of tabs
    _tabController.index = widget.initialTabIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              const Text('Stock Loading',
                  style: TextStyle(color: Colors.white)),
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
              text: 'Header',
            ),
            Tab(
              text: 'Details',
            ),
            Tab(
              text: 'Review',
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
                child: Center(
                  child: Column(children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Load Type',
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
                                    loadTypeValue = value.toString();
                                  });
                                },
                              ),
                              RadioListTile(
                                title: const Text('Delivery Trip'),
                                value: 'Return',
                                groupValue: loadTypeValue,
                                onChanged: (value) {
                                  setState(() {
                                    loadTypeValue = value.toString();
                                  });
                                },
                              ),
                            ]),
                          ),
                          Expanded(
                            child: Column(children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Load Condition',
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
                                    loadConditionValue = value.toString();
                                  });
                                },
                              ),
                              RadioListTile(
                                title: const Text('Internal'),
                                value: 'Internal',
                                groupValue: loadConditionValue,
                                onChanged: (value) {
                                  setState(() {
                                    loadConditionValue = value.toString();
                                  });
                                },
                              ),
                              RadioListTile(
                                title: const Text('Ex-Factory'),
                                value: 'Ex-Factory',
                                groupValue: loadConditionValue,
                                onChanged: (value) {
                                  setState(() {
                                    loadConditionValue = value.toString();
                                  });
                                },
                              )
                            ]),
                          ),
                        ]),
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
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          label: Text('Load ID'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          label: Text('Load Date'),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            //Tab 2 Content
            Center(
              child: Text('Details'),
            ),
            //Tab 3 Content
            Center(
              child: Text('Review'),
            ),
          ],
        ),
      ),
    );
  }
}
