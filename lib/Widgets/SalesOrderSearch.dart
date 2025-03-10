

import 'package:GoCastTrack/Providers/tenantConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './SearchBar.dart';
import '../Widgets/DropDown.dart';
import '../utils/APIProviderV2.dart';
import 'package:provider/provider.dart';
import './SalesOrderPop.dart';
import "../Providers/ArchitectureProvider.dart";
import '../Models/OrderLine.dart';
import '../utils/APIProviderV2.dart';
class SalesOrderSearch extends StatefulWidget {


  @override
  _SalesOrderSearchState createState() => _SalesOrderSearchState();
}
class _SalesOrderSearchState extends  State<SalesOrderSearch>{
  bool SearchSuccess = false;
  TextEditingController _controller = TextEditingController();
  dynamic SOLines = null;
  Future<List<dynamic>> getSalesOrderLines(int OrderNum) async {
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
    var data = await APIV2Helper.getResults( '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
        '/v2/odata/${tenantConfig['company']}/'
        'Erp.BO.SalesOrderSvc/OrderDtls?\$filter=OrderNum eq $OrderNum&\$select=OrderLine '
        ' ',
        {
          'username': tenantConfig['userID'],
          'password': tenantConfig['password']
        }
    );
    return data;
  }
  Future<List<dynamic>> getCustomerShipments(int OrderNum) async {
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
    var data = await APIV2Helper.getResults( '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/BaqSvc/IIT_Cust_ShipTo/Data'
        '/?OrderNum=$OrderNum'
        ' ',
        {
          'username': tenantConfig['userID'],
          'password': tenantConfig['password']
        }
    );
    return data;
  }
  @override
  Widget build(BuildContext context) {
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;

  onSalesOrderSelected(dynamic item) async {
    int salesOrder= int.parse((item as Map<String,dynamic>)['OrderNum'].toString());

    setState(() {
      context.read<ArchitectureProvider>().updateSO(int.parse((item as Map<String,dynamic>)['OrderNum'].toString()));
    });

    dynamic data = await Future.wait([getSalesOrderLines(salesOrder),getCustomerShipments(salesOrder)]);

    setState(() {
      context.read<ArchitectureProvider>().setLines(data[0]);

    });
  }
    return
      Column(
        children: [
          IndexSearchBar(
          entity: "S.O",
          onSearch:  (String term) async {

            var data = await APIV2Helper.getPaginatedResults("https://77.92.189.102/ppgprecastvertical/api/v2/odata/EPIC06/Erp.BO.SalesOrderSvc/SalesOrders",
                1, 10,
                 {"username": context.read<tenantConfigProvider>().tenantConfig['userID'],
                   "password":context.read<tenantConfigProvider>().tenantConfig['password']}
                , entity: "Sales Order");


          },
          advanceSearch: true,
            value: context.watch<ArchitectureProvider>().SO.toString(),
            onAdvanceSearch: (){
             showDialog(context: context, builder: (BuildContext context)=>SalesOrderPopUP( onSalesOrderSelected: onSalesOrderSelected,)

             );
            },

              ),
          Row(
            children: [


              Expanded(
                child: ReDropDown(
                  controller: _controller,
                  label: "S.O Lines",
                  data: context.watch<ArchitectureProvider>().lines?.map((e) => e['OrderLine']).toList()??[],
                  dataMap: context.watch<ArchitectureProvider>().lines?? [],
                  loading: context.watch<ArchitectureProvider>().lines==null &&context.watch<ArchitectureProvider>().SO!=0 ,
                  enabled:!(context.watch<ArchitectureProvider>().lines==null &&context.watch<ArchitectureProvider>().SO!=0) ,

                ),
              ),Expanded(
                child: ReDropDown(
                  controller: _controller,
                  label: "Customer Shipments ",
                  data: context.watch<ArchitectureProvider>().customerShipments?.map((e) => e['ShipTo_ShipToNum']).toList()??[],
                  dataMap: context.watch<ArchitectureProvider>().customerShipments?? [],
                  loading: context.watch<ArchitectureProvider>().customerShipments==null &&context.watch<ArchitectureProvider>().SO!=0 ,
                  enabled:!(context.watch<ArchitectureProvider>().customerShipments==null &&context.watch<ArchitectureProvider>().SO!=0) ,

                ),
              ),



            ],
          ),
        ],
      );
  }
}