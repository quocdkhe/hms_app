import 'dart:convert';
import 'package:hms_app/utils/safe_int_parser.dart';

class Room {
  final int id;
  final int roomNumber;
  final int roomTypeId;
  final int floor;

  Room({
    required this.id,
    required this.roomNumber,
    required this.roomTypeId,
    required this.floor,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: parseInt(json['id']),
      roomNumber: parseInt(json['room_number']),
      roomTypeId: parseInt(json['room_type_id']),
      floor: parseInt(json['floor']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'room_number': roomNumber,
    'room_type_id': roomTypeId,
    'floor': floor,
  };

  // Convenience helpers
  static Room fromJsonString(String jsonString) =>
      Room.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());

  Room copyWith({int? id, int? roomNumber, int? roomTypeId, int? floor}) {
    return Room(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      roomTypeId: roomTypeId ?? this.roomTypeId,
      floor: floor ?? this.floor,
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, roomNumber: $roomNumber, roomTypeId: $roomTypeId, floor: $floor)';
  }
}
