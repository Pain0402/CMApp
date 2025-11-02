import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mycomicsapp/features/home/presentation/providers/home_providers.dart';

/// A provider that fetches the content (image URLs) for a specific chapter.
final chapterContentProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, chapterId) async {
  final supabase = ref.watch(supabaseClientProvider);

  try {
    final data = await supabase.from('Chapter').select('image_urls').eq('chapter_id', chapterId).single();

    final imageUrlsData = data['image_urls'];
    if (imageUrlsData == null) {
      return [];
    }

    List<dynamic> imageUrlsDynamic;

    // Safely handle different data types for image_urls (List or JSON string).
    if (imageUrlsData is List) {
      imageUrlsDynamic = imageUrlsData;
    } else if (imageUrlsData is String) {
      try {
        imageUrlsDynamic = jsonDecode(imageUrlsData) as List;
      } catch (e) {
        // Fallback for invalid JSON string.
        print('Warning: image_urls is a string but not a valid JSON array. Treating as a single URL. Details: $e');
        imageUrlsDynamic = [imageUrlsData];
      }
    } else {
      throw Exception('Invalid format for image_urls data: ${imageUrlsData.runtimeType}');
    }

    // The data from Supabase is List<dynamic>, so convert to List<String>.
    final imageUrls = imageUrlsDynamic.map((e) => e.toString()).toList();

    // The URLs are already public and don't need further processing.
    return imageUrls;
  } on PostgrestException catch (e) {
    if (e.code == 'PGRST116') {
      // RLS might be preventing access.
      throw Exception('Cannot access this chapter. It might be VIP-only or you are not logged in.');
    }
    rethrow;
  } catch (e) {
    print('Error loading chapter content: $e');
    rethrow;
  }
});
