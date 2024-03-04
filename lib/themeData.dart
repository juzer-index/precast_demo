import 'package:flutter/material.dart';


final ThemeData myTheme = ThemeData(
  // Define your theme properties here
  primaryColor: Colors.blue.shade300,
  dividerColor: Colors.transparent,
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.blue.shade300,
      ),

    ),
    floatingLabelStyle: TextStyle(
      color: Colors.blue.shade800,
    ),
  ),
  tabBarTheme: TabBarTheme(
    // Set the indicator color to change the active tab color globally
    indicatorColor: Colors.blue.shade800,
    labelStyle: TextStyle(
      color: Colors.blue.shade800,
    ),
  ),
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
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.white,


    ),


      backgroundColor: MaterialStateProperty.all<Color>(
        Colors.blue.shade300,
      ),
      textStyle: MaterialStateProperty.all<TextStyle>(
        TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    ),
  ),
  // ... other theme properties
);
