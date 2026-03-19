import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/room_search_result.dart';
import 'package:hms_app/models/dtos/room_type_option.dart';
import 'package:hms_app/repositories/room_type_repository.dart';
import 'package:hms_app/widgets/app_drawer.dart';
import 'package:hms_app/repositories/room_repository.dart';
import 'package:hms_app/views/booking_many_view.dart';
import 'package:hms_app/widgets/date_time_picker.dart';

class FindRoomView extends StatefulWidget {
  const FindRoomView({super.key});

  @override
  State<FindRoomView> createState() => _FindRoomViewState();
}

class _FindRoomViewState extends State<FindRoomView> {
  final RoomRepository _roomRepository = RoomRepository();
  final RoomTypeRepository _roomTypeRepository = RoomTypeRepository();
  List<RoomSearchResult> _filteredRooms = [];
  List<RoomTypeOption> _roomTypes = [];
  bool _isLoading = false;

  Set<int> selectedRoomTypeIds = {};
  Set<int> selectedRoomIndices = {};
  DateTime? checkInDate;
  DateTime? checkOutDate;
  final TextEditingController bedNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRoomTypes();
  }

  @override
  void dispose() {
    bedNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadRoomTypes() async {
    try {
      final types = await _roomTypeRepository.getRoomTypeOptions();
      setState(() {
        _roomTypes = types;
      });
    } catch (e) {
      debugPrint('Error loading room types: $e');
    }
  }

  void _toggleRoomType(RoomTypeOption type) {
    setState(() {
      if (selectedRoomTypeIds.contains(type.id)) {
        selectedRoomTypeIds.remove(type.id);
      } else {
        selectedRoomTypeIds.add(type.id);
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final initialDate = isCheckIn
        ? (checkInDate ?? DateTime.now())
        : (checkOutDate ?? checkInDate ?? DateTime.now());
    final firstDate = isCheckIn
        ? DateTime.now()
        : (checkInDate ?? DateTime.now());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    final pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      isCheckIn ? 14 : 12,
      0,
    );

    setState(() {
      if (isCheckIn) {
        checkInDate = pickedDateTime;
        if (checkOutDate != null && checkOutDate!.isBefore(checkInDate!)) {
          checkOutDate = null;
        }
      } else {
        checkOutDate = pickedDateTime;
      }
    });
  }

  Future<void> _searchRooms() async {
    setState(() => _isLoading = true);
    try {
      final bedNumber = int.tryParse(bedNumberController.text);

      final selectedTypeNames = selectedRoomTypeIds.isEmpty
          ? null
          : _roomTypes
                .where((t) => selectedRoomTypeIds.contains(t.id))
                .map((t) => t.typeName)
                .toList();

      final rooms = await _roomRepository.searchRooms(
        numberOfBed: bedNumber,
        typeNames: selectedTypeNames,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      setState(() {
        _filteredRooms = rooms;
        selectedRoomIndices.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error finding rooms: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chọn ngày';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, List<RoomSearchResult>> _groupByTypeName() {
    final map = <String, List<RoomSearchResult>>{};
    for (final room in _filteredRooms) {
      map.putIfAbsent(room.typeName, () => []).add(room);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final grouped = _groupByTypeName();

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: Text('Tìm Phòng', style: TextStyle(color: color.onSurface)),
        centerTitle: true,
        backgroundColor: color.surface,
        iconTheme: IconThemeData(color: color.onSurface),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateTimePicker(
              label: 'Nhận phòng',
              icon: Icons.login,
              value: _formatDate(checkInDate),
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 12),
            DateTimePicker(
              label: 'Trả phòng',
              icon: Icons.logout,
              value: _formatDate(checkOutDate),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bedNumberController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: color.onSurface),
              decoration: InputDecoration(
                labelText: 'Giường chính',
                labelStyle: TextStyle(color: color.onSurfaceVariant),
                prefixIcon: Icon(Icons.bed, color: color.primary),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: color.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: color.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: color.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Room type multi-select
            // Room type multi-select
            Text(
              'Loại Phòng',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (_roomTypes.isEmpty)
              LinearProgressIndicator(color: color.primary)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _roomTypes
                    .map(
                      (type) => FilterChip(
                        label: Text(type.typeName),
                        selected: selectedRoomTypeIds.contains(type.id),
                        onSelected: (_) => _toggleRoomType(type),
                      ),
                    )
                    .toList(),
              ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _searchRooms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.primary,
                  foregroundColor: color.onPrimary,
                  disabledBackgroundColor: color.surfaceContainerHighest,
                ),
                icon: _isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color.onPrimary,
                        ),
                      )
                    : const Icon(Icons.search),
                label: const Text('Tìm kiếm'),
              ),
            ),
            const SizedBox(height: 24),
            Divider(thickness: 1, color: color.outlineVariant),
            const SizedBox(height: 12),

            if (_isLoading)
              Center(child: CircularProgressIndicator(color: color.primary))
            else if (_filteredRooms.isEmpty)
              Center(
                child: Text(
                  'Không có phòng nào phù hợp.',
                  style: TextStyle(color: color.onSurfaceVariant),
                ),
              )
            else
              Column(
                children: grouped.entries.map((entry) {
                  final rooms = entry.value;
                  final selectedCountInGroup = rooms
                      .where((r) => selectedRoomIndices.contains(r.id))
                      .length;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: color.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      collapsedBackgroundColor: color.surfaceContainer,
                      backgroundColor: color.surfaceContainer,
                      title: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: rooms.first.imageUrl != null
                                ? Image.network(
                                    rooms.first.imageUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _imagePlaceholder(color, size: 56),
                                  )
                                : _imagePlaceholder(color, size: 56),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedCountInGroup > 0
                                    ? '${rooms.length} phòng · $selectedCountInGroup đã chọn'
                                    : '${rooms.length} phòng trống',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selectedCountInGroup > 0
                                      ? color.primary
                                      : color.onSurfaceVariant,
                                ),
                              ),
                              if (rooms.first.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  rooms.first.description!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: color.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      children: rooms.map((room) {
                        final isSelected = selectedRoomIndices.contains(
                          room.id,
                        );
                        return InkWell(
                          onTap: () => setState(() {
                            if (isSelected) {
                              selectedRoomIndices.remove(room.id);
                            } else {
                              selectedRoomIndices.add(room.id);
                            }
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: color.outlineVariant.withOpacity(0.4),
                                ),
                                left: isSelected
                                    ? BorderSide(color: color.primary, width: 3)
                                    : BorderSide.none,
                              ),
                              color: isSelected
                                  ? color.primary.withOpacity(0.06)
                                  : null,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Phòng ${room.roomName}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: color.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: color.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: selectedRoomIndices.isNotEmpty
              ? () {
                  final selectedRoomIds = selectedRoomIndices
                      .map((i) => _filteredRooms[i].id)
                      .toSet();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateBookingManyScreen(
                        roomIds: selectedRoomIds,
                        checkIn: checkInDate,
                        checkOut: checkOutDate,
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(
            selectedRoomIndices.isEmpty
                ? 'Đặt Phòng'
                : 'Đặt Phòng (${selectedRoomIndices.length})',
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(ColorScheme color, {double size = 80}) {
    return Container(
      width: size,
      height: size,
      color: color.surfaceContainerHighest,
      child: Icon(Icons.image_not_supported, color: color.onSurfaceVariant),
    );
  }
}
