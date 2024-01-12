
class LoadData {
  late final String projectId;
  late final String loadDate;
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
  late final String resourceCapacity;
  late final String resourceLoaded;
  late final String resourceLength;
  late final String resourceWidth;
  late final String resourceHeight;
  late final String resourceVolume;
  late final String foremanId;
  late final String foremanName;
  late final String comments;
  LoadData({
    required this.projectId,
    required this.loadDate,
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
    required this.resourceCapacity,
    required this.resourceLoaded,
    required this.resourceLength,
    required this.resourceWidth,
    required this.resourceHeight,
    required this.resourceVolume,
    required this.foremanId,
    required this.foremanName,
    required this.comments,
  });

  factory LoadData.fromJson(Map<String, dynamic> json) {
    return LoadData(
      projectId: json['ShortChar05'],
      loadDate: json['Date01'] ?? '',
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ShortChar05': projectId,
      'Date01': loadDate,
      'Character04': toWarehouse,
      'Character05': toBin,
      'ShortChar01': loadType,
      'ShortChar04': loadCondition,
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
      'EmployeeID_c': foremanId,
      'EmployeeName_c': foremanName,
      'Comments_c': comments,
    };
  }

  @override
  String toString() {
    return 'projectId: $projectId, loadDate: $loadDate, toWarehouse: $toWarehouse, toBin: $toBin, loadType: $loadType, loadCondition: $loadCondition' 'truckId: $truckId, resourceId: $resourceId, plateNumber: $plateNumber, driverName: $driverName, driverNumber: $driverNumber, resourceCapacity: $resourceCapacity, resourceLoaded: $resourceLoaded, resourceLength: $resourceLength, resourceWidth: $resourceWidth, resourceHeight: $resourceHeight, resourceVolume: $resourceVolume, foremanId: $foremanId, foremanName: $foremanName, comments: $comments';
  }
}