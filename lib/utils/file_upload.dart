import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> uploadToStorage(File file) async {
  try {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

    await Supabase.instance.client.storage
        .from('HMS_images')
        .upload(fileName, file);

    return Supabase.instance.client.storage
        .from('HMS_images')
        .getPublicUrl(fileName);
  } catch (e) {
    debugPrint('Upload error: $e');
    return null;
  }
}

Future<void> deleteFromStorage(String publicUrl) async {
  try {
    final fileName = publicUrl.split('/').last;

    await Supabase.instance.client.storage.from('HMS_images').remove([
      fileName,
    ]);

    debugPrint('Deleted: $fileName');
  } catch (e) {
    debugPrint('Delete error: $e');
  }
}
