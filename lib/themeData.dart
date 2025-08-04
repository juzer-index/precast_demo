import 'package:flutter/material.dart';


final ThemeData myTheme = ThemeData(
  // Define your theme properties her

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF55C9F4),
    selectionColor: Color(0xFF2BBCF2),
    selectionHandleColor: Color(0xFF2BBCF2),
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color:Color(0xFF55C9F4),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.all<Color>(Color(0xFF80D7F7)), // Set the fill color
    // You can add more properties here to customize the radio button style
  ),

  primaryColor:  Color(0xFF55C9F4),
  shadowColor: Color(0xFFEFEFEF),
  dividerColor: Colors.transparent,
  indicatorColor: Color(0xFFAAE4FA),
  scaffoldBackgroundColor:Color(0xFFB5B5B5),
  canvasColor: Color(0xFF00AEEF),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(
        Color(0xFF00AEEF),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(

    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFF00AEEF),
      ),

    ),
    floatingLabelStyle: TextStyle(
      color:Color(0xFF00AEEF),
    ),
    hintStyle: TextStyle(
      color: Color(0xFF00AEEF),
    ),
  ),
  tabBarTheme: TabBarTheme(
    // Set the indicator color to change the active tab color globally
    indicatorColor: Color(0xFF00AEEF),
    labelStyle: TextStyle(
      color: Color(0xFFFFFFFF),
    ),
  ),
  secondaryHeaderColor: Color(0xFF00AEEF),


  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.white,


      ),



      backgroundColor: MaterialStateProperty.all<Color>(
          Color(0xFF00AEEF)
      ),
      textStyle: MaterialStateProperty.all<TextStyle>(
        TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(
        Color(0xFF00AEEF),
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF55C9F4),
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 25,
    ),
 iconTheme: IconThemeData(
      color: Colors.white,
    ),
  ),
  // ... other theme properties
);
