

import 'package:flutter/material.dart';


class IndexTable extends StatelessWidget {
   List<DataRow> data;
  final List<DataColumn> columns;
   Function(int)? onRowTap;

   IndexTable({super.key, required this.data, required this.columns, onRowTap=null    });

  @override
  Widget build(BuildContext context) {
    if(onRowTap != null){
    data=data.asMap().entries.map((entry) {
      int idx = entry.key;
      DataRow row = entry.value;
      return DataRow(
        cells: row.cells,

      );
    }).toList();

    }
    return Container(

      child: Column(

        children: [
          DataTable(
                columns: columns,
            rows: data

          ),

        ],
      ),
    );
  }
}