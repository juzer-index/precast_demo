import 'Package:flutter/material.dart';
import 'Package:provider/provider.dart';
class ArchitectureProvider extends ChangeNotifier {
  ArchitectureProvider();
  init(){
    _architecure='SO';
    Project="";
    SO=0;
    Lines=null;
    customerShipments=null;
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
    Lines=null;

    notifyListeners();
  }
 dynamic Lines=null;
dynamic get lines => Lines;
setLines(dynamic value) {
    Lines = value;
    notifyListeners();
  }
  dynamic get architecure => _architecure;
  void toggleArchitecure() {
    _architecure = _architecure == 'SO' ? 'Project' : 'SO';
    Project="";
    SO=0;
    Lines=null;
    notifyListeners();
  }
  dynamic customerShipments=null;
  dynamic get shipments => customerShipments;
  setShipments(dynamic value) {
    customerShipments = value;
    notifyListeners();
  }
}