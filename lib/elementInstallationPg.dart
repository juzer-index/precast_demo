import 'dart:convert';
import 'dart:io';
import 'load_model.dart';
import 'sideBarMenu.dart';
import 'package:GoCastTrack/partTable.dart';
import 'package:GoCastTrack/part_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'Providers/tenantConfig.dart';
import 'elementSearchForm.dart';
import 'elementTable.dart';
import 'element_model.dart';

class ElementInstallation extends StatefulWidget {
  dynamic tenantConfig;
  ElementInstallation({Key? key, required this.tenantConfig}) : super(key: key);

  @override
  State<ElementInstallation> createState() => _ElementInstallationState();
}

class _ElementInstallationState extends State<ElementInstallation> {
  Map<String, dynamic> fetchedProjectData = {};
  List<dynamic> fetchedProjectValue = [];
  late final Future dataLoaded;
  TextEditingController projectIdController = TextEditingController();
  late int custNum = 0;
  List<ElementData> selectedElements = [];
  List<PartData> selectedParts = [];
  dynamic tenatConfigP;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tenatConfigP = widget.tenantConfig;
    dataLoaded = getProjectList(tenatConfigP);
  }
  Future<void> InstallElement(String PartNum , String PartDes ,String JobNum ) async{
    try {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('${widget.tenantConfig['userID']}:${widget.tenantConfig['password']}'))}';

      final response = await http.post(
        Uri.parse(
            '${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api/v1/Ice.BO.UD100Svc/UD100s'),
        headers: {
          HttpHeaders.authorizationHeader: basicAuth,
          HttpHeaders.contentTypeHeader: 'application/json',
        }
        ,
        body: jsonEncode({
          "Company": widget.tenantConfig['company'],
          "ShortChar01": JobNum,
          "ShortChar02": PartNum,
          "ShortChar03": PartDes,
          "CheckBox01": true,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {

        AlertDialog dialog = AlertDialog(
          title: const Text("Success"),
          content: const Text("Element installed successfully"),
          actions: [
            TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        );
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return dialog;
            });
      } else {
        AlertDialog dialog = AlertDialog(
          title: const Text("Error"),
          content: const Text("Failed to install element"),
          actions: [
            TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        );
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return dialog;
            });
      }
    } on Exception catch (e) {
      AlertDialog dialog = AlertDialog(
        title: const Text("Error"),
        content: const Text("Failed to install element"),
        actions: [
          TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return dialog;
          });
    }
  }

  List<LoadData> loads = [];
  void addLoadData(LoadData load) {
    setState(() {
      for (int i = 0; i < loads.length; i++) {
        if (loads[i].loadID == load.loadID) {
          loads.removeAt(i);
          break;
        }
      }
    });
    setState(() {
      loads.add(load);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          showAlertDialog(BuildContext context) {
            // Init
            AlertDialog dialog = AlertDialog(
              title: const Text("Are you sure you want to exit?",
                  style: TextStyle(color: Colors.red)),
              content: const Text("All unsaved data will be lost"),
              actions: [
                TextButton(
                    child: Text("Yes",
                        style: TextStyle(color: Theme.of(context).canvasColor)),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }),
                TextButton(
                    child: Text("No",
                        style: TextStyle(color: Theme.of(context).canvasColor)),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            );

            // Show the dialog
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return dialog;
                });
          }

          showAlertDialog(context);
        }
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: width>600?null:SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
          backgroundColor: Color(0xffF0F0F0),
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Center(
              child: Text(
                'Element Installation',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          body: FutureBuilder(
            future: dataLoaded,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ), // Show spinner when disabled
                    ),
                  ],
                );
              }
              return Row(
                  children: [
              width > 600
              ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
                child: SideBarMenu(context, loads, addLoadData, widget.tenantConfig))
                : const SizedBox(),
                            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(100, 10, 100, 10),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        /*
                        Text("Project",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).canvasColor)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownSearch(
                            selectedItem: projectIdController.text,
                            enabled: true,
                            popupProps: const PopupProps.modalBottomSheet(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  suffixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                  labelText: "Search",
                                ),
                              ),
                            ),
                            autoValidateMode:
                                AutovalidateMode.onUserInteraction,
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Project ID",
                              ),
                            ),
                            items: fetchedProjectValue
                                .map((project) => project['ProjectID'])
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                projectIdController.text =
                                    fetchedProjectValue.firstWhere((project) =>
                                        project['ProjectID'] ==
                                        value)['ProjectID'];
                                custNum = fetchedProjectValue.firstWhere(
                                    (project) =>
                                        project['ProjectID'] ==
                                        value)['ConCustNum'];
                              });
                            },
                          ),
                        ),

                         */
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Element Search Form',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).canvasColor),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).indicatorColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElementSearchForm(
                              onElementsSelected: updateElementInformation,
                              arrivedElements: selectedElements.isNotEmpty
                                  ? selectedElements
                                  : [],
                              isOffloading: false,
                              AddElement: _addElement,
                              Project: projectIdController.text,
                              tenantConfig: widget.tenantConfig,
                              isInstalling: true,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Selected Elements',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).canvasColor),
                        ),
                        ElementTable(
                          selectedElements: selectedElements,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: ElevatedButton(
                          style:selectedElements.isEmpty? ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                        )
                        : null,
                            onPressed: () async {

                              for (var element in selectedElements) {

                                  await InstallElement(element.partId, element.elementDesc, element.elementId);

                              }



                            },
                            child: const Text('Save'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
                            ),
                          ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _addElement(ElementData element) {
    setState(() {
      selectedElements.add(element);
    });
  }

  void updateElementInformation(List<ElementData> selectedElementsFromForm,
      List<PartData> selectedPartsFromForm) {
    setState(() {
      selectedElements = selectedElementsFromForm;
      selectedParts = selectedPartsFromForm;
    });
  }

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
}
