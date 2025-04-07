import 'dart:ffi';

class LoadData {
  String  Key1="";
  String Company="";
  String ShortChar01="" ;// loadType
  String ShortChar02="";
  String ShortChar03="" ;// status
  String ShortChar04="" ;// load condition
  String ShortChar05="" ;// architecture
  String ShortChar06="";
  String ShortChar07="" ;// plate number
  String ShortChar08=""; // truck number
  String Character01="";
  String Character02=""; // Driver Name
  String Character03=""; // Driver Number
  String Character04="";// Customer Id
  String Character05="";
  String Character06=""; // from Warehouse
  String Character07=""; // SO Number
  String Character08=""; // Selected Ship to
  String Character09=""; // resource Id
  double Number01=0; // loaded
  int Number02=0;
  int Number03=0; // SO Number
  int Number04=0;
  int Number05=0;
  double Number06=0; // capacity
  double Number07=0; // volume
  double Number08=0; // height
  double Number09=0; // width
  double Number10=0; // length
  int Number11=0; // customer shipment

  LoadData({
  this.Key1="",
     this.Company="",
     this.ShortChar01="",
     this.ShortChar02="",
     this.ShortChar03="",
     this.ShortChar04="",
     this.ShortChar05="",
     this.ShortChar06="",
     this.ShortChar07="",
     this.ShortChar08="",
     this.Character01="",
     this.Character02="",
     this.Character03="",
     this.Character04="",
     this.Character05="",
     this.Character06="",
     this.Character07="",
     this.Character08="",
     this.Character09="",
     this.Number01=0,
     this.Number02=0,
     this.Number03=0,
     this.Number04=0,
     this.Number05=0,
     this.Number06=0,
     this.Number07=0,
      this.Number08=0,
      this.Number09=0,
      this.Number10=0,
      this.Number11=0,

  });
  toJson() {
    return {
      "Key1": Key1,
      "Company": Company,
      "ShortChar01": ShortChar01,
      "ShortChar02": ShortChar02,
      "ShortChar03": ShortChar03,
      "ShortChar04": ShortChar04,
      "ShortChar05": ShortChar05,
      "ShortChar06": ShortChar06,
      "ShortChar07": ShortChar07,
      "ShortChar08": ShortChar08,
      "Character01": Character01,
      "Character02": Character02,
      "Character03": Character03,
      "Character04": Character04,
      "Character05": Character05,
      "Character06": Character06,
      "Character07": Character07,
      "Character08": Character08,
      "Character09": Character09,
      "Number01": Number01,
      "Number02": Number02,
      "Number03": Number03,
      "Number04": Number04,
      "Number05": Number05,
      "Number06": Number06,
      "Number07": Number07,
      "Number08": Number08,
      "Number09": Number09,
      "Number10": Number10,
      "Number11": Number11,
    };
  }
  factory LoadData.fromJson(Map<String, dynamic> json) {
    return LoadData(
      Key1: json['Key1'],
      Company: json['Company'],
      ShortChar01: json['ShortChar01'],
      ShortChar02: json['ShortChar02'],
      ShortChar03: json['ShortChar03'],
      ShortChar04: json['ShortChar04'],
      ShortChar05: json['ShortChar05'],
      ShortChar06: json['ShortChar06'],
      ShortChar07: json['ShortChar07'],
      ShortChar08: json['ShortChar08'],
      Character01: json['Character01'],
      Character02: json['Character02'],
      Character03: json['Character03'],
      Character04: json['Character04'],
      Character05: json['Character05'],
      Character06: json['Character06'],
      Character07: json['Character07'],
      Character08: json['Character08'],
      Character09: json['Character09'],
      Number01: double.parse(json['Number01']),
      Number02: int.parse(json['Number02']),
      Number03: int.parse(json['Number03']),
      Number04: int.parse(json['Number04']),
      Number05: int.parse(json['Number05']),
      Number06: double.parse(json['Number06']),
      Number07: double.parse(json['Number07']),
      Number08: double.parse(json['Number08']),
      Number09: double.parse(json['Number09']),
      Number10: double.parse(json['Number10']),
      Number11: int.parse(json['Number11']),
    );
  }
}