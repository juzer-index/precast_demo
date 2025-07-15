import 'package:flutter/cupertino.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class ReDropDown extends StatefulWidget {
  final bool enabled;
  final List<dynamic> data;
  final String label;
  TextEditingController controller = TextEditingController();
  List<dynamic> dataMap;
  bool loading = false;
  Function? onChnaged;
  String value = '';
  ReDropDown({super.key, required this.enabled, required this.data, required this.label , required this.controller , required this.dataMap,required this.loading, this.onChnaged= null});

  @override
  State<StatefulWidget> createState() {
    return _DropDownState();
  }
}

class _DropDownState extends State<ReDropDown> {

//   bool isLoading = false;
//
//   @override
//   void didUpdateWidget(covariant ReDropDown oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Check if the data has changed and reset the selected item
//
//     if(widget.loading){
//       setState(() {
//         isLoading = true;
//         widget.controller.text = '';
//       });
// }else{
//       setState(() {
//         isLoading = false;
//       });
//
//   }}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          DropdownSearch<dynamic>(
            selectedItem: widget.controller.text,
            enabled: widget.enabled,
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
            onChanged: widget.onChnaged==null? (value) {
             dynamic element= widget.dataMap.where((element) => element['Description'] == value).first;
              setState(() {
                widget.controller.text =element['BinNum'];
              });
            }:widget.onChnaged as void Function(dynamic),
          ),
          Builder(
            builder: (context) {
              if (widget.loading) {
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
