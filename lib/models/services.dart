import 'dart:convert';
import 'package:hms_app/utils/safe_int_parser.dart';

class Service {
  final int id;
  final String name;
  final String? description;
  final String unit;
  final int pricePerUnit;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.unit,
    required this.pricePerUnit,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: parseInt(json['id']),
      name: json['name'] as String,
      description: json['description'] as String?,
      unit: json['unit'] as String,
      pricePerUnit: parseInt(json['price_per_unit']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'unit': unit,
    'price_per_unit': pricePerUnit,
  };

  // Convenience helpers
  static Service fromJsonString(String jsonString) =>
      Service.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());

  Service copyWith({
    int? id,
    String? name,
    String? description,
    String? unit,
    int? pricePerUnit,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    );
  }

  @override
  String toString() {
    return 'Service(id: $id, name: $name, description: $description, unit: $unit, pricePerUnit: $pricePerUnit)';
  }
}
