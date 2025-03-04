import 'Package:flutter/material.dart';
import 'Package:provider/provider.dart';
class ArchitectureProvider extends ChangeNotifier {
  ArchitectureProvider();
  init(){
    _architecure='SO';
    Project="";
    SO=0;
    Line=0;
    notifyListeners();
  }
  String _architecure='SO';
  String Project="";
  String get project => Project;
  set project(String value) {
    Project = value;
    notifyListeners();
  }
  int SO=0;
  int get so => SO;
 updateSO(int value) {
    SO = value;
    notifyListeners();
  }
  int Line=0;
  int get line => Line;
  set line(int value) {
    Line = value;
    notifyListeners();
  }
  dynamic get architecure => _architecure;
  void toggleArchitecure() {
    _architecure = _architecure == 'SO' ? 'Project' : 'SO';
    Project="";
    SO=0;
    Line=0;
    notifyListeners();
  }
}