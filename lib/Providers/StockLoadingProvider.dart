import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class StockLoadingProvider with ChangeNotifier {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoadingProjects = false;

  List<Map<String, dynamic>> get projects => _projects;
  bool get isLoadingProjects => _isLoadingProjects;

  Future<void> fetchProjects(dynamic tenantConfigP) async {
    _isLoadingProjects = true;
    notifyListeners();
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${tenantConfigP['userID']}:${tenantConfigP['password']}'))}';
    try {
      final response = await http.get(
          Uri.parse(
              '${tenantConfigP['httpVerbKey']}://${tenantConfigP['appPoolHost']}/${tenantConfigP['appPoolInstance']}/api/v1/Erp.Bo.ProjectSvc/List/'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      if (response.statusCode == 200) {
        final Map<String, dynamic> fetchedProjectData = json.decode(response.body);
        _projects = List<Map<String, dynamic>>.from(fetchedProjectData['value']);
        _isLoadingProjects = false;
        notifyListeners();
      } else {
        _isLoadingProjects = false;
        notifyListeners();
        throw Exception('Failed to load Project');
      }
    } on Exception catch (e) {
      _isLoadingProjects = false;
      notifyListeners();
      debugPrint(e.toString());
    }
  }

  void clearProjects() {
    _projects = [];
    notifyListeners();
  }
}
