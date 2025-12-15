import 'load_model.dart';
import 'package:flutter/material.dart';
import 'indexAppBar.dart';
import 'stockLoadingPage.dart';
import 'sideBarMenu.dart';
import 'package:provider/provider.dart';
import 'load_model.dart';
import 'utils/APIProviderV2.dart';
import 'dart:math';
import './Widgets/IndexTable.dart';
import './Models/NotFoundException.dart';
import './Widgets/fromToCalendar.dart';
import './utils/DateHelper.dart';
class ElementDataSource extends ChangeNotifier {
  List<LoadData> loads = [];
}

class LoadHistory extends StatefulWidget {
  final List<LoadData> loads;
  final dynamic addLoad;
  final dynamic tenantConfig;
  const LoadHistory({super.key, required this.loads, required this.addLoad, required this.tenantConfig});

  @override
  State<LoadHistory> createState() => _LoadHistoryState();
}



class _LoadHistoryState extends State<LoadHistory> {
  List<LoadData> loads = [];
  bool loading = true;
  int page=1;
  int totalPages=1;
  Map<int,List<LoadData>> cache={};
  DateTime fromDate= DateTime.now().subtract(const Duration(days: 60));
  DateTime toDate= DateTime.now();
  void addLoadData(LoadData load) {
    setState(() {
      for (int i = 0; i < loads.length; i++) {
        if (loads[i].loadID == load.loadID) {
          loads.removeAt(i);
          break;
        }
      }
      loads.add(load);
    });
  }

  _LoadHistoryState();
  final GlobalKey<PaginatedDataTableState> dataTableKey = GlobalKey();

  Future<List<LoadData>> fetchLoadsByUserName(String userName,String fromDate,String toDate,int page,{rows=10}) async {
    try {
      List<dynamic> loads = await APIV2Helper.getPaginatedResults(
        '${widget.tenantConfig['httpVerbKey']}://${widget.tenantConfig['appPoolHost']}/${widget.tenantConfig['appPoolInstance']}/api'
            '/v1/'
            'BaqSvc/IIT_Load_History/?userName=$userName&formDate=${fromDate}&toDate=${toDate}',

        page,
        rows,


        {
          'username': widget.tenantConfig['userID'],
          'password': widget.tenantConfig['password']
        },hasVars: true,entity: "loads"
      );
      return loads.map((load) => LoadData.fromJson(load, prefix: "UD104_")).toList();
    } catch (e) {
      throw Exception('Error fetching loads: $e');
    }
  }
 void fetchData (){
    fetchLoadsByUserName(widget.tenantConfig['userID'],DateHelper.formatForEpicor(fromDate),
        DateHelper.formatForEpicor(toDate)
        ,1,rows: 10).then((fetchedLoads) {

      if (mounted) {
        setState(() {
          cache[page]=fetchedLoads;
          loads = fetchedLoads;

        });

      }

    }).catchError((error) {
      // Handle error here
      print('Error fetching loads: $error');
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }

    );
  }
  

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).shadowColor,
      appBar: const IndexAppBar(title: 'Load History'),
      drawer: width > 600 ? null : SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
      body: Row(
        children: [
          width > 600
              ? SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
          )
              : const SizedBox(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: loading||loads.isNotEmpty
                  ? Column(
                children:[
                  DateRangeBar(initialFrom: fromDate, initialTo: toDate,
                      onSelect: (fromDate,toDate){
                    setState(() {
                      this.fromDate=fromDate;
                      this.toDate=toDate;
                      page=1;
                      cache={};
                      setState(() {
                        loading=true;
                      });
                      fetchData();
                    });
                    print('Date range selected: $fromDate - $toDate');
                  },
                  disabled: loading,
                  ),
                  Card(
                    color: Theme.of(context).indicatorColor,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: loading?Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).canvasColor,
                        ),
                      ):SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: IndexTable(data: loads.map((load)=>DataRow(
                              cells: [
                                DataCell(
                                  GestureDetector(
                                    onTap: ()
                                    {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                          StockLoading(initialTabIndex: 0,
                                            isUpdate: true,
                                            loadDataList: loads,
                                            addLoadData: addLoadData,
                                            historyLoadID: load.loadID,
                                          )));
                                    },
                                    child: Text(load.loadID),

                                  ),
                                ),


                            DataCell(Text(load.loadDate)),
                            DataCell(Text(load.CustomerId)),
                            DataCell(Text(load.projectId)),
                            DataCell(Text(load.CustNum)),
                          ]

                          )).toList(), columns:[

                            DataColumn(label: Text('Load ID', style: TextStyle(color: Theme.of(context).canvasColor)),),
                            DataColumn(label: Text('Load Date', style: TextStyle(color: Theme.of(context).canvasColor)),),
                            DataColumn(label: Text('Customer ID', style: TextStyle(color: Theme.of(context).canvasColor)),),
                            DataColumn(label: Text('Project ID', style: TextStyle(color: Theme.of(context).canvasColor)),),
                            DataColumn(label: Text('Customer Number', style: TextStyle(color: Theme.of(context).canvasColor)),),
                          ] , ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ Center(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(

                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            page<=1?IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey,)):
          IconButton(onPressed:(){

                                setState(() {

                                  loads=cache[page-1]!;
                                  page--;
                                });



                            } , icon: const Icon(Icons.arrow_back_ios_new)),
                            Text(('Page $page ').toString()),

                            IconButton(onPressed:()async{
                              if(cache[page+1]!=null&&cache[page+1]!.isNotEmpty){
                                setState(() {
                                  loads=cache[++page]??[];


                                });

                              }
                              else{
                                setState(() {
                                  loading=true;
                                });
                                try{

                                List<LoadData>temp = await   fetchLoadsByUserName(widget.tenantConfig['userID'],
                                    DateHelper.formatForEpicor(fromDate),
                                    DateHelper.formatForEpicor(toDate)
                                    ,page+1,rows: 10);
                                if(temp.isEmpty){
                                  throw new NotFoundException(entity: 'history loads');
                                }
                                setState(() {
                                  loads=temp;
                                  cache[++page]=loads;

                                  totalPages++;
                                });
                              }on NotFoundException catch(error){

                                  showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                                    title: Text("Error"),
                                    content: Text(error.toString()),
                                  ));
                                }catch(error){
                                  showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                                    title: Text("Error"),
                                    content: Text("something wrong happend"),
                                  ));
                                }
                                finally{
                                  setState(() {
                                    loading=false;
                                  });
                                }
                              }
                            } , icon: const Icon(Icons.arrow_forward_ios)



                            ),
                          ],
                        ),
                      ),
                    ),
                    ],
                  ),
                ],
              )
                  : Center(
                child: Text(
                  'No loads created in this session.',
                  style: TextStyle(fontSize: 16, color: Theme.of(context).canvasColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}