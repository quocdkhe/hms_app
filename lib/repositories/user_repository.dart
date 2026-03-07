import 'package:hms_app/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final _supabase = Supabase.instance.client;

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<void> updateUserProfile({
    required String id,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    await _supabase
        .from('user_profiles')
        .update({
          'full_name': fullName,
          'phone': phone,
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
  }
}
