import 'package:flutter/material.dart';
import 'package:hms_app/widgets/app_drawer.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Dummy Text')),
    );
  }
}
