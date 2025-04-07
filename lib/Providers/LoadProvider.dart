import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../Models/LoadData.dart';
class LoadProvider extends ChangeNotifier {
LoadData? _load;
  LoadProvider() {
    _load = new LoadData();
  }
  LoadData? get load => _load;
  UpdateLoad(LoadData value) {
    _load = value;
    notifyListeners();
  }
  void updateLoad(LoadData value) {
    _load = value;
    notifyListeners();
  }
  void clearLoad() {
    _load = new LoadData();
    notifyListeners();
  }



}
