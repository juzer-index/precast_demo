

import 'package:GoCastTrack/Providers/tenantConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './SearchBar.dart';
import '../Widgets/DropDown.dart';
import '../Providers/APIProviderV2.dart';
import 'package:provider/provider.dart';
import './SalesOrderPop.dart';
class SalesOrderSearch extends StatefulWidget {


  @override
  _SalesOrderSearchState createState() => _SalesOrderSearchState();
}
class _SalesOrderSearchState extends  State<SalesOrderSearch>{
  bool SearchSuccess = false;
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {

    return
      Column(
        children: [
          IndexSearchBar(
          entity: "S.O",
          onSearch:  (String term) async {

            var data = await APIProvider.getPaginatedResults("https://77.92.189.102/ppgprecastvertical/api/v2/odata/EPIC06/Erp.BO.SalesOrderSvc/SalesOrders",
                1, 10,
                 {"username": context.read<tenantConfigProvider>().tenantConfig['userID'],
                   "password":context.read<tenantConfigProvider>().tenantConfig['password']}
                , entity: "Sales Order");
            print(data);

          },
          advanceSearch: true,
            onAdvanceSearch: (){
             showDialog(context: context, builder: (BuildContext context)=>SalesOrderPopUP()

             );
            },

              ),
          ReDropDown(
            controller: _controller,
            label: "S.O Lines",
            data: [],
            dataMap: [],
            loading: false,
            enabled: false,

          ),
        ],
      );
  }
}