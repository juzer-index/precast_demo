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
class DispatchSchedule extends StatefulWidget {
  const DispatchSchedule({Key? key}) : super(key: key);

  @override
  _DispatchScheduleState createState() => _DispatchScheduleState();
}
class _DispatchScheduleState extends State<DispatchSchedule> {
  final TextEditingController warehouseController = TextEditingController();
  List<LoadLine> StructureList = [];
  List<dynamic> dynamicStructures = [];
  bool isLoading = false; // Track loading state
  bool hasError = false;
  final TextEditingController _salesOrderController = TextEditingController();
  // Track error state
  int page = 1;
  Future<void> getData(String SalesOrder) async  {
    try {
      isLoading = true; // Set loading to true when fetching data
      final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
      List<dynamic> data = await APIV2Helper.getPaginatedResults(
        hasVars: true,
          '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
              '/v2/odata/${tenantConfig['company']}/BaqSvc/IIT_DispatchSchedule/Data?OrderNum=${_salesOrderController.text}', page, 10, {
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
        setState(() {
          dynamicStructures += data;
          isLoading = false;
          page++; // Increment page for pagination
          // Set loading to false once data is fetched
        });
      }
    } catch (e) {
      setState(() {
        hasError = true; // Track error
        isLoading = false;
      });
    }
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
      getData(value);
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle floating action button press
          List<dynamic> selectedItems = dynamicStructures.where((x) => x['checked'] == true).toList();
          if (selectedItems.isNotEmpty) {
            // Perform action with selected items
            Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context)=>StockLoading(initialTabIndex: 0, isUpdate: false, LinesOriented: true,
            passedElements: selectedItems.map((x) => ElementData(
              Company: context.read<tenantConfigProvider>().tenantConfig['company'].toString(),
             partId: x['PartLot_PartNum'].toString(),
             elementId: x['PartLot_LotNum'].toString(),
              elementDesc: x['PartLot_PartLotDescription'].toString(),
              erectionSeq: int.parse(x['PartLot_ErectionSequence_c'].toString()),
              erectionDate: x['PartLot_ErectionPlannedDate_c'].toString(),
              weight: double.parse(x['PartLot_Ton_c'].toString()),
              area:double.parse(x['PartLot_M2_c'].toString()),
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
            ))
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
      appBar: AppBar(
        title: const Text('Dispatch Schedule'),
      ),
      body:
           Container(
        color: Theme.of(context).shadowColor,
        child: SingleChildScrollView(
          child: Column(

            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                  child: IndexSearchBar(
                    entity: "S.O",
                    onSearch:  (String term) async {
                      setState(() {
                        isLoading = true;
                        _salesOrderController.text= term;
                      });
                      try {
                        var data = await APIV2Helper.getResults(
                            '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
                                '/v2/odata/${tenantConfig['company']}/BaqSvc/IIT_DispatchSchedule/Data?OrderNum=${term}',

                            {"username": context
                                .read<tenantConfigProvider>()
                                .tenantConfig['userID'],
                              "password": context
                                  .read<tenantConfigProvider>()
                                  .tenantConfig['password']}
                            , entity: "Sales Order");
                        if(data.isNotEmpty){
                          setState(() {
                            dynamicStructures = data;
                            isLoading = false;
                          });
                        }else{
                          setState(() {
                            isLoading = false;
                          });
                          showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                            title: const Text("Error"),
                            content: const Text("No data found"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),],
                          ),);
                        }



                      }on NotFoundException catch(e){
                        setState(() {
                          isLoading = false;
                        });
                        showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                          title: Text("Error"),
                          content: Text(e.toString()),
                        ));
                      };
                    },
                    advanceSearch: true,
                    value: _salesOrderController.text,
                    onAdvanceSearch: (){
                      showDialog(context: context, builder: (BuildContext context)=>SalesOrderPopUP( onSalesOrderSelected: onSalesOrderSelected,)

                      );
                    },

                  ),
                                     )

                ],
              ),
              GestureDetector(
                child: SizedBox(
                  height: height * 0.9,
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        clipBehavior: Clip.hardEdge,
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
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
                                            data: dynamicStructures.map((x) => DataRow(
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
                                            ])).toList().sublist((page-1)*10,min((page*10), dynamicStructures.length) ),
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
                                            onRowTap: (index) {

                                            },
                                          ),
                                             ],
                                      ),
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
                                      Text(page.toString()),
                                      IconButton(onPressed:()async{
                                        if(page*10<dynamicStructures.length){
                                          setState(() {
                                            page++;
                                          });
                                        }
                                        else{
                                          setState(() {
                                            isLoading=true;
                                          });


                                          await getData(_salesOrderController.text);


                                        }
                                      } , icon: const Icon(Icons.arrow_forward_ios)),
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

            ],
          ),
        ),

      ),
    );
  }
}
