import 'package:flutter/material.dart';
import 'package:hms_app/providers/color_provider.dart';
import 'package:hms_app/views/find_customer_view.dart';
import 'package:hms_app/views/find_room_view.dart';
import 'package:hms_app/views/my_profile_view.dart';
import 'package:hms_app/views/room_details.dart';
import 'package:hms_app/views/settings/room/add_room.dart';
import 'package:hms_app/views/settings/room/room_list.dart';
import 'package:hms_app/views/settings/room_type/room_type_list.dart';
import 'package:hms_app/views/settings/service/create_service_view.dart';
import 'package:hms_app/views/settings/service/service_list.dart';
import 'package:hms_app/views/settings_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/room_map_view.dart';
import 'views/login_view.dart';

import 'package:provider/provider.dart';
import 'package:hms_app/providers/theme_provider.dart';
import 'package:hms_app/providers/user_provider.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://tqwmnothdnteccmnbygh.supabase.co',
    anonKey: 'sb_publishable_eliqihAi1W5UcmcK9PmiJQ_TCJcyrAp',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ColorProvider()),
      ],
      child: const HMSApp(),
    ),
  );
}

class HMSApp extends StatelessWidget {
  const HMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorProvider = Provider.of<ColorProvider>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorProvider.primaryColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorProvider.primaryColor,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/room-map': (context) => const RoomMapView(),
        '/find-room': (context) => const FindRoomView(),
        '/find-customer': (context) => const FindCustomerView(),
        '/settings': (context) => const SettingsView(),
        '/profile': (context) => const MyProfileView(),
        '/room-type-list': (context) => const RoomTypeList(),
        '/room-list': (context) => const RoomList(),
        '/service-list': (context) => const ServiceList(),
        '/create-service': (context) => const CreateServiceView(),
        '/add-room': (context) => const AddRoom(),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);

        // Match: /room/:id
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'room-details') {
          final roomId = uri.pathSegments[1];

          return MaterialPageRoute(
            builder: (context) => RoomDetailScreen(roomId: roomId),
          );
        }

        // Match: /edit-room/:id
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'edit-room') {
          final roomId = int.tryParse(uri.pathSegments[1]);
          if (roomId != null) {
            return MaterialPageRoute(
              builder: (context) => AddRoom(roomId: roomId),
            );
          }
        }

        return null; // fallback
      },
    );
  }
}
