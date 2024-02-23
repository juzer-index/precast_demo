class ElementData {
  late final String partId;
  late final String elementId;
  late final String elementDesc;
  late final String erectionSeq;
  late final String erectionDate;
  late final String UOM;
  late final String weight;
  late final String area;
  late final String volume;
  late final String quantity;
  late final String? selectedQty;
  // late final bool is
  ElementData({required this.partId, required this.elementId, required this.elementDesc, required this.erectionSeq, required this.erectionDate, required this.UOM, required this.weight, required this.area, required this.volume, required this.quantity, this.selectedQty});

  factory ElementData.fromJson(Map<String, dynamic> json) {
    return ElementData(
      partId: json['Character01'],
      elementId: json['Character02'],
      elementDesc: json['Character02'],
      erectionSeq: json['Number06'],
      erectionDate: json['Date01'] ?? '',
      UOM: json['ShortChar07'],
      weight: json['Number01'],
      area: json['Number02'],
      volume: json['Number03'],
      quantity: json['Number04'],
    );
  }

  @override
  String toString() {
    return 'ElementData{elementId: $elementId, elementDesc: $elementDesc, erectionSeq: $erectionSeq, erectionDate: $erectionDate, weight: $weight, area: $area, volume: $volume, quantity: $quantity}';
  }
}