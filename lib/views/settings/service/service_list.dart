import 'package:flutter/material.dart';

class ServiceList extends StatelessWidget {
  const ServiceList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách dịch vụ')),
      body: const Center(child: Text('Danh sách dịch vụ')),
    );
  }
}
