
class CustomerShipment {
String Company;
int PackNum;
int OrderNum;
int OrderLine;
int OrderRelNum;
int CustNum;
String LineDesc;
String JobNum;
String WarehouseCode;
String BinNum;
String IUM;
String RevisionNum;
String partNum;
String LotNum;
String LineType;
int OurInventoryShipQty = 1;
bool ShipCmpl;
int Packages = 1;
double SellingInventoryShipQty = 1.0;
double SellingFactor = 1.0;
String SalesUM;
double PickedAutoAllocatedQty = 1.0;
String ShipToNum;
String InventoryShipUOM;
String JobShipUOM;
double PartNumSellingFactor = 1.0;
String PartNumSalesUM;
String PartNumIUM;
bool PartNumTrackLots;
int MFCustNum;
String MFShipToNum;
double SellingReqQty = 1.0;
String SellingReqUM;
double SellingShipmentQty = 1.0;
String SellingShipmentUM;
double SellingShippedQty = 1.0;
String SellingShippedUM;
double OurReqQty = 1.0;
String OurReqUM;
double OurShippedQty = 1.0;
String OurShippedUM;
double DisplayInvQty = 1.0;

CustomerShipment({
required this.Company,
required this.PackNum,
required this.OrderNum,
required this.OrderLine,
required this.OrderRelNum,
required this.CustNum,
required this.LineDesc,
this.JobNum = "",
this.WarehouseCode = "",
this.BinNum = "",
this.IUM = "",
this.RevisionNum = "",
required this.partNum,
required this.LotNum,
required this.LineType,
required this.ShipCmpl,
required this.ShipToNum,
required this.InventoryShipUOM,
required this.JobShipUOM,
required this.PartNumSalesUM,
required this.SalesUM,
required this.PartNumIUM ,
required this.PartNumTrackLots ,
required this.MFCustNum ,
required this.MFShipToNum ,
required this.SellingReqUM,
required this.SellingShipmentUM ,
required this.SellingShippedUM ,
required this.OurReqUM ,
required this.OurShippedUM ,
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
LotNum: json['LotNum'] ?? "",
LineType: json['LineType'] ?? "",
ShipCmpl: json['ShipCmpl'] ?? false,
ShipToNum: json['ShipToNum'] ?? "",
InventoryShipUOM: json['InventoryShipUOM'] ?? "",
JobShipUOM: json['JobShipUOM'] ?? "",
PartNumSalesUM: json['PartNumSalesUM'] ?? "",
SalesUM: json['SalesUM'] ?? "",
PartNumIUM: json['PartNumIUM'] ?? "",
PartNumTrackLots: json['PartNumTrackLots'] ?? "",
MFCustNum: int.parse(json['MFCustNum'] ?? '0'),
MFShipToNum: json['MFShipToNum'] ?? "",
SellingReqUM: json['SellingReqUM'] ?? "",
SellingShipmentUM: json['SellingShipmentUM'] ?? "",
SellingShippedUM: json['SellingShippedUM'] ?? "",
OurReqUM: json['OurReqUM'] ?? "",
OurShippedUM: json['OurShippedUM'] ?? "",
);
}

Map<String, dynamic> toJson() {
  return {
    "Company": Company,
    "PackNum": PackNum.toString(),
    "OrderNum": OrderNum.toString(),
    "OrderLine": OrderLine.toString(),
    "OrderRelNum": OrderRelNum.toString(),
    "CustNum": CustNum.toString(),
    "LineDesc": LineDesc,
    "JobNum": JobNum,
    "WarehouseCode": WarehouseCode,
    "BinNum": BinNum,
    "IUM": IUM,
    "RevisionNum": RevisionNum,
    "PartNum": partNum,
    "LotNum": LotNum,
    "LineType": LineType,
    "ShipCmpl": ShipCmpl.toString(),
    "ShipToNum": ShipToNum,
    "InventoryShipUOM": InventoryShipUOM,
    "JobShipUOM": JobShipUOM,
    "PartNumSalesUM": PartNumSalesUM,
    "SalesUM": SalesUM,
    "PartNumIUM": PartNumIUM,
    "PartNumTrackLots": PartNumTrackLots.toString(),
    "MFCustNum": MFCustNum.toString(),
    "MFShipToNum": MFShipToNum,
    "SellingReqUM": SellingReqUM,
    "SellingShipmentUM": SellingShipmentUM,
    "SellingShippedUM": SellingShippedUM,
    "OurReqUM": OurReqUM,
    "OurShippedUM": OurShippedUM,
    "DisplayInvQty": DisplayInvQty.toString(),
    "PickedAutoAllocatedQty": PickedAutoAllocatedQty.toString(),
  };
}
}

