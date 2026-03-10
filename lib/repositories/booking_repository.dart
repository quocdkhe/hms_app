import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/booking_schedule_item.dart';
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
    debugPrint('└────┴──────────┴─────────────┴─────────────┘');
    debugPrint('Total: ${responseList.length} rooms');
    return responseList;
  }

  Future<void> createBooking({
    required int roomId,
    required String guestName,
    required String guestPhone,
    required DateTime checkInDateTime,
    required DateTime checkOutDateTime,
    required bool checkInNow,
  }) async {
    // Validate booking
    if (!await _isBookingOverlap(
      roomId: roomId,
      checkInDateTime: checkInDateTime,
      checkOutDateTime: checkOutDateTime,
    )) {
      throw Exception('Phòng đã được đặt trong thời gian này!');
    }
    final guestEmail = '$guestPhone@hms.com';

    if (checkInNow && await _isRoomUsingNow(roomId: roomId)) {
      throw Exception('Phòng chưa được checkout!');
    }

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
    } else {
      throw Exception('Số điện thoại này đã tồn tại');
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
        .neq('status', 'checked_out')
        .order('check_in_date_time', ascending: true);
    return (response as List)
        .map((e) => BookingScheduleItem.fromJson(e))
        .toList();
  }

  /// --------------------------------------------------------------------
  /// Helper functions check room is ok to book in this time

  Future<bool> _isBookingOverlap({
    required int roomId,
    required DateTime checkInDateTime,
    required DateTime checkOutDateTime,
  }) async {
    // Ensure we always send UTC to Postgres, regardless of local timezone
    final checkInUtc = checkInDateTime.toUtc();
    final checkOutUtc = checkOutDateTime.toUtc();

    final response = await _supabase
        .from('bookings')
        .select()
        .eq('room_id', roomId)
        .neq('status', 'no_show')
        .or(
          'actual_check_out_date_time.is.null,actual_check_out_date_time.gt.${checkInUtc.toIso8601String()}',
        )
        .lt('check_in_date_time', checkOutUtc.toIso8601String());

    final overlapping = (response as List).where((booking) {
      final actualCheckOut = booking['actual_check_out_date_time'];
      final scheduledCheckOut = booking['check_out_date_time'] as String;

      final effectiveCheckOut = actualCheckOut ?? scheduledCheckOut;

      // Parse and convert to UTC for safe comparison
      final effectiveCheckOutDate = DateTime.parse(effectiveCheckOut).toUtc();

      return effectiveCheckOutDate.isAfter(checkInUtc);
    }).toList();

    return overlapping.isEmpty;
  }

  Future<bool> _isRoomUsingNow({required int roomId}) async {
    final response = await _supabase
        .from('bookings')
        .select()
        .eq('room_id', roomId)
        .eq('status', 'checked_in')
        .isFilter('actual_check_out_date_time', null);
    return (response as List).isNotEmpty;
  }
}
