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
  late final String? Warehouse;
  late final String fromBin;
  late final int SO;  // late final bool is
 late final String ChildKey1;
  ElementData({required this.partId, required this.elementId, required this.elementDesc,  this.erectionSeq=""
    ,  this.erectionDate="", this.UOM="", this.weight="",
    this.area="",
    this.volume="",this.quantity=""
    , this.selectedQty, this.ChildKey1="",
    required this.Warehouse,
  required this.fromBin,
  this.SO=0
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
      Warehouse: json['Character03'],
    );
  }

  @override
  String toString() {
    return 'ElementData{elementId: $elementId, elementDesc: $elementDesc, erectionSeq: $erectionSeq, erectionDate: $erectionDate, weight: $weight, area: $area, volume: $volume, quantity: $quantity}';
  }
}