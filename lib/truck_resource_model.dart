class ResourceDetails {
  late final String capacity;
  late final String length;
  late final String width;
  late final String height;
  late final String volume;
  late final String loaded;
  ResourceDetails({required this.capacity, required this.length, required this.width, required this.height, required this.volume, required this.loaded});

  factory ResourceDetails.fromJson(Map<String, dynamic> json) {
    return ResourceDetails(
      capacity: json['Number03'],
      length: json['Number05'],
      width: json['Number06'],
      height: json['Number07'],
      volume: json['Number04'],
      loaded: json['Number01'],
    );
  }
}