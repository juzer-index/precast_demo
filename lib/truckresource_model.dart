class ResourceDetails {
  late final String capacity;
  late final String length;
  late final String width;
  late final String height;
  late final String volume;
  ResourceDetails({required this.capacity, required this.length, required this.width, required this.height, required this.volume});

  factory ResourceDetails.fromJson(Map<String, dynamic> json) {
    return ResourceDetails(
      capacity: json['Number06'],
      length: json['Number10'],
      width: json['Number09'],
      height: json['Number08'],
      volume: json['Number07'],
    );
  }
}