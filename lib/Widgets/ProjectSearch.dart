import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../Providers/ArchitectureProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../Providers/tenantConfig.dart';
import '../Widgets/DropDown.dart';
class ProjectSearch extends StatefulWidget {
  final bool isUpdate;
  ProjectSearch({required this.isUpdate});

  @override
  _ProjectSearchState createState() => _ProjectSearchState();

}
class _ProjectSearchState extends State<ProjectSearch> {

  bool isSearching = false;
  Map<String,dynamic> fetchedProjectData = {};
  List<dynamic> fetchedProjectValue = [];
 TextEditingController SalesOrderController = TextEditingController();
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
                onChanged: (value) {
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
                },
              ),
            ),
            ReDropDown(enabled: false, data: [], label: "Sales Order", controller: SalesOrderController, dataMap: [], loading: false),
            Row(
              children: [

                Expanded(child: ReDropDown(enabled: false, data: [], label: "S.O Lines", controller: SalesOrderController, dataMap: [], loading: false)),
                Expanded(child: ReDropDown(enabled: false, data: [], label: "Ship To", controller: SalesOrderController, dataMap: [], loading: false)),
              ],
            )
          ],
        );
      },
    );
  }
}