import 'package:flutter/material.dart';
import 'package:hms_app/widgets/app_drawer.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Dummy Text')),
    );
  }
}
