import 'package:hms_app/models/dtos/booking_schedule_item.dart';
import 'package:hms_app/models/dtos/room_details.dart';
import 'package:hms_app/models/room.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Room>> fetchRooms() async {
    final response = await _supabase
        .from('rooms')
        .select()
        .order('id', ascending: true);

    return (response as List).map((e) => Room.fromJson(e)).toList();
  }

  Future<void> createRoom(Room room) async {
    final data = Map<String, dynamic>.from(room.toJson());
    data.remove('id');
    await _supabase.from('rooms').insert(data);
  }

  Future<void> deleteRoom(int id) async {
    await _supabase.from('rooms').delete().eq('id', id);
  }

  Future<void> updateRoom(Room room) async {
    await _supabase.from('rooms').update(room.toJson()).eq('id', room.id);
  }

  Future<Room> getRoomById(int id) async {
    final response = await _supabase
        .from('rooms')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) {
      throw Exception('Không tìm thấy phòng');
    }
    return Room.fromJson(response);
  }

  Future<RoomDetails> getRoomDetails(int id) async {
    final response = await _supabase
        .from('rooms')
        .select('''
          id,
          room_name,
          floor,
          room_types(
            type_name,
            number_of_bed,
            price_per_night,
            description,
            image_url
          )
        ''')
        .eq('id', id)
        .maybeSingle();
    if (response == null) {
      throw Exception('Không tìm thấy phòng');
    }
    return RoomDetails.fromJson(response);
  }

  Future<List<BookingScheduleItem>> getBookingSchedule(int roomId) async {
    final response = await _supabase
        .from('bookings')
        .select('''
          id,
          user_profiles(full_name, avatar_url),
          check_in_date_time,
          check_out_date_time,
          actual_check_out_date_time,
          actual_check_in_date_time,
          status
        ''')
        .eq('room_id', roomId)
        .order('check_in_date_time', ascending: true);
    return (response as List)
        .map((e) => BookingScheduleItem.fromJson(e))
        .toList();
  }
}
