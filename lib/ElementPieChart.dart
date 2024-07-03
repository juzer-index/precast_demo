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
import 'package:device_info/device_info.dart';
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

  final List colors = [
   Color(0xFFDDAF5B),
    Color(0xFF00A2F3),
    Color(0xFF77A36F),
    Color(0xFF8A8A8A),
    Color(0xFFFD9494),
    Color(0xFFA35BA3),
    Color(0xFFE6E68A),
    Color(0xFFEB5050),
    Color(0xFF891E1E),
    Color(0xFF630000),



  ];
  int colorIndex = 0;

}
class _ElementPieChartState extends State<ElementPieChart>{
  late List status=[];
  Future<void> fetchElements( tenantConfigP) async {
    try{
      var url =  Uri.parse("${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/BaqSvc/IIT_ProjectChart");
      final basicAuth = 'Basic ${base64Encode(
          utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';

      final response = await http.get(
          url,
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['value'];
        setState(() {
          status=data;
        });
      } else {
        throw Exception('Failed to load data');
      }
    }catch(e){
      print(e);

    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchElements(Provider.of<tenantConfigProvider>(context).tenantConfig),
      builder:(context,snapshot)=> (
      status.length>0)?
          Center(

            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text('Element Status',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              children:[ SizedBox(
                width: 500 , height: 333,
                child: Card(
                  elevation: 3,
                  color:Theme.of(context).indicatorColor ,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text('Element Status',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),

                        Row(
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
                                            color: widget.colors[widget.colorIndex++ % widget.colors.length],
                                            value:  section['Calculated_NO'].toDouble(),
                                            title:"",
                                            radius: 20,
                                          )
                                      ).toList(
                                      )),
                                ) ,
                              ),
                            ),
                            Legend(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),]
            ),
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
                    Text("In Transit"),
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