import 'package:flutter/material.dart';


class IndexTable extends StatelessWidget {
  final List<DataRow> data;
  final List<DataColumn> columns;
  final Function(int) onRowTap;

  const IndexTable({super.key, required this.data, required this.columns, required this.onRowTap});

  @override
  Widget build(BuildContext context) {
    return DataTable(
          columns: columns,
      rows: data
    );
  }
}