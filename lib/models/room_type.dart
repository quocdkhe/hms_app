import 'dart:convert';
import 'package:hms_app/utils/safe_parser.dart';

class RoomType {
  final int id;
  final String? imageUrl;
  final String typeName;
  final int numberOfBed;
  final String? description;

  RoomType({
    required this.id,
    this.imageUrl,
    required this.typeName,
    required this.numberOfBed,
    this.description,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      id: parseInt(json['id']),
      imageUrl: json['image_url'] as String?,
      typeName: json['type_name'] as String,
      numberOfBed: parseInt(json['number_of_bed']),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'type_name': typeName,
      'number_of_bed': numberOfBed,
      'description': description,
    };
  }

  static RoomType fromJsonString(String jsonString) =>
      RoomType.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());
}
