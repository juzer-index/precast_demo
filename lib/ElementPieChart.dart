import 'dart:async';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'elementTable.dart';
import 'partTable.dart';
import 'elementSearchForm.dart';
import 'stockOffloadingPage.dart';
import 'truckDetails.dart';
import 'truck_resource_model.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'load_model.dart';
import 'part_model.dart';
import 'element_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import 'Providers/UserManagement.dart';
import 'Providers/tenantConfig.dart';
import 'package:fl_chart/fl_chart.dart';

class ElementPieChart extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>
      _ElementPieChartState();
/*
* '#DDAF5B', // draft (Light teal)
'#00A2F3', // entered (Medium blue)
'#77A36F', // approved (Lime green)
'#8A8A8A', // casted (Dark gray)
'#FD9494', // in transit (Light pink)
'#A35BA3', // onsite (Dark purple)
'#E6E68A', // erected (Very light yellow)
'#EB5050', // hold (Dark red)
'#891E1E', // cancelled (Dark maroon)
'#630000', // closed (Black)*/


  Map<String,Color> colorMap={
    "Draft":Color(0xFFDDAF5B),
    "Entered":Color(0xFF00A2F3),
    "Approved":Color(0xFF77A36F),
    "Casted":Color(0xFF8A8A8A),
    "In-Transit":Color(0xFFFD9494),
    "OnSite":Color(0xFFA35BA3),
    "Erected":Color(0xFFE6E68A),
    "Hold":Color(0xFFEB5050),
    "Cancelled":Color(0xFF891E1E),
    "Closed":Color(0xFF630000)
  };

  int colorIndex = 0;

}
class _ElementPieChartState extends State<ElementPieChart>{
  late List status=[];
  Future<void> fetchElements( tenantConfigP) async {
    if(status.length==0) {
      try {
        var url = Uri.parse(
            "${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/BaqSvc/IIT_ProjectChart(${tenantConfigP['company']})");
        final basicAuth = 'Basic ${base64Encode(
            utf8.encode(
                '${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

        final response = await http.get(
            url,
            headers: {
              HttpHeaders.authorizationHeader: basicAuth,
              HttpHeaders.contentTypeHeader: 'application/json',
            });
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body)['value'];
          setState(() {
            status = data;
          });
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        print(e);
      }
    }
    else return;
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: fetchElements(Provider.of<tenantConfigProvider>(context).tenantConfig),
      builder:(context,snapshot)=> (
      status.length>0)?
          Row(
 mainAxisAlignment:width>600? MainAxisAlignment.start: MainAxisAlignment.center,
            children: [Expanded(
              child: Row(
                mainAxisAlignment:width>900? MainAxisAlignment.spaceAround:MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 3,
                      color:Theme.of(context).indicatorColor ,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Pie Chart',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 20),
                                  child: SizedBox(
                                    height:150,
                                    width: 150,
                                    child:PieChart(
                                      PieChartData(

                                          sections: status.map((section) =>
                                              PieChartSectionData(
                                                color: widget.colorMap[section["PartLot_ElementStatus_c"]],
                                                value:  section['Calculated_NO'].toDouble(),
                                                title:"",
                                                radius: 20,
                                              )
                                          ).toList(
                                          )),
                                    ) ,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                  child: Legend(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 3,
                      color:Theme.of(context).indicatorColor ,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Bar Chart',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(width>600)Container(
                                  height: 200,
                                  width: 400,
                                  margin: EdgeInsets.only(left: 20),
                                  child: BarChart(
                                    BarChartData(

                                      barGroups: status.asMap().entries.map((entry) {
                                        int index = entry.key;
                                        var section = entry.value;
                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: section['Calculated_NO'].toDouble(),
                                              color: widget.colorMap[section["PartLot_ElementStatus_c"]],
                                              width: 20,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final index = value.toInt();
                                              if (index < status.length) {
                                                final label = status[index]['PartLot_ElementStatus_c'];
                                                return Text(label, style: TextStyle(fontSize: 10));
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                      ),

                                    ),
                                  ),
                                ),
                                Legend(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  ),

                ],
              ),
            )],
          )
          :Center(child: SizedBox(height: 350,width: 500,child: Card(
        elevation: 3,
        color:Theme.of(context).indicatorColor ,
        child:Center(child: CircularProgressIndicator(),),
      ),)
      ),
    );
  }
  }
  class Legend extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(


      margin: EdgeInsets.only(left: 40),
      alignment: Alignment.topRight,
      width: 80,
      height: 280,

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                height: 25,
                width: 100,
                child: Row(

                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      color: Color(0xFFDDAF5B),
                      height: 10,
                      width: 10,
                      alignment: Alignment.topLeft,
                    ),
                    Text("Draft"),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 25,
                width: 100,
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      color: Color(0xFF00A2F3),
                      height: 10,
                      width: 10,
                      alignment: Alignment.topLeft,
                    ),
                    Text("Entered"),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 25,
                width: 100,
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      color: Color(0xFF77A36F),
                      height: 10,
                      width: 10,
                      alignment: Alignment.topLeft,
                    ),
                    Text("Approved"),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 25,
                  width: 100,
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      color: Color(0xFF8A8A8A),
                      height: 10,
                      width: 10,
                      alignment: Alignment.topLeft,
                    ),
                    Text("Casted"),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 25,
                width: 100,
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      color: Color(0xFFFD9494),
                      height: 10,
                      width: 10,
                      alignment: Alignment.topLeft,
                    ),
                    Text("In-Transit"),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 25,
                width: 100,
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      color: Color(0xFFA35BA3),
                      height: 10,
                      width: 10,
                      alignment: Alignment.topLeft,
                    ),
                    Text("Onsite"),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 25,
                width: 100,
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      color: Color(0xFFE6E68A),
                      height: 10,
                      width: 10,
                      alignment: Alignment.topLeft,
                    ),
                    Text("Erected"),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 25,
                width: 100,
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      color: Color(0xFFEB5050),
                      height: 10,
                      width: 10,
                      alignment: Alignment.topLeft,
                    ),
                    Text("Hold"),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 25,
                width: 100,
                child: Row(
                  mainAxisSize: MainAxisSize.max ,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      color: Color(0xFF891E1E),
                      height: 10,
                      width: 10,
                      alignment: Alignment.topLeft,
                    ),
                    Text("Cancelled"),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 30,
                width: 100,
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      color: Color(0xFF630000),
                      height: 10,
                      width: 10,
                      alignment: Alignment.topLeft,
                    ),
                    Text("Closed"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }}