import 'package:flutter/material.dart';
import 'package:hms_app/widgets/app_drawer.dart';

class RoomMapView extends StatelessWidget {
  const RoomMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sơ đồ phòng')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Dummy Text')),
    );
  }
}
