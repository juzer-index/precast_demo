class CustomerShipment {
  String id;
  String description;
  CustomerShipment({
    required this.id,
    required this.description,
  });
  factory CustomerShipment.fromJson(Map<String, dynamic> json) {
    return CustomerShipment(
      id: json['id'],
      description: json['Description'],
    );
  }
  toJson() {
    return {
      "id": id,
      "Description": description,
    };
  }
}