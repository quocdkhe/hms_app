import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://tqwmnothdnteccmnbygh.supabase.co',
    anonKey: 'sb_publishable_eliqihAi1W5UcmcK9PmiJQ_TCJcyrAp',
  );
  runApp(const HMSApp());
}

class HMSApp extends StatelessWidget {
  const HMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}
