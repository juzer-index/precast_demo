class ElementData {
  late final String partId;
  late final String elementId;
  late final String elementDesc;
  late final String erectionSeq;
  late final String erectionDate;
  late final String uom;
  late final String weight;
  late final String area;
  late final String volume;
  late final String quantity;
  late final String? selectedQty;
  late final String binNum;
  // late final bool is
 late final String childKey1;
  ElementData({required this.partId, required this.elementId, required this.elementDesc, required this.erectionSeq, required this.erectionDate, required this.uom, required this.weight, required this.area, required this.volume, required this.quantity, this.selectedQty, required this.childKey1,required this.binNum});

  factory ElementData.fromJson(Map<String, dynamic> json) {
    return ElementData(
      partId: json['Character01'],
      elementId: json['Character02'],
      elementDesc: json['Character02'],
      erectionSeq: json['Number06'].toString(),
      erectionDate: json['Date01'] ?? '',
      uom: json['ShortChar07'],
      weight: json['Number01'].toString(),
      area: json['Number02'].toString(),
      volume: json['Number03'].toString(),
      quantity: json['Number04'].toString(),
      childKey1: json['ChildKey1'],
      binNum: json['Character04'],
    );
  }

  @override
  String toString() {
    return 'ElementData{elementId: $elementId, elementDesc: $elementDesc, erectionSeq: $erectionSeq, erectionDate: $erectionDate, weight: $weight, area: $area, volume: $volume, quantity: $quantity}';
  }
}