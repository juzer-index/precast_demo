import 'element_model.dart';

class LoadData {
  late final String loadID;
  late final String projectId;
  late final String loadDate;
  late final String fromWarehouse;
  late final String toWarehouse;
  late final String toBin;
  late final String loadType;
  late final String loadCondition;
  late final String loadStatus;
  late final String truckId;
  late final String resourceId;
  late final String plateNumber;
  late final String driverName;
  late final String driverNumber;
  late final dynamic salesOrderNumber;
  late final dynamic salesOrderLine;
  late final dynamic resourceCapacity;
  late final dynamic resourceLoaded;
  late final dynamic resourceLength;
  late final dynamic resourceWidth;
  late final dynamic resourceHeight;
  late final dynamic resourceVolume;
  late final dynamic foremanId;
  late final dynamic foremanName;
  late final dynamic comments;
  late final dynamic createdBy;
  late final dynamic DeviceID;
  late final String projectOrSO;
  late final dynamic shipTo;
  String SO ="0";
  String CustomerId = "";
  String CustNum="0";

  List<ElementData> elements = []; // Add this line to store the list of elements

  LoadData({
    required this.loadID,
    required this.projectId,
    required this.loadDate,
    required this.fromWarehouse,
    required this.toWarehouse,
    required this.toBin,
    required this.loadType,
    required this.loadCondition,
    required this.loadStatus,
    required this.truckId,
    required this.resourceId,
    required this.plateNumber,
    required this.driverName,
    required this.driverNumber,
    this.salesOrderNumber,
    this.salesOrderLine,
    required this.resourceCapacity,
    required this.resourceLoaded,
    required this.resourceLength,
    required this.resourceWidth,
    required this.resourceHeight,
    required this.resourceVolume,
    required this.foremanId,
    required this.foremanName,
    required this.comments,
    this.createdBy,
    this.DeviceID,
    required this.projectOrSO,
    required this.shipTo,
    this.SO = "0",
    this.CustomerId = "",
    this.CustNum = "0",

    this.elements = const [], // Add this to the constructor parameters
  });

  factory LoadData.fromJson(Map<String, dynamic> json) {
    return LoadData(
      loadID: json['Key1'],
      projectId: json['Character10'],
      loadDate: json['Date01'] ?? '',
      fromWarehouse: json['Character06'],
      toWarehouse: json['Character04'],
      toBin: json['Character05'],
      loadType: json['ShortChar01'],
      loadCondition: json['ShortChar04'],
      loadStatus: json['ShortChar03'],
      truckId: json['ShortChar08'],
      resourceId: json['Character09'],
      plateNumber: json['ShortChar07'],
      driverName: json['Character02'],
      driverNumber: json['Character03'],
      resourceCapacity: json['Number06'],
      resourceLoaded: json['Number01'],
      resourceLength: json['Number10'],
      resourceWidth: json['Number09'],
      resourceHeight: json['Number08'],
      resourceVolume: json['Number07'],
      foremanId: json['EmployeeID_c'],
      foremanName: json['EmployeeName_c'],
      comments: json['Comments_c'],
      createdBy: json['CreatedBy_C'],
      DeviceID: json['Deviceid_c'],
      salesOrderNumber: json['Character07'],
      projectOrSO: json['ShortChar05'],
      shipTo: json['Character08'],
      SO: json['Character07'],
      CustomerId: json['Character04'],
      CustNum: json['Number12'] == null ? '0' : json['Number12'].toString()// Assuming this is the project or SO identifier
      // elements: [], // Initialize empty list when creating from JSON
    );
  }

  // factory LoadData.toJson(Map<String, dynamic> json) {
  //   return LoadData(
  //     projectId: json['ShortChar05'],
  //     loadDate: json['Date01'] ?? '',
  //     fromWarehouse: json['Character06'],
  //     toWarehouse: json['Character04'],
  //     toBin: json['Character05'],
  //     loadType: json['ShortChar03'],
  //     loadCondition: json['ShortChar04'],
  //     loadStatus: json['ShortChar01'],
  //     truckId: json['ShortChar08'],
  //     resourceId: json['Character09'],
  //     plateNumber: json['ShortChar07'],
  //     driverName: json['Character02'],
  //     driverNumber: json['Character03'],
  //     resourceCapacity: json['Number06'],
  //     resourceLoaded: json['Number01'],
  //     resourceLength: json['Number10'],
  //     resourceWidth: json['Number09'],
  //     resourceHeight: json['Number08'],
  //     resourceVolume: json['Number07'],
  //     foremanId: json['EmployeeID_c'],
  //     foremanName: json['EmployeeName_c'],
  //     comments: json['Comments_c'],
  //   );
  // }

  @override
  String toString() {
    return 'projectId: $projectId, loadDate: $loadDate, toWarehouse: $toWarehouse, toBin: $toBin, loadType: $loadType, loadCondition: $loadCondition' 'truckId: $truckId, resourceId: $resourceId, plateNumber: $plateNumber, driverName: $driverName, driverNumber: $driverNumber, resourceCapacity: $resourceCapacity, resourceLoaded: $resourceLoaded, resourceLength: $resourceLength, resourceWidth: $resourceWidth, resourceHeight: $resourceHeight, resourceVolume: $resourceVolume, foremanId: $foremanId, foremanName: $foremanName, comments: $comments';
  }
}