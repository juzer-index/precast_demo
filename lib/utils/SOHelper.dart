import './APIProviderV2.dart';
import '../Models/NotFoundException.dart';

class SOHelper {
  static   Future<List<dynamic>?> getSalesOrderLines(int OrderNum, dynamic tenantConfig) async {

    try {
      var data = await APIV2Helper.getResults(
          '${tenantConfig['httpVerbKey']}://${tenantConfig['appPoolHost']}/${tenantConfig['appPoolInstance']}/api'
              '/v1/'
              'BaqSvc/IIT_OrderDtl/?OrderNum=$OrderNum'
              ' ',
          {
            'username': tenantConfig['userID'],
            'password': tenantConfig['password']
          }
      );
      return data;
    }
    on NotFoundException catch (e) {
      return [];
    }

  }
}