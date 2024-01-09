

class PartData {
  late final String partNum;
  late final String partDesc;
  late final String uom;
  late final String qty;
  late final String? selectedQty;
  PartData({required this.partNum, required this.partDesc, required this.uom, required this.qty, this.selectedQty});

  factory PartData.fromJson(Map<String, dynamic> json) {
    return PartData(
      partNum: json['Part_PartNum'],
      partDesc: json['Part_PartDescription'],
      qty: json['Part_QTY'],
      uom: json['Part_IUM'],
    );
  }

  

  @override
  String toString() {
    return 'PartData{partNum: $partNum, partDesc: $partDesc, uom: $uom, qty: $qty, selectedQty: $selectedQty}';
  }

}