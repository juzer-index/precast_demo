import 'dart:convert';

class ElementData {
  late final String Company;
  late final String partId;
  late final String elementId;
  late final String elementDesc;
  late final int erectionSeq;
  late final String erectionDate;
  late final String UOM;
  late final double weight;
  late final double area;
  late final double volume;
  late final int quantity;
  late final int selectedQty;
  late final String Warehouse;
  late final String fromBin;
  late final int SO;  // late final bool is
  late final String ChildKey1;
  late final String Key1;
  late bool CheckBox01;
  late bool CheckBox02;
  late bool CheckBox03;
  late bool CheckBox04;
  late bool CheckBox05;
  late bool CheckBox06;
  late bool CheckBox07;
  late bool CheckBox08;
  late bool CheckBox09;
  late bool CheckBox10;
  late bool CheckBox11;
  late bool CheckBox12;
  late bool CheckBox13;
  late final String UOMClass;
  late final String Revision;

  ElementData({required this.partId, required this.elementId, required this.elementDesc,  this.erectionSeq=0
    ,  this.erectionDate="", this.UOM="", this.weight=0,
    this.area=0,
    this.volume=0,this.quantity=0
    , this.selectedQty=0, this.ChildKey1="",
    required this.Warehouse,
    required this.fromBin,
    this.SO=0,
    this.CheckBox01=false,
    this.CheckBox02=false,
    this.CheckBox03=false,
    this.CheckBox04=false,
    this.CheckBox05=false,
    this.CheckBox06=false,
    this.CheckBox07=false,
    this.CheckBox08=false,
    this.CheckBox09=false,
    this.CheckBox10=false,
    this.CheckBox11=false,
    this.CheckBox12=false,
    this.CheckBox13=false,
  required this.Company,
     this.Key1="",
    required this.UOMClass,
     required this.Revision,
  });


  factory ElementData.fromJson(Map<String, dynamic> json) {
    return ElementData(
      Company: json['Company'] ?? '',
      partId: json['Character01'] ?? '',
      elementId: json['Character02'] ?? '',
      elementDesc: json['Character02'] ?? '',
      erectionSeq: json['Number06'] is int ? json['Number06'] : (json['Number06'] ?? 0).toInt(),
      erectionDate: json['Date01'] ?? '',
      UOM: json['ShortChar07'] ?? '',
      selectedQty: json['Number01'] is int ? json['Number01'] : (json['Number01'] ?? 0).toInt(),
      weight: json['Number03'] is double ? json['Number03'] : (json['Number03'] ?? 0.0).toDouble(),
      area: json['Number04'] is double ? json['Number04'] : (json['Number04'] ?? 0.0).toDouble(),
      volume: json['Number05'] is double ? json['Number05'] : (json['Number05'] ?? 0.0).toDouble(),
      quantity: 1,
      ChildKey1: json['ChildKey1'] ?? '',
      fromBin: json['Character04'] ?? '',
      Warehouse: json['Character03'] ?? '',
      Key1: json['Key1'] ?? '',
      CheckBox01: json['CheckBox01'] ?? false,
      CheckBox02: json['CheckBox02'] ?? false,
      CheckBox03: json['CheckBox03'] ?? false,
      CheckBox04: json['CheckBox04'] ?? false,
      CheckBox05: json['CheckBox05'] ?? false,
      CheckBox06: json['CheckBox06'] ?? false,
      CheckBox07: json['CheckBox07'] ?? false,
      CheckBox08: json['CheckBox08'] ?? false,
      CheckBox09: json['CheckBox09'] ?? false,
      CheckBox10: json['CheckBox10'] ?? false,
      CheckBox11: json['CheckBox11'] ?? false,
      CheckBox12: json['CheckBox12'] ?? false,
      CheckBox13: json['CheckBox13'] ?? false,
      UOMClass: json['Character09'] ?? '',
      Revision: json['Character08'] ?? '',
    );
  }

  @override
  String toString() {
    return 'ElementData{elementId: $elementId, elementDesc: $elementDesc, erectionSeq: $erectionSeq, erectionDate: $erectionDate, weight: $weight, area: $area, volume: $volume, quantity: $quantity}';
  }
  toJson() {
    return jsonEncode({
      'Company': Company,
      'Key1': Key1,
      'Character01': partId,
      'Character02': elementId,
      'Character03': Warehouse,
      'Character04': fromBin,
       'Character08':Revision,
        'Character09':UOMClass,

      'ShortChar07': UOM,
      'Number01': selectedQty.toString(),
      'Number03': weight.toString(),
      'Number04': area.toString(),
      'Number05': volume.toString(),
      'Number06': erectionSeq.toString(),
      'ChildKey1': ChildKey1,
      'CheckBox01': CheckBox01,
      'CheckBox02': CheckBox02,
      'CheckBox03': CheckBox03,
      'CheckBox04': CheckBox04,
      'CheckBox05': CheckBox05,
      'CheckBox06': CheckBox06,
      'CheckBox07': CheckBox07,
      'CheckBox08': CheckBox08,
      'CheckBox09': CheckBox09,
      'CheckBox10': CheckBox10,
      'CheckBox11': CheckBox11,
      'CheckBox12': CheckBox12,
      'CheckBox13': CheckBox13,



    });
  }
}