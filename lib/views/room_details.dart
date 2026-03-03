import 'package:flutter/material.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Thanh tiêu đề ─────────────────────────────────────────
      appBar: AppBar(title: Text('Phòng $roomId')),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Thông tin phòng ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=200',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phòng Suite Giường Đôi Cao Cấp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('Tầng 1 • Hướng thành phố'),
                    SizedBox(height: 4),
                    Text(
                      'Phòng suite rộng rãi với tiện nghi cao cấp và tầm nhìn toàn cảnh',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

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
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Trần Thị Bích'),
            subtitle: const Text('16/10 – 18/10'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Lê Minh Khoa'),
            subtitle: const Text('20/10 – 25/10'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Phạm Thị Lan'),
            subtitle: const Text('28/10 – 01/11'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
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
  }
}
