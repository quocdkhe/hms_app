import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/room_card_item.dart';
import 'package:hms_app/repositories/booking_repository.dart';
import 'package:hms_app/widgets/app_drawer.dart';
import 'package:hms_app/widgets/room_card.dart';

enum RoomFilter {
  all('Tất cả'),
  empty('Trống'),
  checkInToday('Check-in hôm nay'),
  occupied('Đang SD');

  final String label;
  const RoomFilter(this.label);
}

class RoomMapView extends StatefulWidget {
  const RoomMapView({super.key});

  @override
  State<RoomMapView> createState() => _RoomMapViewState();
}

class _RoomMapViewState extends State<RoomMapView> {
  RoomFilter _selectedFilter = RoomFilter.all;

  final _bookingRepository = BookingRepository();
  List<RoomCardItem> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await _bookingRepository.getRoomMap();
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải danh sách phòng: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sơ đồ phòng')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ── Bộ lọc ──────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: RoomFilter.values.map((filter) {
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Lưới phòng ──────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadRooms,
                    child: _rooms.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text('Không có phòng nào')),
                            ],
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.1,
                                ),
                            itemCount: _rooms.length,
                            itemBuilder: (context, index) =>
                                RoomCard(room: _rooms[index]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
