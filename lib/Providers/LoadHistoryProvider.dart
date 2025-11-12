import 'package:flutter/material.dart';
import '../load_model.dart';

class LoadHistoryProvider extends ChangeNotifier {
  List<LoadData> _sessionLoads = [];

  List<LoadData> get sessionLoads => _sessionLoads;

  // Add a new load to the session history
  void addLoad(LoadData load) {
    // Check if load already exists and update it
    final existingIndex = _sessionLoads.indexWhere((l) => l.loadID == load.loadID);

    if (existingIndex != -1) {
      // Update existing load
      _sessionLoads[existingIndex] = load;
    } else {
      // Add new load
      _sessionLoads.add(load);
    }

    notifyListeners();
  }

  // Remove a load from session history
  void removeLoad(String loadID) {
    _sessionLoads.removeWhere((load) => load.loadID == loadID);
    notifyListeners();
  }

  // Clear all session loads
  void clearAllLoads() {
    _sessionLoads.clear();
    notifyListeners();
  }

  // Get a specific load by ID
  LoadData? getLoadByID(String loadID) {
    try {
      return _sessionLoads.firstWhere((load) => load.loadID == loadID);
    } catch (e) {
      return null;
    }
  }

  // Get count of loads in session
  int get loadCount => _sessionLoads.length;
}

