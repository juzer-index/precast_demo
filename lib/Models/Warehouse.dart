import './Point.dart';

class Warehouse{
  String id;
  String Description;
  Point Location;
  Warehouse({
    required this.id,
    required this.Description,
    required this.Location,
  });
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'],
      Description: json['Description'],
      Location: new Point(latitude: double.parse(json['Latitude']), longitude:json['Longitude']),
    );
  }
}