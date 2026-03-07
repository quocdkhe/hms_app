enum RoomStatus { available, using }

class RoomCardItem {
  final int id;
  final String roomName;
  final String roomTypeName;
  final RoomStatus status;

  RoomCardItem({
    required this.id,
    required this.roomName,
    required this.roomTypeName,
    required this.status,
  });

  factory RoomCardItem.mapRoomCardItem(
    Map<String, dynamic> roomData,
    DateTime now,
  ) {
    final roomId = roomData['id'] as int;
    final roomName = roomData['room_name'] as String;

    final roomType = roomData['room_types'] as Map?;
    final typeName = roomType?['type_name'] as String? ?? '';

    final bookings = roomData['bookings'] as List? ?? [];

    final isUsing = bookings.any((b) {
      final status = b['status'];
      final checkIn = b['actual_check_in_date_time'];
      final checkout = b['checkout_date_time'];

      if (status != 'checked_in' || checkIn == null || checkout == null) {
        return false;
      }

      final checkInTime = DateTime.parse(checkIn);
      final checkoutTime = DateTime.parse(checkout);

      return now.isAfter(checkInTime) && now.isBefore(checkoutTime);
    });

    return RoomCardItem(
      id: roomId,
      roomName: roomName,
      roomTypeName: typeName,
      status: isUsing ? RoomStatus.using : RoomStatus.available,
    );
  }
}
