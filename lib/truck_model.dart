class TruckDetails {
  late final String plateNumber;
  late final String transporterName;
  TruckDetails({required this.plateNumber, required this.transporterName});

  factory TruckDetails.fromJson(Map<String, dynamic> json) {
    return TruckDetails(
      plateNumber: json['ShortChar07'],
      transporterName: json['Character01'],
    );
  }

  @override
   String toString() {
      return 'plateNumber: $plateNumber, transporterName: $transporterName';
    }
}