import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/booking_schedule_item.dart';
import 'package:hms_app/models/dtos/customer_short_detail.dart';
import 'package:hms_app/models/enums/booking_status.dart';
import 'package:hms_app/repositories/booking_repository.dart';

class CustomerBookingsView extends StatefulWidget {
  final CustomerShortDetail customer;

  const CustomerBookingsView({super.key, required this.customer});

  @override
  State<CustomerBookingsView> createState() => _CustomerBookingsViewState();
}

class _CustomerBookingsViewState extends State<CustomerBookingsView> {
  late Future<List<BookingScheduleItem>> _bookingsFuture;
  final _bookingRepository = BookingRepository();

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    _bookingsFuture = _bookingRepository.getBookingsByCustomerId(
      widget.customer.userId,
    );
  }

  String _formatDateCompact(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  /// Returns true for bookings the customer is currently involved in
  /// (confirmed / upcoming, checked-in, no-show that may still need action).
  bool _isCurrent(BookingScheduleItem b) =>
      b.status != BookingStatus.checkedOut;

  void _navigateToBooking(BookingScheduleItem booking) async {
    final route = booking.status == BookingStatus.checkedIn
        ? '/stay-management/${booking.id}'
        : '/booking-details/${booking.id}';
    final result = await Navigator.pushNamed(context, route);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thao tác thành công!')),
      );
      setState(() => _loadBookings());
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Đặt phòng của ${customer.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Customer info ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage:
                    (customer.avatar != null && customer.avatar!.isNotEmpty)
                        ? NetworkImage(customer.avatar!)
                        : null,
                child: (customer.avatar == null || customer.avatar!.isEmpty)
                    ? const Icon(Icons.person, size: 36)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
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
                          customer.phone,
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

          const Divider(height: 32),

          // ── Bookings future ─────────────────────────────────────────
          FutureBuilder<List<BookingScheduleItem>>(
            future: _bookingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Lỗi tải đặt phòng: ${snapshot.error}'),
                );
              }

              final bookings = snapshot.data ?? [];
              final current = bookings.where(_isCurrent).toList();
              final completed =
                  bookings.where((b) => !_isCurrent(b)).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section: Current bookings ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Đặt phòng hiện tại',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => setState(() => _loadBookings()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (current.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Không có đặt phòng hiện tại',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ...current.map(
                      (b) => _BookingItem(
                        booking: b,
                        onTap: () => _navigateToBooking(b),
                        formatDate: _formatDateCompact,
                      ),
                    ),

                  const Divider(height: 32),

                  // ── Section: Completed bookings ──────────────────────
                  const Text(
                    'Đã hoàn thành',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (completed.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Không có lịch sử đặt phòng',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ...completed.map(
                      (b) => _BookingItem(
                        booking: b,
                        onTap: () => _navigateToBooking(b),
                        formatDate: _formatDateCompact,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Booking list item ─────────────────────────────────────────────────────────

class _BookingItem extends StatelessWidget {
  final BookingScheduleItem booking;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  const _BookingItem({
    required this.booking,
    required this.onTap,
    required this.formatDate,
  });

  (String label, Color color) _statusDisplay(
    BookingStatus status,
    ColorScheme cs,
  ) {
    return switch (status) {
      BookingStatus.confirmed => ('Đã đặt cọc', cs.primary),
      BookingStatus.checkedIn => ('Đang ở', Colors.green),
      BookingStatus.checkedOut => ('Đã trả phòng', cs.outline),
      BookingStatus.noShow => ('Vắng mặt', Colors.red),
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final (statusLabel, statusColor) = _statusDisplay(booking.status, colorScheme);
    final roomLabel = booking.roomName != null
        ? 'Phòng ${booking.roomName}'
        : 'Phòng #${booking.roomId}';
    final dateRange =
        '${formatDate(booking.checkInDateTime)} – ${formatDate(booking.checkoutDateTime)}';

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          roomLabel,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dateRange,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                statusLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              side: BorderSide(color: statusColor.withValues(alpha: 0.4)),
              backgroundColor: statusColor.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
        isThreeLine: true,
      ),
    );
  }
}
