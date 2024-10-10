import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'loginPage.dart';
import 'themeData.dart';
import 'dart:io';
import 'Providers/UserManagement.dart';
import 'Providers/tenantConfig.dart';
import './HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'Providers/UserManagement.dart';
import 'Models/UserManagement.dart';
import 'Providers/tenantConfig.dart';

// Future<void> isLogged() async {
//
//   SharedPreferences prefs =  await  SharedPreferences.getInstance();
//   if(prefs.containsKey('userManagement') && prefs.containsKey('tenantConfig')){
//     UserManagement userManagement = UserManagement.fromJson(json.decode(prefs.getString('userManagement')!)!);
//     context.read<UserManagementProvider>().updateUserManagement(userManagement!);
//     context.read<tenantConfigProvider>().updateTenantConfig(json.decode(prefs.getString('tenantConfig')!));
//     tenantConfig = json.decode(prefs.getString('tenantConfig')!);
//     if (mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage(tenantConfig: tenantConfig,)),
//       );
//
//     }
//   }
// }
void main() {
  HttpOverrides.global = MyHttpOverrides();
  final context = SecurityContext.defaultContext;
  context.allowLegacyUnsafeRenegotiation = true;
  final httpClient = HttpClient(context: context);

  runApp(MultiProvider(providers:[
    ChangeNotifierProvider(create: (context)=>UserManagementProvider(),
   ),
    ChangeNotifierProvider(create: (context)=>tenantConfigProvider(),
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
  SharedPreferences? prefs;
  dynamic tenantConfig;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // Handle error, return an error widget if necessary
            return Text('Error: ${snapshot.error}');
          }

          final prefs = snapshot.data;
          if (prefs != null && prefs.containsKey('userManagement') && prefs.containsKey('tenantConfig')) {
            // Parse userManagement and tenantConfig from SharedPreferences
            UserManagement userManagement = UserManagement.fromJson(json.decode(prefs.getString('userManagement')!));
            tenantConfig = json.decode(prefs.getString('tenantConfig')!);

            // Ensure the widget is still mounted before updating providers
            if (mounted) {
              context.read<UserManagementProvider>().updateUserManagement(userManagement);
              context.read<tenantConfigProvider>().updateTenantConfig(tenantConfig);

              return MaterialApp(
                title: 'Precast Demo',
                theme: myTheme,
                debugShowCheckedModeBanner: false,
                home: HomePage(
                  tenantConfig: tenantConfig,
                ),
              );
            }
          }

          // If keys are missing or widget is not mounted, return LoginPage
          return MaterialApp(
            title: 'Precast Demo',
            theme: myTheme,
            debugShowCheckedModeBanner: false,
            home: const LoginPage(),
          );
        } else {
          // While waiting for the future to complete, display a loading indicator
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

}

