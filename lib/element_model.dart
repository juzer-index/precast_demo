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

  late final String fromBin;
  // late final bool is
 late final String ChildKey1;
  ElementData({required this.partId, required this.elementId, required this.elementDesc, required this.erectionSeq, required this.erectionDate, required this.UOM, required this.weight, required this.area, required this.volume, required this.quantity, this.selectedQty,
    required this.ChildKey1,
  required this.fromBin,
});

  factory ElementData.fromJson(Map<String, dynamic> json) {
    return ElementData(
      partId: json['Character01'],
      elementId: json['Character02'],
      elementDesc: json['Character02'],
      erectionSeq: json['Number06'].toString(),
      erectionDate: json['Date01'] ?? '',
      UOM: json['ShortChar07'],
      weight: json['Number01'].toString(),
      area: json['Number02'].toString(),
      volume: json['Number03'].toString(),
      quantity: json['Number04'].toString(),
      ChildKey1: json['ChildKey1'],

      fromBin: json['Character04'],
    );
  }

  @override
  String toString() {
    return 'ElementData{elementId: $elementId, elementDesc: $elementDesc, erectionSeq: $erectionSeq, erectionDate: $erectionDate, weight: $weight, area: $area, volume: $volume, quantity: $quantity}';
  }
}