class ElementMasterData {
  late final String partNum;
  late final String elementId;
  late final String elementDesc;
  late final String project;
  late final String status;
  late final int erectionSeq;
  late final String erectionDate;
  late final String UOM;
  late final String weight;
  late final String area;
  late final String volume;
  late final String quantity;
  late final String height;

  ElementMasterData({required this.partNum, required this.elementId, required this.elementDesc, required this.project, required this.status, required this.erectionSeq, required this.erectionDate, required this.UOM, required this.weight, required this.area, required this.volume, required this.quantity, required this.height});

  factory ElementMasterData.fromJson(Map<String, dynamic> json) {
    return ElementMasterData(
      partNum: json['PartNum'],
      elementId: json['ElementId'],
      elementDesc: json['ElementDesc'],
      project: json['Project'],
      status: json['Status'],
      erectionSeq: json['ErectionSeq'],
      erectionDate: json['ErectionDate'],
      UOM: json['UOM'],
      weight: json['Weight'],
      area: json['Area'],
      volume: json['Volume'],
      quantity: json['Quantity'],
      height: json['Height']
    );
  }
}