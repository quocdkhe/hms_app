import 'package:flutter/material.dart';

class CheckOutView extends StatefulWidget {
  final int bookingId;
  const CheckOutView({super.key, required this.bookingId});

  @override
  State<CheckOutView> createState() => _CheckOutViewState();
}

class _CheckOutViewState extends State<CheckOutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Out')),
      body: const Center(child: Text('Check Out')),
    );
  }
}
