import 'package:flutter/material.dart';
import 'package:hms_app/widgets/app_drawer.dart';

class FindCustomerView extends StatefulWidget {
  const FindCustomerView({super.key});

  @override
  State<FindCustomerView> createState() => _FindCustomerViewState();
}

class _FindCustomerViewState extends State<FindCustomerView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm khách hàng')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Dummy Text')),
    );
  }
}
