class SalesOrderLine {
  int OrderNumber;
  int OrderLine;
  String PartNum;
  String LineDesc;
  String IUM;
 String RevisionNum;
  String OrderQty;
  String UnitPrice;
  SalesOrderLine({
    required this.OrderNumber,
    required this.OrderLine,
    required this.PartNum,
    required this.LineDesc,
    required this.IUM,
    required this.RevisionNum,
    required this.OrderQty,
    required this.UnitPrice,
  });
  factory SalesOrderLine.fromJson(Map<String, dynamic> json) {
    return SalesOrderLine(
      OrderNumber: json['OrderNumber'],
      OrderLine: json['OrderLine'],
      PartNum: json['PartNum'],
      LineDesc: json['LineDesc'],
      IUM: json['IUM'],
      RevisionNum: json['RevisionNum'],
      OrderQty: json['OrderQty'],
      UnitPrice: json['UnitPrice'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'OrderNumber': OrderNumber,
      'OrderLine': OrderLine,
      'PartNum': PartNum,
      'LineDesc': LineDesc,
      'IUM': IUM,
      'RevisionNum': RevisionNum,
      'OrderQty': OrderQty,
      'UnitPrice': UnitPrice,
    };
  }

}