class Point {
  final double latitude;
  final double longitude;

  Point({
    required this.latitude,
    required this.longitude,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}