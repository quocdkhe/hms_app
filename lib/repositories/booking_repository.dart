import 'package:hms_app/models/dtos/room_card_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepository {
  final _supabase = Supabase.instance.client;

  Future<List<RoomCardItem>> getRoomMap() async {
    final response = await _supabase.from('rooms').select('''
      id,
      room_name,
      room_types(type_name),
      bookings!left(
        status,
        actual_check_in_date_time,
        checkout_date_time
      )
    ''');

    final now = DateTime.now();

    return (response as List)
        .map((roomData) => RoomCardItem.mapRoomCardItem(roomData, now))
        .toList();
  }
}
