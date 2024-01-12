import 'package:flutter/material.dart';
import 'element_model.dart';

class ElementTable extends StatefulWidget {
  List<ElementData> selectedElements = [];
  ElementTable({super.key, required this.selectedElements});

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
            DataColumn(label: Text('Element Description')),
            DataColumn(label: Text('Erection Seq')),
          ],
          rows: widget.selectedElements
              .map((row) => DataRow(cells: [
            DataCell(Text(row.elementId)),
            DataCell(Text(row.elementDesc)),
            DataCell(Text(row.erectionSeq)),
          ]))
              .toList(),
        ),
      ),
    );
  }
}
