import 'package:GoCastTrack/Providers/tenantConfig.dart';
import 'package:flutter/material.dart';
import './SearchBar.dart';
import 'package:provider/provider.dart';
import '../Providers/APIProviderV2.dart';
import '../Providers/tenantConfig.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../Providers/APIProviderV2.dart';
class SalesOrderPopUP extends StatefulWidget {
  const SalesOrderPopUP({Key? key}) : super(key: key);

  @override
  _SalesOrderPopUPState createState() => _SalesOrderPopUPState();
}
class _SalesOrderPopUPState extends State<SalesOrderPopUP> {
  bool isSearching = false;
  List<String> SearchedItems = [];
  int page = 1;
  dynamic? _pagingController;
  String searchValue = "";

  @override
  void initState(){
    super.initState();
     final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
   _pagingController= PagingController<int,dynamic>(
        getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
        fetchPage: (pageKey) async {
          final data= await APIProvider.getPaginatedResults(
              '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
                  '/v2/odata/${tenantConfig['company']}/'
                  'BaqSvc/IIT_SalesOrders_MS/Data${searchValue.isNotEmpty?'/?OrderNum=$searchValue':""}',
              pageKey, 20, {
            'username': tenantConfig['userID'],
            'password': tenantConfig['password']
          }, hasVars: searchValue.isNotEmpty, entity: "Sales Order");

          return data.map((e) => e['OrderHed_OrderNum'].toString()).toList();
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    final Width=MediaQuery.of(context).size.width;
    final Height= MediaQuery.of(context).size.height;



    return AlertDialog(

      title: Text("Sales Order"),
      content: SingleChildScrollView(
        reverse: true,
        child: Container(
          height: 600,
          width:Width ,
          child: Column(
            children: [
              IndexSearchBar(entity: "Sales Order", onSearch: (String term) async {

                setState(() {
                  searchValue = term;
                  _pagingController!.refresh();
                });

              },),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: PagingListener(controller: _pagingController, builder: (context,state,fetchNextPage){
                    return PagedListView(state: state, fetchNextPage: fetchNextPage, builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context,item,index){
                          return ListTile(
                            title: Text(item.toString()),
                            onTap: (){

                            },
                          );
                        }
                    ));
                  }
                ),
              ),
              ),


            ],
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