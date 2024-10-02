import 'dart:convert';

class LoadData {
  late final String company;
  late final String loadID;
  late final String projectId;
  late final String loadDate;
  late final String fromWarehouse;
  late final String toWarehouse;
  late final String toBin;
  late final String loadType;
  late final String truckType;
  late final String loadStatus;
  late final String truckId;
  late final String resourceId;
  late final String plateNumber;
  late final String driverName;
  late final String driverNumber;
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

  LoadData({
    required this.company,
    required this.loadID,
    required this.projectId,
    required this.loadDate,
    required this.fromWarehouse,
    required this.toWarehouse,
    required this.toBin,
    required this.loadType,
    required this.truckType,
    required this.loadStatus,
    required this.truckId,
    required this.resourceId,
    required this.plateNumber,
    required this.driverName,
    required this.driverNumber,
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
  });

  //ud103

  factory LoadData.fromJson(Map<String, dynamic> json) {
    return LoadData(
      company: json['Company'],
      loadID: json['Key1'],
      projectId: json['ShortChar05'],
      loadDate: json['Date01'] ?? '',
      fromWarehouse: json['Character06'],
      toWarehouse: json['Character04'],
      toBin: json['Character05'],
      loadType: json['ShortChar01'],
      truckType: json['ShortChar04'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Company': company,
      'Key1': loadID,
      'ShortChar05': projectId,
      'Date01': loadDate,
      'Character06': fromWarehouse,
      'Character04': toWarehouse,
      'Character05': toBin,
      'ShortChar01': loadType,
      'ShortChar04': truckType,
      'ShortChar03': loadStatus,
      'ShortChar08': truckId,
      'Character09': resourceId,
      'ShortChar07': plateNumber,
      'Character02': driverName,
      'Character03': driverNumber,
      'Number06': resourceCapacity,
      'Number01': resourceLoaded,
      'Number10': resourceLength,
      'Number09': resourceWidth,
      'Number08': resourceHeight,
      'Number07': resourceVolume,
      // 'EmployeeID_c': foremanId,
      // 'EmployeeName_c': foremanName,
      // 'Comments_c': comments,
      // 'CreatedBy_C': createdBy,
      // 'Deviceid_c': DeviceID,
    };
  }

  factory LoadData.fromMap(Map<String, dynamic> map) {
    return LoadData(
      company: map['Company'],
      loadID: map['Key1'],
      projectId: map['ShortChar05'],
      loadDate: map['Date01'] ?? '',
      fromWarehouse: map['Character06'],
      toWarehouse: map['Character04'],
      toBin: map['Character05'],
      loadType: map['ShortChar01'],
      truckType: map['ShortChar04'],
      loadStatus: map['ShortChar03'],
      truckId: map['ShortChar08'],
      resourceId: map['Character09'],
      plateNumber: map['ShortChar07'],
      driverName: map['Character02'],
      driverNumber: map['Character03'],
      resourceCapacity: map['Number06'],
      resourceLoaded: map['Number01'],
      resourceLength: map['Number10'],
      resourceWidth: map['Number09'],
      resourceHeight: map['Number08'],
      resourceVolume: map['Number07'],
      foremanId: map['EmployeeID_c'],
      foremanName: map['EmployeeName_c'],
      comments: map['Comments_c'],
      createdBy: map['CreatedBy_C'],
      DeviceID: map['Deviceid_c'],
    );
  }

  @override
  String toString() {
    return 'projectId: $projectId, loadDate: $loadDate, toWarehouse: $toWarehouse, toBin: $toBin, loadType: $loadType, loadCondition: $truckType'
        'truckId: $truckId, resourceId: $resourceId, plateNumber: $plateNumber, driverName: $driverName, driverNumber: $driverNumber, resourceCapacity: $resourceCapacity, resourceLoaded: $resourceLoaded, resourceLength: $resourceLength, resourceWidth: $resourceWidth, resourceHeight: $resourceHeight, resourceVolume: $resourceVolume, foremanId: $foremanId, foremanName: $foremanName, comments: $comments';
  }
}
