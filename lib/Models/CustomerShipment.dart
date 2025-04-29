class CustomerShipment {
  String Company;
  int PackNum;

  int OrderNum;
  int OrderLine;
  int OrderRelNum;
  int CustNum;
  String LineDesc;
  String JobNum ;
  String WarehouseCode;
  String BinNum;
  String IUM;
  String RevisionNum;
  String partNum;
  String jobLotNum;


  CustomerShipment({
    required this.Company
    , required this.PackNum

    , required this.OrderNum
    , required this.OrderLine
    , required this.OrderRelNum
    , required this.CustNum
    , required this.LineDesc
    , this.JobNum=""
    , this.WarehouseCode=""
    , this.BinNum=""
    , this.IUM=""
    , this.RevisionNum=""
    , required this.partNum
    , required this.jobLotNum


  });
  factory CustomerShipment.fromJson(Map<String, dynamic> json) {
    return CustomerShipment(
      Company: json['Company'],
      PackNum: int.parse(json['PackNum']),

      OrderNum: int.parse(json['OrderNum']),
      OrderLine: int.parse(json['OrderLine']),
      OrderRelNum: int.parse(json['OrderRelNum']),
      CustNum: int.parse(json['CustNum']),
      LineDesc: json['LineDesc'],
      JobNum: json['JobNum'] ?? "",
      WarehouseCode: json['WarehouseCode'] ?? "",
      BinNum: json['BinNum'] ?? "",
      IUM: json['IUM'] ?? "",
      RevisionNum: json['RevisionNum'] ?? "",
      partNum: json['PartNum'] ?? "",
      jobLotNum: json['JobLotNum'] ?? "",

    );
  }
  toJson() {
    return {
      "Company": Company,
      "PackNum": PackNum,

      "OrderNum": OrderNum,
      "OrderLine": OrderLine,
      "OrderRelNum": OrderRelNum,
      "CustNum": CustNum,
      "LineDesc": LineDesc,
      "JobNum": JobNum,
      "WarehouseCode": WarehouseCode,
      "BinNum": BinNum,
      "IUM": IUM,
      "RevisionNum": RevisionNum,
      "PartNum": partNum,
      "JobLotNum": jobLotNum,
      "CurrencyCode": "USD",
      "OrderNumCurrencyCode": "USD",

    };
  }
}