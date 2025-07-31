import 'package:flutter/material.dart';
import 'part_model.dart';

class PartTable extends StatefulWidget {
  List<PartData> selectedParts = [];
  bool isOffloading = false;
  PartTable({super.key, required this.selectedParts, this.isOffloading = false});

  @override
  State<PartTable> createState() => _PartTableState();
}

class _PartTableState extends State<PartTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns:  [
            if(widget.isOffloading) DataColumn(label: Text('Recieved')),
            DataColumn(label: Text('Part Num')),
            DataColumn(label: Text('Part Description')),
            DataColumn(label: Text('UOM')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Actions')),
          ],
          rows: widget.selectedParts
              .map((row) => DataRow(cells: [
            if(widget.isOffloading) DataCell(
              Checkbox(
                value: row.isRecieved,
                onChanged: (value) {
                  setState(() {
                    row.isRecieved = value ?? false;
                  });
                },
              ),
            ),
            DataCell(Text(row.partNum)),
            DataCell(Text(row.partDesc)),
            DataCell(Text(row.uom)),
            DataCell(Text(row.qty)),
            DataCell(IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  widget.selectedParts.remove(row);
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
