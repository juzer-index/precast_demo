import 'package:flutter/material.dart';
class DateRangeBar extends StatefulWidget {
  final DateTime initialFrom;
  final DateTime initialTo;
  final void Function(DateTime from, DateTime to) onSelect;
  bool disabled=false;
   DateRangeBar({
    super.key,
    required this.initialFrom,
    required this.initialTo,
    required this.onSelect,
    this.disabled=false
  });

  @override
  State<DateRangeBar> createState() => _DateRangeBarState();
}

class _DateRangeBarState extends State<DateRangeBar> {
  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();
    _from = widget.initialFrom;
    _to = widget.initialTo;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _from, end: _to),
      builder: (context, child) {
        // Use your app theme for the popup as well
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _from = result.start;
        _to = result.end;
      });
      widget.onSelect(_from, _to);
    }
  }

  String _fmt(DateTime dt) => "${dt.year}-${dt.month}-${dt.day}";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => {
        if(!widget.disabled){
         _selectDateRange(context)}},
      borderRadius: BorderRadius.circular( 8),
      child: Container(
        padding: theme.inputDecorationTheme.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

        decoration: BoxDecoration(

          borderRadius:
        BorderRadius.circular(8),
          border: Border.all(
          color: Theme.of(context).canvasColor
          ),
        ),

        child: Row(
          children: [
            Icon(
              Icons.date_range,
              size: theme.iconTheme.size,
              color: Theme.of(context).canvasColor,
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Text(
                "${_fmt(_from)} → ${_fmt(_to)}",
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Icon(
              Icons.arrow_drop_down,
              size: theme.iconTheme.size,
              color: Theme.of(context).canvasColor,

            ),
          ],
        ),
      ),
    );
  }
}
