import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hms_app/models/services.dart';

class ServiceRepository {
  final _supabase = Supabase.instance.client;

  Future<void> createService({
    required String name,
    String? description,
    required String unit,
    required int pricePerUnit,
    String? imageUrl,
    required bool status,
  }) async {
    await _supabase.from('services').insert({
      'name': name,
      'description': description,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      'image_url': imageUrl,
      'status': status,
    });
  }

  Future<List<Service>> getServices() async {
    final response = await _supabase
        .from('services')
        .select()
        .order('id', ascending: true);

    return (response as List).map((json) => Service.fromJson(json)).toList();
  }

  Future<void> deleteService(int id) async {
    await _supabase.from('services').delete().eq('id', id);
  }
}
