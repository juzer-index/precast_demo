import 'package:flutter/material.dart';

class WarehouseModel {
  final String warehouseCode;
  final String warehouseDesc;

  WarehouseModel({required this.warehouseCode, required this.warehouseDesc});

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      warehouseCode: json['Key1'],
      warehouseDesc: json['Character01'],
    );
  }

  @override
  String toString() {
    return 'warehouseCode: $warehouseCode, warehouseDesc: $warehouseDesc';
  }
}