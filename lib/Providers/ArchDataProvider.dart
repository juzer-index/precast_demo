import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class ArchitectureProvider extends ChangeNotifier {
  ArchitectureProvider();
  String _architecure='SO';
  dynamic get architecure => _architecure;
  void toggleArchitecure() {
    _architecure = _architecure == 'SO' ? 'Project' : 'SO';
    notifyListeners();
  }
}
