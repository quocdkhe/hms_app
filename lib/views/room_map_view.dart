import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/room_card_item.dart';
import 'package:hms_app/repositories/booking_repository.dart';
import 'package:hms_app/views/room_details.dart';
import 'package:hms_app/widgets/app_drawer.dart';

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
                : _rooms.isEmpty
                ? const Center(child: Text('Không có phòng nào'))
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
                        _RoomCard(room: _rooms[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Thẻ phòng ─────────────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  final RoomCardItem room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final isOccupied = room.status == RoomStatus.using;

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RoomDetailScreen(roomId: room.id)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(room.roomTypeName, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                room.roomName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: isOccupied ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOccupied ? 'Đang SD' : 'Trống',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
