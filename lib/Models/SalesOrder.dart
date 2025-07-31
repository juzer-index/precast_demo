import './OrderLine.dart';
class SalesOrder {
  String Company;
  int OrderNum;
  int CustNum;
  String ShipToNum;
  String OrderDate;
  String ShipViaCode;
  String TermsCode;
  List<SalesOrderLine> OrderLines = [];
  set orderLines(List<SalesOrderLine> value) {
    OrderLines = value;
  }
  SalesOrder({
    required this.Company,
    required this.OrderNum,
    required this.CustNum,
    required this.ShipToNum,
    required this.OrderDate,
    required this.ShipViaCode,
    required this.TermsCode,
  });
  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      Company: json['Company'],
      OrderNum: json['OrderNum'],
      CustNum: json['CustNum'],
      ShipToNum: json['ShipToNum'],
      OrderDate: json['OrderDate'],
      ShipViaCode: json['ShipViaCode'],
      TermsCode: json['TermsCode'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'Company': Company,
      'OrderNum': OrderNum,
      'CustNum': CustNum,
      'ShipToNum': ShipToNum,
      'OrderDate': OrderDate,
      'ShipViaCode': ShipViaCode,
      'TermsCode': TermsCode,
    };
  }

}