import 'package:flutter/material.dart';

class RoomList extends StatelessWidget {
  const RoomList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách phòng')),
      body: const Center(child: Text('Danh sách phòng')),
    );
  }
}
