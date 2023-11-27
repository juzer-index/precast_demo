import 'package:flutter/material.dart';

import 'loginPage.dart';
import 'themeData.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Precast Demo',
      theme: myTheme,
      home: const LoginPage(),
    );
  }
}

