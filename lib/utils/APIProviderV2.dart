import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/NotFoundException.dart';
import '../Providers/tenantConfig.dart';

class APIV2Helper extends ChangeNotifier {
  APIV2Helper();
 static String _apiKey = dotenv.env['APIKEY']??'' ;


  static Future<List<dynamic>>getPaginatedResults(String url  ,int page , int pageSize,Map<String,String>auth,{bool hasVars=false,String entity=""}) async {
    int top = pageSize;
    int skip = (page - 1) * pageSize;
    String query = "\$top=$top&\$skip=$skip";
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('${auth['username']}:${auth['password']}'));
    var response = await http.get(Uri.parse(hasVars ? "$url&$query":"$url?$query"  ),
        headers: {

          "accept": "application/json",
          "x-api-key": "$_apiKey",
          "Authorization": basicAuth
        }
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body)['value'] as List<dynamic>;
    }
    else if (response.statusCode == 404) {
      throw new NotFoundException(entity: entity);
    }
    else {
      throw new Exception("Failed to load data");
    }
  }
  static Future<List<dynamic>>getResults(String url ,Map<String,String>auth,{String entity=""}) async {
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('${auth['username']}:${auth['password']}'));
    var response = await http.get(Uri.parse("$url"),
        headers: {

          "accept": "application/json",
          "x-api-key": "$_apiKey",
          "Authorization": basicAuth
        }
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body)['value'] as List<dynamic>;
    }
    else if (response.statusCode == 404) {
      throw new NotFoundException(entity: entity);
    }
    else {
      throw new Exception("Failed to load data");
    }
  }


}