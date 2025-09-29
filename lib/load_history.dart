import 'load_model.dart';
import 'package:flutter/material.dart';
import 'indexAppBar.dart';
import 'stockLoadingPage.dart';
import 'sideBarMenu.dart';
import 'package:provider/provider.dart';
import 'load_model.dart';
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
                         historyLoadID: loads[index].loadID,
                    )));
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
          DataCell(Text(loads[index].resourceCapacity.toString() ?? '')),
          DataCell(Text(loads[index].resourceLoaded.toString() ?? '')),
          DataCell(Text(loads[index].resourceLength.toString() ?? '')),
          DataCell(Text(loads[index].resourceWidth.toString() ?? '')),
          DataCell(Text(loads[index].resourceHeight.toString() ?? '')),
          DataCell(Text(loads[index].resourceVolume.toString() ?? '')),
          DataCell(Text(loads[index].foremanId.toString() ?? '')),



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

  _LoadHistoryState() ;
  final GlobalKey<PaginatedDataTableState> dataTableKey = GlobalKey();
  @override
  // TODO: implement widget
  Widget build(BuildContext context){
    final sessionLoads = widget.loads; // ensure we use the passed updated list
    final hasLoads = sessionLoads.isNotEmpty;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).shadowColor,
      appBar: const IndexAppBar(title: 'Load History'),
        drawer: width>600?null:SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
        body: Row(
            children: [
        width > 600
        ? SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        child: SideBarMenu(context, loads, addLoadData, widget.tenantConfig))
        : const SizedBox(),
        Expanded(
        child: Padding(
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
    ),
      ],
    ),
    );
  }
}