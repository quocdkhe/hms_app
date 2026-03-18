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

    // Check-in always at 14:00, check-out always at 12:00
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

      // Get selected type names; if none selected, search all
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

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

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
            // Check-in
            DateTimePicker(
              label: 'Nhận phòng',
              icon: Icons.login,
              value: _formatDate(checkInDate),
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 12),

            // Check-out
            DateTimePicker(
              label: 'Trả phòng',
              icon: Icons.logout,
              value: _formatDate(checkOutDate),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 12),

            // Bed number
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

            // Search button
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

            // Room list
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
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredRooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final room = _filteredRooms[index];
                  final isSelected = selectedRoomIndices.contains(index);
                  return Card(
                    color: color.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: isSelected ? color.primary : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() {
                        if (selectedRoomIndices.contains(index)) {
                          selectedRoomIndices.remove(index);
                        } else {
                          selectedRoomIndices.add(index);
                        }
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: room.imageUrl != null
                                  ? Image.network(
                                      room.imageUrl!,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _imagePlaceholder(color),
                                    )
                                  : _imagePlaceholder(color),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Phòng ${room.roomName}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
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
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.bed,
                                        size: 14,
                                        color: color.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${room.numberOfBed} giường',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: color.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    room.description ?? 'Không có mô tả.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: color.onSurfaceVariant,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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

  Widget _imagePlaceholder(ColorScheme color) {
    return Container(
      width: 90,
      height: 90,
      color: color.surfaceContainerHighest,
      child: Icon(Icons.image_not_supported, color: color.onSurfaceVariant),
    );
  }
}
