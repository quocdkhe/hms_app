import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/booking_schedule_item.dart';
import 'package:hms_app/repositories/booking_repository.dart';
import 'package:hms_app/widgets/app_drawer.dart';
import 'package:hms_app/widgets/booking_card.dart';

class BookingSearchView extends StatefulWidget {
  const BookingSearchView({super.key});

  @override
  State<BookingSearchView> createState() => _BookingSearchViewState();
}

class _BookingSearchViewState extends State<BookingSearchView> {
  final _bookingRepository = BookingRepository();
  final _searchController = TextEditingController();
  List<BookingScheduleItem> _allBookings = [];
  List<BookingScheduleItem> _filteredBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _searchController.addListener(_filterBookings);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await _bookingRepository.getAllBookings();
      if (mounted) {
        setState(() {
          _allBookings = bookings;
          _filteredBookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Error loading bookings: $e');
      }
    }
  }

  void _filterBookings() {
    final query = _searchController.text.trim();
    setState(() {
      _filteredBookings = _allBookings.where((booking) {
        // Strict requirement: only search by phone number
        return booking.customerPhone.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm khách hàng')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập số điện thoại',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                ? const Center(child: Text('Không có dữ liệu'))
                : ListView.builder(
                    itemCount: _filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = _filteredBookings[index];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/booking-details/${booking.id}',
                        ),
                        child: BookingCard(booking: booking),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
