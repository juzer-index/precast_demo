import 'package:GoCastTrack/Providers/tenantConfig.dart';
import 'package:flutter/material.dart';
import './SearchBar.dart';
import 'package:provider/provider.dart';
import '../Providers/APIProviderV2.dart';
import '../Providers/tenantConfig.dart';

class SalesOrderPopUP extends StatefulWidget {
  const SalesOrderPopUP({Key? key}) : super(key: key);

  @override
  _SalesOrderPopUPState createState() => _SalesOrderPopUPState();
}
class _SalesOrderPopUPState extends State<SalesOrderPopUP> {
  bool isSearching = false;
  @override
  Widget build(BuildContext context) {
    final Width=MediaQuery.of(context).size.width;
    final Height= MediaQuery.of(context).size.height;
    final tenantConfig = context.read<tenantConfigProvider>().tenantConfig;
    return AlertDialog(
      title: Text("Sales Order"),
      content: Container(
        height: Height*0.6,
        width:Width ,
        child: Column(
          children: [
            IndexSearchBar(entity: "Sales Order", onSearch: (String term) async {
              context.read<APIProvider>().getPaginatedResults('${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
              setState(() {
                isSearching = true;
              });

            },),
          ],
        ),
      ),
    );
  }
}