import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'Providers/UserManagement.dart';
import 'Models/UserManagement.dart';
import 'Providers/tenantConfig.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();


}

class _LoginPageState extends State<LoginPage> {
  String username = '' ;
  String password = '';
  String tenantId = '';

  dynamic TenantConfig;
  bool RememberMe=false ;
  bool isLoading = false;
  bool Checked = false;
  SharedPreferences? prefs;
  Future<void> login() async {
    if(username.isNotEmpty && password.isNotEmpty && tenantId.isNotEmpty){
      setState(() {
        isLoading = true;
      });

    var url = Uri.parse('https://77.92.189.106:83/Account/${tenantId}/Login');
      var response =  http.MultipartRequest('POST', url);
      response.fields['username'] = username;
      response.fields['password'] = password;
      response.fields['tenantId'] = tenantId;
      var res = await response.send();
      setState(() {
        isLoading = false;

      });

      if(res.statusCode == 200){
        var responseData= json.decode(await res.stream.bytesToString());
        var userManagement = responseData['message']['userManagement'];
        var tenantConfig = responseData['message']['tenantConfig'];
        SharedPreferences prefs =  await  SharedPreferences.getInstance();
        if(RememberMe) {
          prefs.setString('userManagement', json.encode(userManagement));
          prefs.setString('tenantConfig', json.encode(tenantConfig));

          context.read<UserManagementProvider>().updateUserManagement(UserManagement.fromJson(userManagement)!);
          context.read<tenantConfigProvider>().updateTenantConfig(tenantConfig);
        }
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
      else if(res.statusCode == 500){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server Error'),
          ),
        );
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Credentials'),
          ),
        );
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Credentials'),
        ),
      );
    }
  }
  isLogged() async {

    SharedPreferences prefs =  await  SharedPreferences.getInstance();
    if(prefs.containsKey('userManagement') && prefs.containsKey('tenantConfig')){
      UserManagement userManagement = UserManagement.fromJson(json.decode(prefs.getString('userManagement')!));
      context.read<UserManagementProvider>().updateUserManagement(userManagement!);
      context.read<tenantConfigProvider>().updateTenantConfig(json.decode(prefs.getString('tenantConfig')!));
      if (mounted) {
       Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

      }
    }
  }
  @override
  void initState() {
    super.initState();
    isLogged();

  }


  @override
  Widget build(BuildContext context) {
    var Imagepath = 'assets/Index-Logo.jpg';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            'IIT Precast App',
            style: TextStyle(
                color: Colors.lightBlue,
                fontSize: 20 , fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      Imagepath,
                      width: 150,
                      height: 150,
                    ),
                  ),
                  Card(
                    child: Container(
                      alignment: Alignment.center,
                      height: 350,
                      width: 375,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),

                      child: isLoading ? const CircularProgressIndicator() :
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Username"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  username = value;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextFormField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Password"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Your Password';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Tenant ID"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Your Tenant ID';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  tenantId = value;
                                });
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 8.0),
                            height: 40,
                            alignment: Alignment.centerLeft,

                          child:
                          Row( children:[Checkbox(value: RememberMe , onChanged: (bool?value) {
                            if(value != null)
                            setState(() {
                              RememberMe = value;
                            });
                          },
                          fillColor: RememberMe?MaterialStateProperty.all<Color>(Theme.of(context).primaryColor):MaterialStateProperty.all<Color>(Colors.white),
                          ),Text('Remember Me')]),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              login();
                            },
                            //style: ElevatedButton.styleFrom(
                            //  backgroundColor: Colors.blueGrey),
                            child: const Text('Login'
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  ),




                ],
              ),

            ),
          ),
        ),
      ),
    );
  }
}
