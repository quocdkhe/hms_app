import 'package:flutter/material.dart';
import 'package:hms_app/models/dtos/room_details.dart';
import 'package:hms_app/repositories/room_repository.dart';
import 'package:hms_app/utils/format_vnd.dart';

class RoomDetailScreen extends StatefulWidget {
  final int roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late Future<RoomDetails> _roomDetailsFuture;
  final _roomRepository = RoomRepository();

  @override
  void initState() {
    super.initState();
    _roomDetailsFuture = _roomRepository.getRoomDetails(widget.roomId);
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
          // ── Title ─────────────────────────────────────────
          appBar: AppBar(title: Text('Phòng ${room.roomName}')),

          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Room detail ────────────────────────────────────
              // Room details section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (room.imageUrl != null)
                    Image.network(
                      room.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phòng ${room.roomName} - ${room.typeName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tầng ${room.floor} - ${room.numberOfBed} giường - ${formatVND(room.pricePerNight)} VND/đêm',
                        ),
                        if (room.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            room.description!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              // End room details section
              const Divider(height: 32),

              // ── Khách đang ở ───────────────────────────────────────
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Khách đang ở',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Nguyễn Văn An'),
                subtitle: Text('12/10 – 15/10 (3 đêm)'),
              ),
              const LinearProgressIndicator(value: 0.45),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Quản lý lưu trú'),
              ),

              const Divider(height: 32),

              // ── Đặt phòng sắp tới ──────────────────────────────────
              const Text(
                'Đặt phòng sắp tới',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.hardEdge,
                child: ListTile(
                  title: const Text('Trần Thị Bích'),
                  subtitle: const Text('16/10 – 18/10'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {},
                ),
              ),
              Card(
                clipBehavior: Clip.hardEdge,
                child: ListTile(
                  title: const Text('Lê Minh Khoa'),
                  subtitle: const Text('20/10 – 25/10'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {},
                ),
              ),
              Card(
                clipBehavior: Clip.hardEdge,
                child: ListTile(
                  title: const Text('Phạm Thị Lan'),
                  subtitle: const Text('28/10 – 01/11'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {},
                ),
              ),

              const Divider(height: 32),

              // ── Đặt phòng tương lai ────────────────────────────────
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Đặt thêm lịch cho phòng này'),
              ),
            ],
          ),
        );
      },
    );
  }
}
