

class PartData {
  late final String partNum;
  late final String partDesc;
  late final String uom;
  late final String qty;
  late final String? selectedQty;
  late final String? BinNum;
  PartData({required this.partNum, required this.partDesc, required this.uom, required this.qty, this.selectedQty,this.BinNum});

  factory PartData.fromJson(Map<String, dynamic> json) {
    return PartData(
      partNum: json['Character01'],
      partDesc: json['Character02'],
      qty: json['Number01'].toString(),
      uom: json['ShortChar07'],
    );
  }

  

  @override
  String toString() {
    return 'PartData{partNum: $partNum, partDesc: $partDesc, uom: $uom, qty: $qty, selectedQty: $selectedQty}';
  }

}