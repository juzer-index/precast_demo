import 'package:flutter/material.dart';
import '../Models/NotFoundException.dart';
class IndexSearchBar extends StatefulWidget {
  final String entity;
  Future Function(String) onSearch;
  bool advanceSearch;
  Function? onAdvanceSearch=(){};
  String value = "";
  IndexSearchBar({required this.entity,required this.onSearch,this.advanceSearch = false,this.onAdvanceSearch, this.value=""});
  @override
  _IndexSearchBarState createState() => _IndexSearchBarState();
}

class _IndexSearchBarState extends State<IndexSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool isSearching = false;
 @override
  void initState() {
    super.initState();

    _controller.text = widget.value;
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(

              controller: _controller,
              decoration: InputDecoration(
                label: Text("Search ${widget.entity}"),
                hintText: "Search ${widget.entity}",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          !isSearching? IconButton(
            icon: Icon(Icons.search),
            onPressed: ()  async{
              try {
                if(_controller.text.isEmpty){
                  throw new Exception("Please enter a search term");
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()),));
                return;
              }
           try {
             setState(() {
                isSearching = true;
             });
             await widget.onSearch(_controller.text);

             setState(() {
                isSearching = false;
             });
            }
            on NotFoundException catch (e) {
                setState(() {
                isSearching = false;
                _controller.clear();
                });
             showDialog(context: context, builder: (context){
                return AlertDialog(
                  title: Text("Not Found"),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, child: Text("OK"))
                  ],
                );
              });



                 }
            catch (e) {
              setState(() {
                isSearching = false;
                _controller.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()),));

            }
            },
          ): CircularProgressIndicator(),
          if(widget.advanceSearch) IconButton(
            icon: Icon(Icons.manage_search, size: 30
    ),
            onPressed: (){
              if(!isSearching){
                widget.onAdvanceSearch!();
              }
            },
          )
        ],
      ),
    );
  }
}