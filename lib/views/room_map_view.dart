import 'package:flutter/material.dart';
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

  List<RoomInfo> get _filteredRooms {
    switch (_selectedFilter) {
      case RoomFilter.all:
        return _allRooms;
      case RoomFilter.empty:
        return _allRooms.where((r) => r.status == RoomStatus.empty).toList();
      case RoomFilter.checkInToday:
        return _allRooms
            .where((r) => r.status == RoomStatus.checkInToday)
            .toList();
      case RoomFilter.occupied:
        return _allRooms.where((r) => r.status == RoomStatus.occupied).toList();
    }
  }

  void _onFilterSelected(RoomFilter filter) {
    // TODO: handle filter selection
    setState(() => _selectedFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _filteredRooms;

    return Scaffold(
      appBar: AppBar(title: const Text('Sơ đồ phòng')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _FilterBar(selected: _selectedFilter, onSelected: _onFilterSelected),
          Expanded(
            child: rooms.isEmpty
                ? const Center(child: Text('Không có phòng nào'))
                : _RoomGrid(rooms: rooms),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final RoomFilter selected;
  final ValueChanged<RoomFilter> onSelected;

  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: RoomFilter.values.map((filter) {
            final isSelected = filter == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                filter: filter,
                isSelected: isSelected,
                onTap: () => onSelected(filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final RoomFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          filter.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _RoomGrid extends StatelessWidget {
  final List<RoomInfo> rooms;

  const _RoomGrid({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) => _RoomCard(room: rooms[index]),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomInfo room;

  const _RoomCard({required this.room});

  Color _dotColor(BuildContext context, RoomStatus status) {
    switch (status) {
      case RoomStatus.empty:
        return Colors.green;
      case RoomStatus.occupied:
      case RoomStatus.checkInToday:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dotColor = _dotColor(context, room.status);

    return Card(
      elevation: 1,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                room.type,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                room.number,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.circle, size: 6, color: dotColor),
                  const SizedBox(width: 6),
                  Text(
                    room.statusLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
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
