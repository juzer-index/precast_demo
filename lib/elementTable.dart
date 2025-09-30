import 'package:flutter/material.dart';
import 'element_model.dart';
import '../Widgets/essentials.dart';
class ElementTable extends StatefulWidget {
  List<ElementData> selectedElements = [];
  bool isOffloading=false;
  dynamic DeletededSaveElements=[];
  Function(List<ElementData>)? onElementsChanged;
  ElementTable({super.key, required this.selectedElements,
    this.DeletededSaveElements,this.isOffloading=false
    ,  this.onElementsChanged
  });

  @override
  State<ElementTable> createState() => _ElementTableState();
}

class _ElementTableState extends State<ElementTable> {


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns:  [
            if(widget.isOffloading)DataColumn(label: Text('Received')),
            DataColumn(label: Text('Structure ID')),
            DataColumn(label: Text('Part Number')),
            DataColumn(label: Text('Erection Seq')),
            if(!widget.isOffloading)DataColumn(label: Text('Actions')),
          ],
          rows: widget.selectedElements
              .map((row) => DataRow(cells: [
            if(widget.isOffloading)DataCell(
              Checkbox(
                activeColor: row.isRecieved?Theme.of(context).primaryColor:Colors.grey,
                value:row.isRecieved,
                onChanged: (bool? newValue) {
                  setState(() {
                    widget.selectedElements[widget.selectedElements.indexOf(row)].isRecieved = newValue ?? false;

                    widget.onElementsChanged!(widget.selectedElements);
                  });
                },
              ),
            ),
            DataCell(Text(row.elementId)),
            DataCell(Text(row.partId)),
            DataCell(Text(row.erectionSeq.toString())),
            if(!widget.isOffloading)DataCell(
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    widget.selectedElements.remove(row);
                    widget.onElementsChanged!(widget.selectedElements);
                  });
                },
              ),
            ),
          ]))
              .toList(),
        ),
      ),
    );
  }
}
