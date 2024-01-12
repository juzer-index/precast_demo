class TruckDetails {
  late final String truckName;
  late final String plateNumber;
  late final String resourceID;
  TruckDetails({required this.truckName, required this.plateNumber, required this.resourceID});

  factory TruckDetails.fromJson(Map<String, dynamic> json) {
    return TruckDetails(
      truckName: json['Character01'],
      plateNumber: json['Character02'],
      resourceID: json['Key1'],
    );
  }

  @override
   String toString() {
      return 'truckName: $truckName, plateNumber: $plateNumber key1: $resourceID';
    }
}