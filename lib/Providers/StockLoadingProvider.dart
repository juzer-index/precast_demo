import 'package:flutter/material.dart';
import '../Models/Warehouse.dart';
import '../project_model.dart';
import '../truck_model.dart';

class StockLoadingProvider with ChangeNotifier {
  List<Warehouse> _warehouses = [];
  List<Warehouse> get warehouses => _warehouses;

  List<ProjectDetails> _projects = [];
  List<ProjectDetails> get projects => _projects;

  List<TruckDetails> _trucks = [];
  List<TruckDetails> get trucks => _trucks;
}
