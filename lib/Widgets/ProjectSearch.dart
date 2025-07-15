import 'package:GoCastTrack/Models/SalesOrder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../Providers/ArchitectureProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../Providers/tenantConfig.dart';
import '../Widgets/DropDown.dart';
import '../utils/APIProviderV2.dart';
import '../Models/NotFoundException.dart';
class ProjectSearch extends StatefulWidget {
  final bool isUpdate;
  const ProjectSearch({super.key, required this.isUpdate});

  @override
  _ProjectSearchState createState() => _ProjectSearchState();

}
class _ProjectSearchState extends State<ProjectSearch> {

  bool isSearching = false;
  Map<String,dynamic> fetchedProjectData = {};
  List<dynamic> fetchedProjectValue = [];
 TextEditingController SalesOrderController = TextEditingController();
  TextEditingController _customerShipcontroller = TextEditingController();
  List<dynamic> salesOrderList = [];
  Future<void> getProjectList(dynamic tenantConfigP) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final response = await http.get(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Erp.Bo.ProjectSvc/List/'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if (response.statusCode == 200) {
        setState(() {
          fetchedProjectData = json.decode(response.body);
          fetchedProjectValue = fetchedProjectData['value'];
        });
      } else {
        throw Exception('Failed to load Project');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<List<dynamic>?> getCustomerShipments(int OrderNum) async {
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
    try {
      var data = await APIV2Helper.getResults(
          '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
              '/v1/'
              'BaqSvc/IIT_Cust_ShipTo/?OrderNum=$OrderNum',

          {
            'username': tenantConfig['userID'],
            'password': tenantConfig['password']
          }
      );
      return data;
    } on NotFoundException catch (e) {
      return [];
    }
    catch (e) {
      showDialog(context: context, builder: (BuildContext context) => AlertDialog(
        title: Text("Error"),
        content: Text(e.toString()),
      ));
    }
    return null;

  }
  @override
  Widget build(BuildContext context) {
    final tenantConfigP = context.watch<tenantConfigProvider>().tenantConfig;
    return FutureBuilder(
      future: getProjectList(tenantConfigP),
      builder: (context, snapshot) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownSearch(
                selectedItem:
                context.watch<ArchitectureProvider>().project,
                enabled: !widget.isUpdate,
                popupProps:
                const PopupProps.modalBottomSheet(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      labelText: "Search",
                    ),
                  ),
                ),
                autoValidateMode: AutovalidateMode
                    .onUserInteraction,
                dropdownDecoratorProps:
                const DropDownDecoratorProps(
                  dropdownSearchDecoration:
                  InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Project ID",
                  ),
                ),
                items: fetchedProjectValue
                    .map((project) =>
                project['ProjectID'])
                    .toList(),
                onChanged: (value) async {
                  setState(() {
                      context.read<ArchitectureProvider>().Project =
                      fetchedProjectValue
                          .firstWhere((project) =>
                      project[
                      'ProjectID'] ==
                      value)['ProjectID'];
                      context.read<ArchitectureProvider>().updateCust(fetchedProjectValue
                          .firstWhere((project) =>
                      project['ProjectID'] ==
                      value)['ConCustNum']);
                  });
                      try {
                        var data = await APIV2Helper.getResults(
                            '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api'
                                '/v1/'
                                'BaqSvc/IIT_Project_SO/?Project=${value.toString()}',

                            {"username": context
                                .read<tenantConfigProvider>()
                                .tenantConfig['userID'],
                              "password": context
                                  .read<tenantConfigProvider>()
                                  .tenantConfig['password']}
                            , entity: "Sales Order");
                        setState(() {
                          salesOrderList = data;
                          debugPrint("Sales Order List: $salesOrderList");
                        });
                        if(data.isNotEmpty) {
                          dynamic Shipments = await Future.wait(
                              [getCustomerShipments(
                                  data[0]['OrderDtl_OrderNum'].toInt())
                              ]);

                          setState(() {
                            context.read<ArchitectureProvider>().setShipments(
                                Shipments[0]);
                          });
                        }else{
                          throw new NotFoundException(entity: "Sales Orders ");
                        }
                      }on NotFoundException catch(e){
                        showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                          title: Text("Error"),
                          content: Text(e.toString()),
                        ));
                      };


                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownSearch(
                selectedItem: context.watch<ArchitectureProvider>().SO.toString(),
                enabled: !widget.isUpdate,
                popupProps: const PopupProps.modalBottomSheet(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      labelText: "Sales Order",
                    ),
                  ),
                ),
                autoValidateMode: AutovalidateMode.onUserInteraction,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Sales Order",
                  ),
                ),
                items: salesOrderList.map((x) => x['OrderDtl_OrderNum'].toString()).toList(),
                onChanged: (value) async {
                  final element = salesOrderList.firstWhere((element) => element['OrderDtl_OrderNum'].toString() == value);
                  setState(() {
                    context.read<ArchitectureProvider>().updateSO(element['OrderDtl_OrderNum'].toInt());
                    context.read<ArchitectureProvider>().updateCust(element['OrderDtl_CustNum']);
                    context.read<ArchitectureProvider>().updateCustId(element['Customer_CustID']);
                    SalesOrderController.text = element['OrderDtl_OrderNum'].toString();
                  });
                  final Shipments = await Future.wait([getCustomerShipments(element['OrderDtl_OrderNum'].toInt())]);
                  context.read<ArchitectureProvider>().setShipments(Shipments[0]);
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownSearch(
                      selectedItem: context.watch<ArchitectureProvider>().selectedShipment,
                      enabled: !(context.watch<ArchitectureProvider>().customerShipments == null || context.watch<ArchitectureProvider>().SO == 0),
                      popupProps: const PopupProps.modalBottomSheet(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            labelText: "Ship To",
                          ),
                        ),
                      ),
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Ship To",
                        ),
                      ),
                      items: context.watch<ArchitectureProvider>().customerShipments?.map((e) => e['ShipTo_ShipToNum']).toList() ?? [],
                      onChanged: (value) {
                        setState(() {
                          context.read<ArchitectureProvider>().updateShipment(value);
                          _customerShipcontroller.text = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}