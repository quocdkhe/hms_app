import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/booking_details.dart';
import 'package:hms_app/models/dtos/room_details.dart';
import 'package:hms_app/repositories/booking_repository.dart';
import 'package:hms_app/repositories/room_repository.dart';
import 'package:hms_app/widgets/time_row.dart';

class CheckOutView extends StatefulWidget {
  final int bookingId;
  const CheckOutView({super.key, required this.bookingId});

  @override
  State<CheckOutView> createState() => _CheckOutViewState();
}

class _CheckoutData {
  final BookingDetails booking;
  final RoomDetails room;

  _CheckoutData({required this.booking, required this.room});
}

class _CheckOutViewState extends State<CheckOutView> {
  final _bookingRepository = BookingRepository();
  final _roomRepository = RoomRepository();
  late Future<_CheckoutData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<_CheckoutData> _fetchData() async {
    final booking = await _bookingRepository.getCurrentStayDetails(
      widget.bookingId,
    );
    final room = await _roomRepository.getRoomDetails(booking.roomId);
    return _CheckoutData(booking: booking, room: room);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Out')),
      body: FutureBuilder<_CheckoutData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy dữ liệu'));
          }

          final data = snapshot.data!;
          final room = data.room;
          final booking = data.booking;
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Room and guest information ────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section
                  if (room.imageUrl != null)
                    Image.network(
                      room.imageUrl!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      width: 110,
                      height: 110,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                  // Content section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phòng ${room.roomName} - ${room.typeName}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Khách: ${booking.customerName}',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                              children: [
                                const TextSpan(text: 'Trạng thái: '),
                                TextSpan(
                                  text: 'Đang ở',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // End room details section
              const Divider(height: 32),

              // ── Stay Duration Card ─────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thời gian lưu trú',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildTimeRow(
                        context,
                        icon: Icons.login_outlined,
                        label: 'Check-in',
                        dateTime:
                            booking.actualCheckInDateTime ??
                            booking.checkInDateTime,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: SizedBox(
                          height: 24,
                          child: VerticalDivider(width: 1, thickness: 1),
                        ),
                      ),
                      buildTimeRow(
                        context,
                        icon: Icons.logout_outlined,
                        label: 'Check-out (dự kiến)',
                        dateTime:
                            booking.actualCheckOutDateTime ??
                            booking.checkoutDateTime,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
