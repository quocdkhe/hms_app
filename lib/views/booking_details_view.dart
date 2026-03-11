import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/booking_schedule_item.dart';
import 'package:hms_app/models/enums/booking_status.dart';
import 'package:hms_app/repositories/booking_repository.dart';
import 'package:hms_app/widgets/date_time_picker.dart';

class BookingDetailsScreen extends StatefulWidget {
  final int bookingId;
  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late Future<BookingScheduleItem> _detailsFuture;
  final _bookingRepository = BookingRepository();

  DateTime? _checkIn;
  DateTime? _checkOut;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _bookingRepository.getBookingDetails(widget.bookingId);
  }

  Future<void> _pickDateTime({required bool isCheckIn}) async {
    final initial = isCheckIn ? _checkIn : _checkOut;
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (time == null || !mounted) return;
    final result = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isCheckIn) {
        _checkIn = result;
      } else {
        _checkOut = result;
      }
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Chưa chọn';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}  $h:$min';
  }

  (String label, Color color) _statusDisplay(
    BookingStatus status,
    ColorScheme cs,
  ) {
    return switch (status) {
      BookingStatus.confirmed => ('Đã xác nhận', cs.primary),
      BookingStatus.checkedIn => ('Đang ở', Colors.green),
      BookingStatus.checkedOut => ('Đã trả phòng', cs.outline),
      BookingStatus.noShow => ('Không đến', Colors.red),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BookingScheduleItem>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết đặt phòng')),
            body: Center(child: Text('Lỗi: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết đặt phòng')),
            body: const Center(child: Text('Không tìm thấy')),
          );
        }

        final booking = snapshot.data!;
        _checkIn ??= booking.checkInDateTime.toLocal();
        _checkOut ??= booking.checkoutDateTime.toLocal();

        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final (statusLabel, statusColor) = _statusDisplay(
          booking.status,
          colorScheme,
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Chi tiết đặt phòng')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Customer card ──────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: booking.customerAvatar != null
                            ? NetworkImage(booking.customerAvatar!)
                            : null,
                        child: booking.customerAvatar == null
                            ? const Icon(Icons.person, size: 32)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.customerName,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.customerPhone,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Date/time pickers ──────────────────────────────────
              Text(
                'Thời gian đặt phòng',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              DateTimePicker(
                label: 'Nhận phòng',
                icon: Icons.login,
                value: _formatDateTime(_checkIn),
                onTap: () => _pickDateTime(isCheckIn: true),
              ),
              const SizedBox(height: 8),
              DateTimePicker(
                label: 'Trả phòng',
                icon: Icons.logout,
                value: _formatDateTime(_checkOut),
                onTap: () => _pickDateTime(isCheckIn: false),
              ),

              const SizedBox(height: 16),

              // ── Status chip ────────────────────────────────────────
              Row(
                children: [
                  Text(
                    'Trạng thái: ',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Chip(
                    label: Text(
                      statusLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    side: BorderSide(color: statusColor.withValues(alpha: 0.4)),
                    backgroundColor: statusColor.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: Check in – full width
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: handle check-in
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Check in'),
                  ),
                ),
                const SizedBox(height: 8),
                // Row 2: Xóa | Cập nhật
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: handle delete
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                        label: Text(
                          'Xóa',
                          style: TextStyle(color: colorScheme.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.error),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          // TODO: handle update
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Cập nhật'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
