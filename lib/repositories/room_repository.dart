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
    await _supabase.from('rooms').insert(room.toJson());
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
}
