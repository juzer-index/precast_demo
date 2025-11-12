import 'package:GoCastTrack/Providers/tenantConfig.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
  final bool isUpdate;
  final bool enabled;
  const SalesOrderSearch({super.key, required this.isUpdate,
  this.enabled = true
  });

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
              '/v1/'
              'BaqSvc/IIT_OrderDtl/?OrderNum=$OrderNum'
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
  Future<List<dynamic>?> getCustomerShipments(num OrderNum) async {
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

  }
  @override
  @override
  void initState() {

    if(context.read<ArchitectureProvider>().SO!=0){
      getCustomerShipments(context.read<ArchitectureProvider>().SO).then((value) {
        setState(() {
          context.read<ArchitectureProvider>().setShipments(value);
        });
      });
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;

  onSalesOrderSelected(dynamic item) async {
    int salesOrder= int.parse((item as Map<String,dynamic>)['OrderNum'].toString());

       context.read<ArchitectureProvider>().updateSO(int.parse((item)['OrderNum'].toString()));
      context.read<ArchitectureProvider>().updateCust((item)['CustNum']);
      context.read<ArchitectureProvider>().updateCustId((item)['Customer']);


    dynamic data = await Future.wait([getCustomerShipments(salesOrder),getSalesOrderLines((item)['OrderNum'])]);


   if(mounted) {
     context.read<ArchitectureProvider>().setShipments(data[0]);
     context.read<ArchitectureProvider>().setLines(data[1]);
   }
  }
    return
      Column(
        children: [
          IndexSearchBar(
            enabled: widget.enabled,
          entity: "S.O",
          onSearch:  (String term) async {
           try {
             var data = await APIV2Helper.getResults(
                 '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
                     '/v1/'
                     'BaqSvc/IIT_Cust_SO/?\$filter=OrderHed_OrderNum eq $term',

                 {"username": context
                     .read<tenantConfigProvider>()
                     .tenantConfig['userID'],
                   "password": context
                       .read<tenantConfigProvider>()
                       .tenantConfig['password']}
                 , entity: "Sales Order");
             if(data.isNotEmpty && mounted){
               context.read<ArchitectureProvider>().updateSO(data[0]['OrderHed_OrderNum'].toInt());
                context.read<ArchitectureProvider>().updateCust(data[0]['Customer_CustNum']);
                context.read<ArchitectureProvider>().updateCustId(data[0]['Customer_CustID']);
             }
             dynamic res = await Future.wait([getCustomerShipments(data[0]['OrderHed_OrderNum'].toInt()),getSalesOrderLines(data[0]['OrderHed_OrderNum'].toInt())]);



             if(mounted) {
               context.read<ArchitectureProvider>().setShipments(res[0]);
               context.read<ArchitectureProvider>().setLines(res[1]);
             }


           }on NotFoundException catch(e){
             showDialog(context: context, builder: (BuildContext context) => AlertDialog(
               title: Text("Error"),
               content: Text(e.toString()),
             ));
           };
          },
          advanceSearch: true,
            value: context.watch<ArchitectureProvider>().SO == 0
                ? ''
                : context.watch<ArchitectureProvider>().SO.toString(),
            onAdvanceSearch: (){
             showDialog(context: context, builder: (BuildContext context)=>SalesOrderPopUP( onSalesOrderSelected: onSalesOrderSelected,)

             );
            },

              ),
          Row(
            children: [


           Expanded(
             child: Padding(
               padding: const EdgeInsets.all(8.0),
               child: DropdownSearch(
                 selectedItem: context.watch<ArchitectureProvider>().selectedShipment,
                 enabled: widget.enabled&&!(context.watch<ArchitectureProvider>().customerShipments == null || context.watch<ArchitectureProvider>().SO == 0),
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
                   if(mounted) setState(() {
                     context.read<ArchitectureProvider>().updateShipment(value);
                     _customerShipcontroller.text = value;
                   });
                 },
               ),
             ),
             //    child: ReDropDown(
             //      controller: _customerShipcontroller,
             //      label: "Ship To ",
             //      data: context.watch<ArchitectureProvider>().customerShipments?.map((e) => e['ShipTo_ShipToNum']).toList()??[],
             //      dataMap: context.watch<ArchitectureProvider>().customerShipments?? [],
             //      loading: context.watch<ArchitectureProvider>().customerShipments==null &&context.watch<ArchitectureProvider>().SO!=0 ,
             //      enabled:!(context.watch<ArchitectureProvider>().customerShipments==null || context.watch<ArchitectureProvider>().SO==0) ,
             //      onChnaged: (value){
             //        setState(() {
             //          context.read<ArchitectureProvider>().updateShipment(value);
             //        });
             //      },
             //    ),
              ),



            ],
          ),
        ],
      );
  }
}