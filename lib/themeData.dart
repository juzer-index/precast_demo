import 'package:flutter/material.dart';


final ThemeData myTheme = ThemeData(
  // Define your theme properties her

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.blue,
    selectionColor: Colors.blue,
    selectionHandleColor: Colors.blue,
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Colors.blue,
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.all<Color>(Colors.blue), // Set the fill color
    // You can add more properties here to customize the radio button style
  ),

  primaryColor:  Color.fromRGBO(1, 176, 241, 1.0),
  dividerColor: Colors.transparent,
  indicatorColor: Colors.blue.shade300,


  inputDecorationTheme: InputDecorationTheme(

    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.blue.shade300,
      ),

    ),
    floatingLabelStyle: TextStyle(
      color: Colors.blue.shade800,
    ),
    hintStyle: TextStyle(
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
        Color.fromRGBO(1, 176, 241, 1.0),
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
