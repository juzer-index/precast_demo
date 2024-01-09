
class LoadData {
  late final String projectId;
  late final String loadDate;
  late final String toWarehouse;
  late final String toBin;
  late final String loadType;
  late final String loadCondition;
  LoadData({required this.projectId, required this.loadDate, required this.toWarehouse, required this.toBin, required this.loadType, required this.loadCondition});

  factory LoadData.fromJson(Map<String, dynamic> json) {
    return LoadData(
      projectId: json['ShortChar05'],
      loadDate: json['Date01'],
      toWarehouse: json['Character04'],
      toBin: json['Character05'],
      loadType: json['ShortChar01'],
      loadCondition: json['ShortChar04'],
    );
  }

  @override
  String toString() {
    return 'projectId: $projectId, loadDate: $loadDate, toWarehouse: $toWarehouse, toBin: $toBin, loadType: $loadType, loadCondition: $loadCondition';
  }
}