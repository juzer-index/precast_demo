import 'Package:flutter/material.dart';
import 'Package:provider/provider.dart';
class ArchitectureProvider extends ChangeNotifier {
  ArchitectureProvider();
  String _architecure='SO';
  dynamic get architecure => _architecure;
  void toggleArchitecure() {
    _architecure = _architecure == 'SO' ? 'Project' : 'SO';
    notifyListeners();
  }
}