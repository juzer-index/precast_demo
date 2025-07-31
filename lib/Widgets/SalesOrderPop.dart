import 'package:GoCastTrack/Providers/tenantConfig.dart';
import 'package:flutter/material.dart';
import './SearchBar.dart';
import 'package:provider/provider.dart';
import '../utils/APIProviderV2.dart';
import '../Providers/tenantConfig.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../utils/APIProviderV2.dart';
import '../Providers/ArchitectureProvider.dart';
import '../Models/OrderLine.dart';
class SalesOrderPopUP extends StatefulWidget {
  Function(dynamic SO) onSalesOrderSelected;
  SalesOrderPopUP({required this.onSalesOrderSelected});

  @override
  _SalesOrderPopUPState createState() => _SalesOrderPopUPState();
}
class _SalesOrderPopUPState extends State<SalesOrderPopUP> {
  bool isSearching = false;
  List<Map<int,String>> SearchedItems = [];
  int page = 1;
  dynamic? _pagingController;
  String searchValue = "";


  @override
  void initState(){
    super.initState();
     final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
   _pagingController= PagingController<int,Map<String,dynamic>>(
        getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) async {
          final data= await APIV2Helper.getPaginatedResults(
              '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
                  '/v1/BaqSvc/IIT_SalesOrders_MS/${searchValue.isNotEmpty?'?OrderNum=$searchValue':""}',
              pageKey, 20, {
            'username': tenantConfig['userID'],
            'password': tenantConfig['password']
          }, hasVars: searchValue.isNotEmpty, entity: "Sales Order");


          return data.map((e) =>{
            'OrderNum':e['OrderHed_OrderNum']
            ,'Customer':e['Customer_CustID']
          , 'CustNum':e['Customer_CustNum']

          }as Map<String,dynamic>).toList();
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    final Width=MediaQuery.of(context).size.width;
    final Height= MediaQuery.of(context).size.height;
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;


    return AlertDialog(

      title: Text("Sales Order"),
      content: SingleChildScrollView(
        reverse: true,
        child: Container(
          height: Height*0.6,
          width:Width ,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[200],

          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                IndexSearchBar(entity: "Sales Order", onSearch: (String term) async {

                  setState(() {
                    searchValue = term;
                    _pagingController!.refresh();
                  });

                },),
                Expanded(
                  child: PagingListener(controller: _pagingController, builder: (context,state,fetchNextPage){
                    return PagedListView(state: state, fetchNextPage: fetchNextPage, builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context,item,index){
                          return ListTile(
                            selectedColor: Colors.green,

                            title: Text('${(item as Map<String,dynamic>)['OrderNum'].toString()} (${(item as Map<String,dynamic>)['Customer'].toString()})'),

                            onTap: ()async {
                              widget.onSalesOrderSelected(item);


                              Navigator.of(context).pop();

                            },
                          );
                        }
                    ));
                  }
                                  ),
                ),


              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}