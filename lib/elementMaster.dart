import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precast_demo/indexAppBar.dart';
import 'package:http/http.dart' as http;


class ElementMaster extends StatefulWidget {
  const ElementMaster({super.key});

  @override
  State<ElementMaster> createState() => _ElementMasterState();
}

class Data {
  late final int id;
  late final String elementId;
  late final String partNum;
  late final String elementDesc;
  late final String project;
  late final String status;
  Data({required this.id, required this.elementId, required this.partNum, required this.project, required this.status, required this.elementDesc});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['Id'],
      elementId: json['ElementId'],
      partNum: json['PartNum'],
      elementDesc: json['ElementDesc'],
      project: json['Project'],
      status: json['Status']
    );
  }
}

// Future<List<Data>> fetchData() async {
//   var url = Uri.parse('https://raw.githubusercontent.com/juzer-index/Precast-assets/main/data.json');
//   final response = await http.get(url);
//   if (response.statusCode == 200) {
//     List jsonResponse  = json.decode(response.body);
//     return jsonResponse.map((data) => Data.fromJson(data)).toList();
//   }
//   else {
//     throw Exception('unexpected error');
//   }
// }

// SY: 27112023: Use Local DATA in json format

Future<List<Data>> fetchData() async {
  String jsonString = await rootBundle.loadString('assets/elementmaster.json');
  List jsonResponse = json.decode(jsonString);
  return jsonResponse.map((data) => Data.fromJson(data)).toList();
}

class MyDataTableSource extends DataTableSource{
  final List<Data> _data;

  MyDataTableSource(this._data);

  @override
  DataRow? getRow(int index) {
    Color statusColor;
    final row = _data[index];
    if (row.status == 'Entered'){
      statusColor = Colors.grey;
    } else if(row.status == 'Casted') {
      statusColor = Colors.green;
    } else if (row.status == 'Erected'){
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.transparent;
    }
    return DataRow(cells: [
      DataCell(
          Text(row.id.toString())
      ),
      DataCell(
          Text(row.elementId)
      ),
      DataCell(
          Text(row.partNum)
      ),
      DataCell(
        Text(row.elementId),
      ),
      DataCell(
        Text(row.project),
      ),
      DataCell(
        Container(
          height: 20,
          width: 50,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: statusColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(row.status),
            ],
          ),
        ),

      )
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;


}

class _ElementMasterState extends State<ElementMaster> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndexAppBar(title: 'Element Master',),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.12,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      elevation: 1,
                      color: Colors.lightBlue.shade100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.search, color: Colors.blue,),
                                  fillColor: Colors.white,
                                    filled: true,
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    labelText: "Part Number"),
          
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    suffixIcon: Icon(Icons.search, color: Colors.blue,),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    labelText: "Element ID"),
          
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: () {
          
                              },
                              icon: Icon(
                                  Icons.refresh_sharp,
                                color: Colors.blueGrey.shade800,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero
                      ),
                      color: Colors.lightBlue.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<List<Data>> (
                          future: fetchData(),
                          builder: (context, snapshot){
                            if (snapshot.hasData) {
                              return SingleChildScrollView(
                                child: PaginatedDataTable(
                                  headingRowColor: MaterialStateColor.resolveWith((states) {return Theme.of(context).primaryColor;}),
                                  columnSpacing: 30,
                                  columns: const [
                                    DataColumn(label: Text('ID')),
                                    DataColumn(label: Text('Element ID')),
                                    DataColumn(label: Text('Part Num')),
                                    DataColumn(label: Text('Element Desc')),
                                    DataColumn(label: Text('Project')),
                                    DataColumn(label: Text('Status')),
                                  ],
                                  source: MyDataTableSource(snapshot.data!),
                                  )
                              );
                            }
                            else if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                            }
                            // By default show a loading spinner.
                            return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,));
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
