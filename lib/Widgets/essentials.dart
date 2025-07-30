import 'package:flutter/material.dart';


class IndexCheckBox extends StatefulWidget {
  bool value;

  IndexCheckBox({this.value = false,

  });
  @override
  State<IndexCheckBox> createState() => _IndexCheckBoxState();


}
class _IndexCheckBoxState extends State<IndexCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      activeColor: Theme.of(context).primaryColor,
      value: widget.value,
      onChanged: (bool? newValue) {
        setState(() {
          widget.value = newValue ?? false;
        });

      },

    );
  }
}