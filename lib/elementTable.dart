import 'package:flutter/material.dart';
import 'element_model.dart';

class ElementTable extends StatefulWidget {
  List<ElementData> selectedElements = [];
  dynamic DeletededSaveElements=[];
  ElementTable({super.key, required this.selectedElements,this.DeletededSaveElements});

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
          columns: const [
            DataColumn(label: Text('Element ID')),
            DataColumn(label: Text('Part Number')),
            DataColumn(label: Text('Erection Seq')),
            DataColumn(label: Text('Actions')),
          ],
          rows: widget.selectedElements
              .map((row) => DataRow(cells: [
            DataCell(Text(row.elementId)),
            DataCell(Text(row.partId)),
            DataCell(Text(row.erectionSeq)),
            DataCell(IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  widget.selectedElements.remove(row);
                  if(widget.DeletededSaveElements!=null){
                    widget.DeletededSaveElements.add(row.ChildKey1);
                  }
                });
              },
            )),
          ]))
              .toList(),
        ),
      ),
    );
  }
}
