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
import '../Models/NotFoundException.dart';
class SalesOrderSearch extends StatefulWidget {


  @override
  _SalesOrderSearchState createState() => _SalesOrderSearchState();
}
class _SalesOrderSearchState extends  State<SalesOrderSearch>{
  bool SearchSuccess = false;
  TextEditingController _lineController = TextEditingController();
  TextEditingController _customerShipcontroller = TextEditingController();
  dynamic SOLines = null;
  Future<List<dynamic>?> getSalesOrderLines(int OrderNum) async {
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
    try {
      var data = await APIV2Helper.getResults(
          '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
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
    on NotFoundException catch (e) {
      return [];
    }
    catch (e) {
      showDialog(context: context, builder: (BuildContext context) => AlertDialog(
        title: Text("Error"),
        content: Text(e.toString()),
      ));
    }
  }
  Future<List<dynamic>?> getCustomerShipments(int OrderNum) async {
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
    try {
      var data = await APIV2Helper.getResults(
          '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
              '/v2/odata/${tenantConfig['company']}/'
              'BaqSvc/IIT_Cust_ShipTo/Data/?OrderNum=$OrderNum',

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

  }
  @override
  Widget build(BuildContext context) {
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;

  onSalesOrderSelected(dynamic item) async {
    int salesOrder= int.parse((item as Map<String,dynamic>)['OrderNum'].toString());

    setState(() {
      context.read<ArchitectureProvider>().updateSO(int.parse((item as Map<String,dynamic>)['OrderNum'].toString()));
      context.read<ArchitectureProvider>().updateCust((item as Map<String,dynamic>)['CustNum']);
      context.read<ArchitectureProvider>().updateCustId((item as Map<String,dynamic>)['Customer']);
    });

    dynamic data = await Future.wait([getCustomerShipments(salesOrder)]);

    setState(() {

      context.read<ArchitectureProvider>().setShipments(data[0]);

    });
  }
    return
      Column(
        children: [
          IndexSearchBar(
          entity: "S.O",
          onSearch:  (String term) async {
           try {
             var data = await APIV2Helper.getResults(
                 '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
                     '/v2/odata/${tenantConfig['company']}/'
                     'BaqSvc/IIT_Cust_SO/Data?\$filter=OrderHed_OrderNum eq ${term}',

                 {"username": context
                     .read<tenantConfigProvider>()
                     .tenantConfig['userID'],
                   "password": context
                       .read<tenantConfigProvider>()
                       .tenantConfig['password']}
                 , entity: "Sales Order");
             if(data.isNotEmpty){
               context.read<ArchitectureProvider>().updateSO(data[0]['OrderHed_OrderNum'].toInt());
                context.read<ArchitectureProvider>().updateCust(data[0]['Customer_CustNum']);
                context.read<ArchitectureProvider>().updateCustId(data[0]['Customer_CustID']);
             }
             dynamic Shipments = await Future.wait([getCustomerShipments(data[0]['OrderHed_OrderNum'].toInt())]);

             setState(() {

               context.read<ArchitectureProvider>().setShipments(Shipments[0]);

             });
           }on NotFoundException catch(e){
             showDialog(context: context, builder: (BuildContext context) => AlertDialog(
               title: Text("Error"),
               content: Text(e.toString()),
             ));
           };
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
                  controller: _customerShipcontroller,
                  label: "Ship To ",
                  data: context.watch<ArchitectureProvider>().customerShipments?.map((e) => e['ShipTo_ShipToNum']).toList()??[],
                  dataMap: context.watch<ArchitectureProvider>().customerShipments?? [],
                  loading: context.watch<ArchitectureProvider>().customerShipments==null &&context.watch<ArchitectureProvider>().SO!=0 ,
                  enabled:!(context.watch<ArchitectureProvider>().customerShipments==null || context.watch<ArchitectureProvider>().SO==0) ,
                  onChnaged: (value){
                    setState(() {
                      context.read<ArchitectureProvider>().updateShipment(value);

                    });
                  },
                ),
              ),



            ],
          ),
        ],
      );
  }
}