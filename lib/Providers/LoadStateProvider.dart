import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class loadStateProvider extends ChangeNotifier {
 String? currentLoad=null;
  String? get currentLoadState => currentLoad;
  bool loadCreated = false;
  bool linesLoaded = false;
  bool delivered = false;

  void setCurrentLoad(String? load) {
    currentLoad = load;
    notifyListeners();
  }
  void setLoadCreated(bool value) {
    loadCreated = value;
    notifyListeners();
  }
  void setLinesLoaded(bool value) {
    linesLoaded = value;
    notifyListeners();
  }
  void setDelivered(bool value) {
    delivered = value;
    notifyListeners();
  }

  void clearCurrentLoad() {
    currentLoad = null;
    loadCreated = false;
    linesLoaded = false;
    notifyListeners();
  }
}