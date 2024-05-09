import 'package:flutter/material.dart';

class BottomRightText extends StatelessWidget {
  final String text;

  const BottomRightText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
