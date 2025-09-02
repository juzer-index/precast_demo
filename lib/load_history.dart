import 'load_model.dart';
import 'package:flutter/material.dart';
import 'indexAppBar.dart';
import 'stockLoadingPage.dart';
class ElementDataSource extends ChangeNotifier {
  List<LoadData> loads = [];



}
class LoadHistory extends StatefulWidget {
   final List<LoadData> loads;
   final dynamic addLoad;
   final dynamic tenantConfig;
   const LoadHistory({super.key, required this.loads, required this.addLoad, required this.tenantConfig}) ;

  @override
  State<LoadHistory> createState() => _LoadHistoryState();

}
class LoadTableSource extends DataTableSource{
  List<LoadData> loads=[];
  final BuildContext context;
  dynamic addLoadData;
  dynamic tenantConfig;
  LoadTableSource({Key? key, required this.loads, required this.context,required this.addLoadData,required this.tenantConfig }) ;

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= loads.length) return null; // guard
    final l = loads[index];
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
                         addLoadData: addLoadData,
                         historyLoadID: l.loadID,
                    )));
                 },
             child: Text(l.loadID),

           ),
         ),
         DataCell(Text(l.projectId)),
          DataCell(Text(l.loadDate)),
          DataCell(Text(l.fromWarehouse)),
          DataCell(Text(l.toWarehouse)),
          DataCell(Text(l.toBin)),
          DataCell(Text(l.loadType)),
          DataCell(Text(l.loadCondition)),
          DataCell(Text(l.loadStatus)),
          DataCell(Text(l.truckId)),
          DataCell(Text(l.resourceId)),
          DataCell(Text(l.plateNumber)),
          DataCell(Text(l.driverName)),
          DataCell(Text(l.driverNumber)),
          DataCell(Text(l.resourceCapacity?.toString() ?? '')),
          DataCell(Text(l.resourceLoaded?.toString() ?? '')),
          DataCell(Text(l.resourceLength?.toString() ?? '')),
          DataCell(Text(l.resourceWidth?.toString() ?? '')),
          DataCell(Text(l.resourceHeight?.toString() ?? '')),
          DataCell(Text(l.resourceVolume?.toString() ?? '')),
          DataCell(Text(l.foremanId?.toString() ?? '')),



       ]
   );
  }
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => loads.length;
  @override
  int get selectedRowCount => 0; // no selection

}
class _LoadHistoryState extends State<LoadHistory> {

  _LoadHistoryState() ;
  final GlobalKey<PaginatedDataTableState> dataTableKey = GlobalKey();
  @override
  // TODO: implement widget
  Widget build(BuildContext context){
    final sessionLoads = widget.loads; // ensure we use the passed updated list
    final hasLoads = sessionLoads.isNotEmpty;
    return Scaffold(
      backgroundColor: Theme.of(context).shadowColor,
      appBar: const IndexAppBar(title: 'Load History'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: hasLoads
            ? Column(
              children: [
                Card(
                    color: Theme.of(context).indicatorColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PaginatedDataTable(
                        key: dataTableKey,
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
                        ],
                        source: LoadTableSource(
                          loads: sessionLoads.reversed.toList(),
                          context: context,
                          addLoadData: widget.addLoad,
                          tenantConfig: widget.tenantConfig,
                        ),
                      ),
                    ),
                  ),
              ],
            )
            : Center(
                child: Text(
                  'No loads created in this session.',
                  style: TextStyle(
                      fontSize: 16, color: Theme.of(context).canvasColor),
                ),
              ),
      ),
    );
  }
}