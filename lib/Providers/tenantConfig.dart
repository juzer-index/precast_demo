import 'package:flutter/cupertino.dart';
class tenantConfigProvider extends ChangeNotifier {
  tenantConfigProvider();

  dynamic _tenantConfig;

  dynamic get tenantConfig => _tenantConfig;

  void updateTenantConfig(dynamic tenantConfig) {
    _tenantConfig = tenantConfig;
    notifyListeners();
  }
}