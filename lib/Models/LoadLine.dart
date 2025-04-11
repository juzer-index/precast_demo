class LoadLine {
  String? Key1;
  String? Company;
  String? ChildKey1;
  String? Character01; // partNum
  String? Character02; // Element Id
  String? Character03; // From Warehouse
  String? Character04; // From Bin
  int? Number01; // Quantity
  double? Number03; // Weight
  double? Number04; // area
  double? Number05; // Volume
  int? Number06; //erection Sequence
  String? ShortChar07; // UOM
  bool? CheckBox01;
  bool? CheckBox02;
  bool? CheckBox03;

  bool? CheckBox05;
  bool? CheckBox07;
  bool? CheckBox13;
    LoadLine({
     this.Key1="",
    this.Company="",
    this.ChildKey1="",
    this.Character01="",
    this.Character02="",
    this.Character03="",
    this.Character04="",
    this.Number01=0,
    this.Number03=0,
    this.Number04=0,
    this.Number05=0,
    this.Number06=0,
    this.ShortChar07="",
    this.CheckBox01=false,
    this.CheckBox02=false,
    this.CheckBox03=false,
    this.CheckBox05=false,
    this.CheckBox07=false,
    this.CheckBox13=false,
  });
  toJson() {
    return {
      "Key1": Key1,
      "Company": Company,
      "ChildKey1": ChildKey1,
      "Character01": Character01,
      "Character02": Character02,
      "Character03": Character03,
      "Character04": Character04,
      "Number01": Number01,
      "Number03": Number03,
      "Number04": Number04,
      "Number05": Number05,
      "Number06": Number06,
      "ShortChar07": ShortChar07,
      "CheckBox01": CheckBox01,
      "CheckBox02": CheckBox02,
      "CheckBox03": CheckBox03,
      "CheckBox05": CheckBox05,
      "CheckBox07": CheckBox07,
      "CheckBox13": CheckBox13,

    };
  }
  factory LoadLine.fromJson(Map<String, dynamic> json) {
    return LoadLine(
      Key1: json['Key1'],
      Company: json['Company'],
      ChildKey1: json['ChildKey1'],
      Character01: json['Character01'],
      Character02: json['Character02'],
      Character03: json['Character03'],
      Character04: json['Character04'],
      Number01: int.parse(json['Number01']),
      Number03: double.parse(json['Number03']),
      Number04: double.parse(json['Number04']),
      Number05: double.parse(json['Number05']),
      Number06: int.parse(json['Number06']),
      ShortChar07: json['ShortChar07'],
      CheckBox01: json['CheckBox01'] == 1,
      CheckBox02: json['CheckBox02'] == 1,
      CheckBox03: json['CheckBox03'] == 1,
      CheckBox05: json['CheckBox05'] == 1,
      CheckBox07: json['CheckBox07'] == 1,
      CheckBox13: json['CheckBox13'] == 1,
    );
  }
}