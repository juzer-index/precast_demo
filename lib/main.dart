import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loginPage.dart';
import 'themeData.dart';
import 'dart:io';
import 'Providers/UserManagement.dart';
import 'Providers/tenantConfig.dart';
import './Models/LoadData.dart';
import 'Providers/LoadProvider.dart';
import 'Providers/ArchitectureProvider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io show HttpOverrides, SecurityContext, HttpClient;
import 'package:flutter/foundation.dart'; // for kIsWeb
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    io.HttpOverrides.global = MyHttpOverrides();
    final context = io.SecurityContext.defaultContext;
    context.allowLegacyUnsafeRenegotiation = true;
    final httpClient = io.HttpClient(context: context);
  }

  await dotenv.load(fileName: "android/app/profile/.env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserManagementProvider()),
        ChangeNotifierProvider(create: (context) => tenantConfigProvider()),
        ChangeNotifierProvider(create: (context) => ArchitectureProvider()),
        ChangeNotifierProvider(create: (context) => LoadProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
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