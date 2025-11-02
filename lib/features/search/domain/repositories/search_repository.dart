// lib/features/search/domain/repositories/search_repository.dart
import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:mycomicsapp/features/search/domain/entities/filter_options.dart';
import 'package:mycomicsapp/features/search/domain/entities/genre.dart';

abstract class SearchRepository {
  // Cập nhật: Thêm tham số FilterOptions
  Future<List<Story>> searchStories(String query, FilterOptions filters);

  // Thêm mới: Hàm để lấy danh sách thể loại
  Future<List<Genre>> getGenres();
}
