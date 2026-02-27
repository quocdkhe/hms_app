import 'package:flutter/material.dart';
import 'package:hms_app/widgets/app_drawer.dart';

class FindRoomView extends StatefulWidget {
  const FindRoomView({super.key});

  @override
  State<FindRoomView> createState() => _FindRoomViewState();
}

class _FindRoomViewState extends State<FindRoomView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm phòng phù hợp')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Dummy Text')),
    );
  }
}
