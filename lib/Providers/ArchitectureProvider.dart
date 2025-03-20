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
    custNum=0;
    selectedLine=0;
    selectedShipment="";
    CustomerId="";
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
  int custNum=0;
  int get cust => custNum;
  updateCust(int value) {
    custNum = value;
    notifyListeners();
  }
  int selectedLine=0;
  int get line => selectedLine;
  updateLine(int value) {
    selectedLine = value;
    notifyListeners();
  }
  String selectedShipment="";
  String get shipment => selectedShipment;
  updateShipment(String value) {
    selectedShipment = value;
    notifyListeners();
  }
  String CustomerId="";
  String get customerId => CustomerId;
  updateCustId(String value) {
    CustomerId = value;
    notifyListeners();
  }
}