import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(
  // Define your theme properties here
  primaryColor: Colors.blue.shade300,
  dividerColor: Colors.transparent,
  secondaryHeaderColor: Colors.grey.shade800,
  textTheme: TextTheme(
    labelMedium: TextStyle(
      color: Colors.blueGrey.shade800,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: const TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.normal,
    ),
  ),
  // ... other theme properties
);
