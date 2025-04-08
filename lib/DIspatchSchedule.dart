import 'package:flutter/material.dart';
import 'Widgets/IndexTable.dart';
class DispatchSchedule extends StatefulWidget {
  const DispatchSchedule({Key? key}) : super(key: key);

  @override
  _DispatchScheduleState createState() => _DispatchScheduleState();
}
class _DispatchScheduleState extends State<DispatchSchedule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Schedule'),
      ),
      body: Container(
        color:Theme.of(context).shadowColor,
        child: Column(

          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Sales Order',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
            GestureDetector(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        children: [

                          IndexTable(
                            data: [
                              DataRow(cells: [
                                DataCell(Text('1')),
                                DataCell(Text('1')),
                                DataCell(Text('2021-09-01')),
                                DataCell(Text('Warehouse 1')),
                                DataCell(Text('Warehouse 2')),
                                DataCell(Text('Bin 1')),
                                DataCell(Text('Dispatch Type 1')),
                                DataCell(Text('Dispatch Condition 1')),
                                DataCell(Text('Dispatch Status 1')),
                              ]),

                            ],
                            columns: [
                              DataColumn(label: Text('Dispatch ID')),
                              DataColumn(label: Text('Project ID')),
                              DataColumn(label: Text('Dispatch Date')),
                              DataColumn(label: Text('From Warehouse')),
                              DataColumn(label: Text('To Warehouse')),
                              DataColumn(label: Text('To Bin')),
                              DataColumn(label: Text('Dispatch Type')),
                              DataColumn(label: Text('Dispatch Condition')),
                              DataColumn(label: Text('Dispatch Status')),
                            ],
                            onRowTap: (index) {
                              print('Row $index tapped');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}