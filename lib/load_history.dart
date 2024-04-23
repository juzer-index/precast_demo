import 'dart:convert';

import 'dart:io';
import 'dart:math';
import 'package:IIT_precast_app/load_model.dart';
import 'package:flutter/material.dart';
import 'package:IIT_precast_app/indexAppBar.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'stockLoadingPage.dart';
class ElementDataSource extends ChangeNotifier {
  List<LoadData> loads = [];



}
class LoadHistory extends StatefulWidget {
   List<LoadData> loads;
   dynamic AddLoad;
   dynamic tenantConfig;
   LoadHistory({Key? key, required this.loads, required this.AddLoad, required this.tenantConfig}) ;

  @override
  State<LoadHistory> createState() => _LoadHistoryState();

}
class loadTableSource extends DataTableSource{
  List<LoadData> loads=[];
  final BuildContext context;
  dynamic AddLoadData;
  dynamic tenantConfig;
  loadTableSource({Key? key, required this.loads, required this.context,required this.AddLoadData,required this.tenantConfig }) ;

  @override
  DataRow? getRow(int index) {
   return DataRow.byIndex(
       index: index,
       cells: [
         DataCell(
           GestureDetector(
             onTap: ()
                 {
                   Navigator.push(context, MaterialPageRoute(builder: (context) =>
                       StockLoading(initialTabIndex: 0,
                         isUpdate: true,
                         loadDataList: loads,
                         addLoadData: this.AddLoadData,
                         historyLoadID: loads[index].loadID,
                       tenantConfig:tenantConfig ,)));
                 },
             child: Text(loads[index].loadID),

           ),
         ),
         DataCell(Text(loads[index].projectId)),
          DataCell(Text(loads[index].loadDate)),
          DataCell(Text(loads[index].fromWarehouse)),
          DataCell(Text(loads[index].toWarehouse)),
          DataCell(Text(loads[index].toBin)),
          DataCell(Text(loads[index].loadType)),
          DataCell(Text(loads[index].loadCondition)),
          DataCell(Text(loads[index].loadStatus)),
          DataCell(Text(loads[index].truckId)),
          DataCell(Text(loads[index].resourceId)),
          DataCell(Text(loads[index].plateNumber)),
          DataCell(Text(loads[index].driverName)),
          DataCell(Text(loads[index].driverNumber)),
          DataCell(Text(loads[index].resourceCapacity.toString())),
          DataCell(Text(loads[index].resourceLoaded.toString())),
          DataCell(Text(loads[index].resourceLength.toString())),
          DataCell(Text(loads[index].resourceWidth.toString())),
          DataCell(Text(loads[index].resourceHeight.toString())),
          DataCell(Text(loads[index].resourceVolume.toString())),
          DataCell(Text(loads[index].foremanId.toString())),
          DataCell(Text(loads[index].foremanName)),
          DataCell(Text(loads[index].comments)),

       ]
   );
  }
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => loads.length;
  @override
  int get selectedRowCount => loads.length;

}
class _LoadHistoryState extends State<LoadHistory> {

  _LoadHistoryState({Key? key }) ;
  final GlobalKey<PaginatedDataTableState> dataTablekey = GlobalKey();
  @override
  // TODO: implement widget
  Widget build(BuildContext context){
    return Scaffold(
      appBar: IndexAppBar(title: 'Load History'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              child: Card(
                  color: Colors.lightBlue.shade100,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),

                      child: PaginatedDataTable(
                        key : dataTablekey,


                        columnSpacing: 30,
                        columns: const [
                          DataColumn(label: Text('Load ID')),
                          DataColumn(label: Text('Project ID')),
                          DataColumn(label: Text('Load Date')),
                          DataColumn(label: Text('From Warehouse')),
                          DataColumn(label: Text('To Warehouse')),
                          DataColumn(label: Text('To Bin')),
                          DataColumn(label: Text('Load Type')),
                          DataColumn(label: Text('Load Condition')),
                          DataColumn(label: Text('Load Status')),
                          DataColumn(label: Text('Truck ID')),
                          DataColumn(label: Text('Resource ID')),
                          DataColumn(label: Text('Plate Number')),
                          DataColumn(label: Text('Driver Name')),
                          DataColumn(label: Text('Driver Number')),
                          DataColumn(label: Text('Resource Capacity')),
                          DataColumn(label: Text('Resource Loaded')),
                          DataColumn(label: Text('Resource Length')),
                          DataColumn(label: Text('Resource Width')),
                          DataColumn(label: Text('Resource Height')),
                          DataColumn(label: Text('Resource Volume')),
                          DataColumn(label: Text('Foreman ID')),
                          DataColumn(label: Text('Foreman Name')),
                          DataColumn(label: Text('Comments')),
                        ],
                       source:loadTableSource(loads:widget.loads.reversed.toList(), context: context, AddLoadData: widget.AddLoad ,tenantConfig:widget.tenantConfig),

                      )
                  )
              ),
            ),
          ],
        ),

      ),
    );
  }
}