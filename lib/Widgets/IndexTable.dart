import 'package:flutter/material.dart';


class IndexTable extends StatelessWidget {
  final List<DataRow> data;
  final List<DataColumn> columns;
  final Function(int) onRowTap;

   IndexTable({super.key, required this.data, required this.columns, required this.onRowTap});

  @override
  Widget build(BuildContext context) {
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