import 'package:flutter/cupertino.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class ReDropDown extends StatefulWidget {
  final bool enabled;
  final List<dynamic> data;
  final String label;
  TextEditingController controller = TextEditingController();
  List<dynamic> dataMap;
  ReDropDown({super.key, required this.enabled, required this.data, required this.label , required this.controller , required this.dataMap});

  @override
  State<StatefulWidget> createState() {
    return _DropDownState();
  }
}

class _DropDownState extends State<ReDropDown> {

  bool isLoading = false;

  @override
  void didUpdateWidget(covariant ReDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the data has changed and reset the selected item

    if(widget.data.isEmpty&&widget.enabled){
      setState(() {
        isLoading = true;
        widget.controller.text = '';
      });
}else{
      setState(() {
        isLoading = false;
      });

  }}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          DropdownSearch(
            selectedItem: widget.controller.text ,
            enabled: widget.enabled&& !isLoading,
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
            autoValidateMode: AutovalidateMode.onUserInteraction,
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: widget.label,
              ),
            ),
            items: widget.data,
            onChanged: (value) {
             dynamic element= widget.dataMap.where((element) => element['Description'] == value).first;
              setState(() {
                widget.controller.text =element['BinNum'];
              });
            },
          ),
          Builder(
            builder: (context) {
              if (isLoading) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
