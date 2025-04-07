import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loginPage.dart';
import 'themeData.dart';
import 'dart:io';
import 'Providers/UserManagement.dart';
import 'Providers/tenantConfig.dart';
import 'Providers/ArchitectureProvider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  final context = SecurityContext.defaultContext;
  context.allowLegacyUnsafeRenegotiation = true;
  final httpClient = HttpClient(context: context);
  await dotenv.load(fileName: "android/app/profile/.env");
  runApp(MultiProvider(providers:[
    ChangeNotifierProvider(create: (context)=>UserManagementProvider(),
   ),
    ChangeNotifierProvider(create: (context)=>tenantConfigProvider(),
    ),
    ChangeNotifierProvider(create: (context)=>ArchitectureProvider(),
    ),




    
  ], child:MyApp()));
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {

  @override
  void initState()  {


    super.initState();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Precast Demo',
      theme: myTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

