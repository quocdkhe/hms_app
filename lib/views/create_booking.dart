import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/room_details.dart';
import 'package:hms_app/repositories/room_repository.dart';
import 'package:hms_app/repositories/booking_repository.dart';
import 'package:hms_app/utils/format_vnd.dart';
import 'package:hms_app/widgets/date_time_picker.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key, required this.roomId});

  final int roomId;

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  late Future<RoomDetails> _roomDetailsFuture;
  final _roomRepository = RoomRepository();
  final _bookingRepository = BookingRepository();

  final _guestNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _checkInNow = false;
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _roomDetailsFuture = _roomRepository.getRoomDetails(widget.roomId);
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isCheckIn}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

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
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submitBooking() async {
    final name = _guestNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        _checkIn == null ||
        _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (_checkOut!.isBefore(_checkIn!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngày trả phòng phải sau ngày nhận phòng'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _bookingRepository.createBooking(
        roomId: widget.roomId,
        guestName: name,
        guestPhone: phone,
        checkInDateTime: _checkIn!,
        checkOutDateTime: _checkOut!,
        checkInNow: _checkInNow,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tạo booking: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RoomDetails>(
      future: _roomDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lỗi')),
            body: Center(child: Text('Lỗi: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Không tìm thấy')),
            body: const Center(child: Text('Không tìm thấy phòng')),
          );
        }

        final room = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text('Đặt phòng ${room.roomName}')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Section 1: Room details ──────────────────────────
              Card(
                clipBehavior: Clip.antiAlias,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
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
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.bed,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${room.numberOfBed} giường  •  Tầng ${room.floor}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${formatVND(room.pricePerNight)} VND/đêm',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            if (room.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                room.description!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Section 2: Guest information ─────────────────────
              const Text(
                'Thông tin khách',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _guestNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên khách',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // ── Section 3: Check-in / Check-out ──────────────────
              const Text(
                'Thời gian đặt phòng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Check-in now toggle
              DateTimePicker(
                label: 'Nhận phòng',
                icon: Icons.login,
                value: _formatDateTime(_checkIn),
                onTap: _checkInNow
                    ? null
                    : () => _pickDateTime(
                        isCheckIn: true,
                      ), // disabled if checkInNow
              ),
              const SizedBox(height: 8),
              DateTimePicker(
                label: 'Trả phòng',
                icon: Icons.logout,
                value: _formatDateTime(_checkOut),
                onTap: () => _pickDateTime(isCheckIn: false),
              ),
              //End section 3
              Row(
                children: [
                  Checkbox(
                    value: _checkInNow,
                    onChanged: (val) {
                      setState(() {
                        _checkInNow = val ?? false;
                        if (_checkInNow) _checkIn = DateTime.now();
                      });
                    },
                  ),
                  const Text('Check-in ngay'),
                ],
              ), // space for bottom button
              const SizedBox(height: 100),
            ],
          ),

          // ── Bottom button ─────────────────────────────────────────
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Thu tiền cọc & đặt lịch',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        );
      },
    );
  }
}
