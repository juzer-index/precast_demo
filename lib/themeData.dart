import 'package:flutter/material.dart';


final ThemeData myTheme = ThemeData(
  // Define your theme properties her

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF7CC95D),
    selectionColor: Color(0xFF7CC95D),
    selectionHandleColor: Color(0xFF7CC95D),
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color:Color(0xFF7CC95D),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.all<Color>(Color(0xFF7CC95D)), // Set the fill color
    // You can add more properties here to customize the radio button style
  ),

  primaryColor:  Color(0xFF7CC95D),
 shadowColor: Color(0xFFEFEFEF),
  dividerColor: Colors.transparent,
  indicatorColor: Color(0xFFD4E7CC),
  scaffoldBackgroundColor:Color(0xFFB5B5B5),
  canvasColor: Color(0xFF5E9746),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(
        Color(0xFF5E9746),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(

    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFF5E9746),
      ),

    ),
    floatingLabelStyle: TextStyle(
      color:Color(0xFF5E9746),
    ),
    hintStyle: TextStyle(
      color: Color(0xFF5E9746),
    ),
  ),
  tabBarTheme: TabBarTheme(
    // Set the indicator color to change the active tab color globally
    indicatorColor: Color(0xFF5E9746),
    labelStyle: TextStyle(
      color: Color(0xFFFFFFFF),
    ),
  ),
  secondaryHeaderColor: Color(0xFF5E9746),


  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.white,


    ),



      backgroundColor: MaterialStateProperty.all<Color>(
          Color(0xFF7CC95D)
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
