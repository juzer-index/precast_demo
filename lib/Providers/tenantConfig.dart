import 'package:flutter/cupertino.dart';
class tenantConfigProvider extends ChangeNotifier {
  tenantConfigProvider();

  Map<String,dynamic> _tenantConfig={};

  Map<String,dynamic> get tenantConfig => _tenantConfig;

  void updateTenantConfig(dynamic tenantConfig) {
    _tenantConfig = tenantConfig;
    notifyListeners();
  }
}