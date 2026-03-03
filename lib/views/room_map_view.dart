import 'package:flutter/material.dart';
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

enum RoomStatus { empty, occupied, checkInToday }

class RoomInfo {
  final String type;
  final String number;
  final String statusLabel;
  final RoomStatus status;

  const RoomInfo({
    required this.type,
    required this.number,
    required this.statusLabel,
    required this.status,
  });
}

class RoomMapView extends StatefulWidget {
  const RoomMapView({super.key});

  @override
  State<RoomMapView> createState() => _RoomMapViewState();
}

class _RoomMapViewState extends State<RoomMapView> {
  RoomFilter _selectedFilter = RoomFilter.all;

  static const List<RoomInfo> _allRooms = [
    RoomInfo(
      type: 'Standard',
      number: 'S101',
      statusLabel: 'Trống',
      status: RoomStatus.empty,
    ),
    RoomInfo(
      type: 'Standard',
      number: 'S102',
      statusLabel: 'Đang SD',
      status: RoomStatus.occupied,
    ),
    RoomInfo(
      type: 'Deluxe',
      number: 'D201',
      statusLabel: 'Trống',
      status: RoomStatus.empty,
    ),
    RoomInfo(
      type: 'Standard',
      number: 'S202',
      statusLabel: 'Trống',
      status: RoomStatus.empty,
    ),
    RoomInfo(
      type: 'Penthouse',
      number: 'P301',
      statusLabel: 'Trống',
      status: RoomStatus.empty,
    ),
    RoomInfo(
      type: 'Standard',
      number: 'S302',
      statusLabel: 'Trống',
      status: RoomStatus.empty,
    ),
    RoomInfo(
      type: 'Standard',
      number: 'S203',
      statusLabel: 'Trống',
      status: RoomStatus.empty,
    ),
    RoomInfo(
      type: 'Standard',
      number: 'S303',
      statusLabel: 'Trống',
      status: RoomStatus.empty,
    ),
  ];

  List<RoomInfo> get _filteredRooms => _allRooms; // TODO: apply filter

  @override
  Widget build(BuildContext context) {
    final rooms = _filteredRooms;

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
            child: rooms.isEmpty
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
                    itemCount: rooms.length,
                    itemBuilder: (context, index) =>
                        _RoomCard(room: rooms[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Thẻ phòng ─────────────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  final RoomInfo room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final isOccupied = room.status != RoomStatus.empty;

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RoomDetailScreen(roomId: room.number),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(room.type, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                room.number,
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
                  Text(room.statusLabel, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
