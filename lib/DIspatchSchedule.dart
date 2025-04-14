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
class DispatchSchedule extends StatefulWidget {
  const DispatchSchedule({Key? key}) : super(key: key);

  @override
  _DispatchScheduleState createState() => _DispatchScheduleState();
}
class _DispatchScheduleState extends State<DispatchSchedule> {
  final TextEditingController warehouseController = TextEditingController();
  List<LoadLine> StructureList = [];
  List<dynamic> dynamicStructures = [];
  bool isLoading = true; // Track loading state
  bool hasError = false;
  // Track error state
  int page = 1;
  Future<void> getData() async  {
    try {
      final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
      List<dynamic> data = await APIV2Helper.getPaginatedResults(
          '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
              '/v2/odata/${tenantConfig['company']}/BaqSvc/IIT_DispatchSchedule/Data', page, 10, {
        'username': tenantConfig['userID'],
        'password': tenantConfig['password']
      });

      setState(() {
        dynamicStructures+= data;
        isLoading = false; // Set loading to false once data is fetched
      });
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
    getData(); // Fetch data once when widget is created
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle floating action button press
          List<dynamic> selectedItems = dynamicStructures.where((x) => x['checked'] == true).toList();
          if (selectedItems.isNotEmpty) {
            // Perform action with selected items
            Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context)=>StockLoading(initialTabIndex: 1, isUpdate: false, LinesOriented: true,
            passedElements: selectedItems.map((x) => ElementData(
              Company: context.read<tenantConfigProvider>().tenantConfig['company'].toString(),
             partId: x['PartLot_PartNum'].toString(),
             elementId: x['PartLot_LotNum'].toString(),
              elementDesc: x['PartLot_PartLotDescription'].toString(),
              erectionSeq: int.parse(x['PartLot_ErectionSequence_c'].toString()),
              erectionDate: x['PartLot_ErectionPlannedDate_c'].toString(),
              weight: double.parse(x['PartLot_Ton_c']),
              area:double.parse(x['PartLot_M2_c']),
              volume: double.parse(x['PartLot_M3_c'].toString()),
              UOM: x['Part_UOMClassID'].toString(),
              quantity: 1,
              selectedQty: 1,
              ChildKey1: x['ChildKey1'].toString(),
              fromBin: x['PartBin_BinNum'].toString(),
              Warehouse: x['PartBin_WarehouseCode'].toString(),
              SO: x['OrderDtl_OrderNum'].toInt(),
            )).toList(),
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
      body: hasError
          ? Center(child: Text('Error fetching data'))
          : Container(
        color: Theme.of(context).shadowColor,
        child: Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
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
                  Expanded(
                      flex: 1,
                      child: ReDropDown(
                          enabled: true,
                          data: [],
                          label: "Warehouse",
                          controller: warehouseController,
                          dataMap: [],
                          loading: false)),
                ],
              ),
              GestureDetector(
                child: SizedBox(
                  height: height * 0.8,
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
                                        child: Center(child: CircularProgressIndicator())) :Container(

                                      child: Column(
                                        children: [
                                          IndexTable(
                                            data: dynamicStructures.map((x) => DataRow(cells: [
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
                                              DataCell(Text(x['OrderDtl_RequestDate'].toString())),
                                              DataCell(Text(x['OrderDtl_OrderNum'].toString())),
                                              DataCell(Text(x['Customer_Name'].toString())),
                                              DataCell(Text(x['Calculated_Status'].toString())),
                                            ])).toList().sublist((page-1)*10, page*10),
                                            columns: [
                                              DataColumn(label: Text('Checked')),
                                              DataColumn(label: Text('Structure ID')),
                                              DataColumn(label: Text('Structure Number')),
                                              DataColumn(label: Text('Ship By Date')),
                                              DataColumn(label: Text('Sales Order')),
                                              DataColumn(label: Text('Customer Name')),
                                              DataColumn(label: Text('Status')),
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
                              
                              
                                          await getData();
                                          setState(() {
                                           page++;
                                          });
                              
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
