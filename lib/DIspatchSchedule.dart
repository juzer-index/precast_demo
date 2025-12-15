import 'package:flutter/material.dart';
import 'Widgets/IndexTable.dart';
import './Widgets/DropDown.dart';
import './utils/APIProviderV2.dart';
import '../Models/LoadLine.dart';
import 'package:provider/provider.dart';
import 'Providers/tenantConfig.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import './stockLoadingPage.dart';
import './element_model.dart';
import 'Widgets/SalesOrderSearch.dart';
import 'Models/NotFoundException.dart';
import './Widgets/SearchBar.dart';
import 'Widgets/SalesOrderPop.dart';
import 'dart:math';
import 'load_model.dart'; // ADDED
import 'sideBarMenu.dart';
import 'load_model.dart';
import 'indexAppBar.dart';

class DispatchSchedule extends StatefulWidget {
  // ADDED: session loads & callback
  final List<LoadData> sessionLoads;
  final Function(LoadData) addLoadData;
  DispatchSchedule({
    Key? key,
    required this.sessionLoads,
    required this.addLoadData,
  }) : super(key: key);
  dynamic tenantConfig;


  @override
  _DispatchScheduleState createState() => _DispatchScheduleState();
}
class _DispatchScheduleState extends State<DispatchSchedule> {
  final TextEditingController warehouseController = TextEditingController();
  List<LoadLine> StructureList = [];
  List<dynamic> dynamicStructures = [];
  bool isLoading = false; // Track loading state
  bool hasError = false;
  int totalRecords = 0;
 int totalPages = 0; // Track total pages for pagination
  final TextEditingController _salesOrderController = TextEditingController();
  // Track error state
  int page =0;
  addUniqueElements(List<dynamic> newElements) {
    for (var element in newElements) {
      if (!dynamicStructures.any((x) => x['PartLot_PartNum'] == element['PartLot_PartNum'] &&
          x['PartLot_LotNum'] == element['PartLot_LotNum'])) {
        dynamicStructures.add(element);
      }
    }
  }
  Future<void> getData(String SalesOrder,bool nextPage) async  {
    try {
      isLoading = true; // Set loading to true when fetching data
      page=0;
      final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
      List<dynamic> data = await APIV2Helper.getPaginatedResults(
        hasVars: true,
          '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
              '/v1/BaqSvc/IIT_DispatchSchedule/?OrderNum=${_salesOrderController.text}', page, 10, {
        'username': tenantConfig['userID'],
        'password': tenantConfig['password'],

      });
      if (data.isEmpty) {
        setState(() {
          isLoading = false; // Set loading to false if no data is found
        });
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text("Error"),
            content: const Text("No data found"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),],
          ),
        );
        return;
      }else {
        if(nextPage) {
          setState(() {
            dynamicStructures += data;
            isLoading = false;
            page++; // Increment page for pagination
         // Calculate total pages
            // Set loading to false once data is fetched
          });
        }else{
          setState(() {
            dynamicStructures = data;
            isLoading = false;
            page=1; // Increment page for pagination
            totalRecords = dynamicStructures[0]['Calculated_total_count'];
            totalPages = (totalRecords / 10).ceil();
          });
        }
      }
    } catch (e) {
      setState(() {
        hasError = true; // Track error
        isLoading = false;
      });
    }
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
  void initState() {
    super.initState();
     // Fetch data once when widget is created
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;

    void onSalesOrderSelected(dynamic salesOrder) {
      String value = salesOrder['OrderNum'].toString();

      setState(() {
        _salesOrderController.text = value;
      });
      getData(value,false);
    }
    return Scaffold(
      drawer: width > 600
          ? null
          : SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle floating action button press
          List<dynamic> selectedItems = dynamicStructures.where((x) => x['checked'] == true).toList();
          if (selectedItems.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StockLoading(
                  initialTabIndex: 0,
                  isUpdate: false,
                  LinesOriented: true,
                  passedElements: selectedItems.map((x) => ElementData(
                    // ...existing mapping...
                    Company: context.read<tenantConfigProvider>().tenantConfig['company'].toString(),
                    partId: x['PartLot_PartNum'].toString(),
                    elementId: x['PartLot_LotNum'].toString(),
                    elementDesc: x['PartLot_PartLotDescription'].toString(),
                    erectionSeq: int.parse(x['PartLot_ErectionSequence_c'].toString()),
                    erectionDate: x['PartLot_ErectionPlannedDate_c'].toString(),
                    weight: double.parse(x['PartLot_Ton_c'].toString()),
                    area: double.parse(x['PartLot_M2_c'].toString()),
                    volume: double.parse(x['PartLot_M3_c'].toString()),
                    UOMClass: x['Part_UOMClassID'].toString(),
                    UOM: x['Part_SalesUM'].toString(),
                    Revision: x['OrderDtl_RevisionNum'].toString(),
                    quantity: 1,
                    selectedQty: 1,
                    ChildKey1: x['ChildKey1'].toString(),
                    fromBin: x['PartLot_BinNum_c'].toString(),
                    Warehouse: x['PartLot_Warehouse_c'].toString(),
                    SO: int.parse(x['OrderDtl_OrderNum'].toString() ?? '0'),
                  )).toList(),
                  custNum: int.parse(selectedItems[0]['OrderHed_CustNum'].toString()),
                  // ADDED: pass session loads & callback
                  loadDataList: widget.sessionLoads,
                  addLoadData: widget.addLoadData,
                ),
              ),
            );
          } else {
            // Show message to select at least one item
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select at least one item')),
            );
          }
        },
         label: const Text('Create Load'),

      ),
      appBar: IndexAppBar(
        title: ('Dispatch Schedule'),
      ),
      body:
           Container(
        color: Theme.of(context).shadowColor,
        child: Row(
          children: [
            width > 600
                ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: SideBarMenu(context, loads, addLoadData, widget.tenantConfig))
                : const SizedBox(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(

            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                  child: SalesOrderSearch(isUpdate: false,showShipTo: false,
                  onSalesOrderSelected: onSalesOrderSelected,
                  ),

                                     )

                      ],
                    ),
                    GestureDetector(
                      child: SizedBox(
                        height: height * 0.9,

                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SingleChildScrollView(
                               clipBehavior: Clip.hardEdge,
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Center(
                                        child: Container(

                                          decoration: BoxDecoration(
                                            color: Theme.of(context).indicatorColor,
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child:isLoading?SizedBox(
                                              height: height*0.6,
                                              width: width*0.95,
                                              child: Center(child: CircularProgressIndicator())) : _salesOrderController.text.isEmpty? Center(
                                            child: SizedBox(
                                                height: height*0.6,
                                                width: width*0.95,
                                                child: Center(child: Text("Please select a sales order"))))
                                              :Container(

                                      child: Column(
                                        children: [
                                          IndexTable(
                                            data: dynamicStructures.length>0?dynamicStructures.map((x) => DataRow(
                                                color: x['Calculated_Status'].toString() == "Shipped" ? const MaterialStatePropertyAll<Color>(Colors.deepOrange) : null,
                                                cells: [
                                              DataCell(Checkbox(

                                                value: x['checked'] ?? false,
                                                onChanged: (value) {
                                                  setState(() {
                                                    x['checked'] = value;
                                                  });
                                                  // Handle checkbox change
                                                },
                                              )),
                                              DataCell(Text(x['PartLot_PartNum'].toString())),
                                              DataCell(Text(x["PartLot_LotNum"].toString())),
                                              DataCell(Text(x['OrderDtl_RevisionNum'].toString())),
                                              DataCell(Text(x['OrderDtl_RequestDate'].toString())),
                                              DataCell(Text(x['OrderDtl_OrderNum'].toString())),
                                              DataCell(Text(x['Customer_Name'].toString())),
                                              DataCell(Text(x['Calculated_Status'].toString())),
                                              DataCell(Text(x['PartLot_ErectionSequence_c'].toString())),
                                            ])).toList().sublist((page-1)*10,min((page*10),

                                                (dynamicStructures.length)) ):[],
                                            columns: [
                                              DataColumn(label: Text('Checked')),
                                              DataColumn(label: Text('Structure ID')),
                                              DataColumn(label: Text('Structure Number')),
                                              DataColumn(label: Text('Revision')),
                                              DataColumn(label: Text('Ship By Date')),
                                              DataColumn(label: Text('Sales Order')),
                                              DataColumn(label: Text('Customer Name')),
                                              DataColumn(label: Text('Status')),
                                              DataColumn(label: Text('Erection Sequence')),
                                            ],

                                          ),
                                             ],
                                      ),
                                                                          ),
                                                                        ),
                                                                      ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [ Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(

                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(onPressed:(){
                                          if(page>1){
                                            setState(() {
                                              page--;
                                            });
                                          }


                                        } , icon: const Icon(Icons.arrow_back_ios_new)),
                                        Text(('Page $page of $totalPages').toString()),
                                        page<totalPages?IconButton(onPressed:()async{
                                          if(page*10<dynamicStructures.length){
                                            setState(() {
                                              page++;
                                            });
                                          }
                                          else{
                                            setState(() {
                                              isLoading=true;
                                            });


                                            await getData(_salesOrderController.text,true);


                                          }
                                        } , icon: const Icon(Icons.arrow_forward_ios)):IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey,)


                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                              ),
                            ],
                          ),
                                                ),
                                              ],
                                            ),
                        ),
                ),
              ),

                  ],
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }
}
