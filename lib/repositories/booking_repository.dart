import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/room_card_item.dart';
import 'package:hms_app/models/enums/booking_status.dart';
import 'package:hms_app/models/enums/user_role.dart';
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
        check_out_date_time
      )
    ''');

    var responseList = (response as List)
        .map((roomData) => RoomCardItem.mapRoomCardItem(roomData))
        .toList();
    debugPrint('┌────┬──────────┬─────────────┬─────────────┐');
    debugPrint('│ ID │ Room     │ Type        │ Status      │');
    debugPrint('├────┼──────────┼─────────────┼─────────────┤');
    for (final r in responseList) {
      debugPrint(
        '│ ${r.id.toString().padRight(3)}│ ${r.roomName.padRight(9)}│ ${r.roomTypeName.padRight(12)}│ ${r.status.name.padRight(12)}│',
      );
    }
    print('└────┴──────────┴─────────────┴─────────────┘');
    print('Total: ${responseList.length} rooms');
    return responseList;
  }

  Future<void> createBooking({
    required int roomId,
    required String guestName,
    required String guestPhone,
    required String guestEmail,
    required DateTime checkInDateTime,
    required DateTime checkOutDateTime,
    required bool checkInNow,
  }) async {
    // Step 1: Find or create user
    var userProfile = await _supabase
        .from('user_profiles')
        .select('id')
        .eq('email', guestEmail)
        .maybeSingle();

    if (userProfile == null) {
      // Sign up creates auth.users → trigger auto-creates user_profiles row
      final authResponse = await _supabase.auth.signUp(
        email: guestEmail,
        password: '123123',
      );

      final userId = authResponse.user!.id;

      // Update the auto-created profile with guest info
      await _supabase
          .from('user_profiles')
          .update({
            'full_name': guestName,
            'phone': guestPhone,
            'role': UserRole.customer.label,
          })
          .eq('id', userId);

      userProfile = {'id': userId};
    }

    // Step 2: Create booking
    await _supabase.from('bookings').insert({
      'room_id': roomId,
      'user_id': userProfile['id'],
      'check_in_date_time': checkInDateTime.toUtc().toIso8601String(),
      'actual_check_in_date_time': checkInNow
          ? checkInDateTime.toUtc().toIso8601String()
          : null,
      'check_out_date_time': checkOutDateTime.toUtc().toIso8601String(),
      'status': checkInNow
          ? BookingStatus.checkedIn.name
          : BookingStatus.confirmed.name,
    });
  }
}
