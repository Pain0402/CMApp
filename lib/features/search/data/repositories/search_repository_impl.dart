import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:mycomicsapp/features/search/domain/entities/filter_options.dart';
import 'package:mycomicsapp/features/search/domain/entities/genre.dart';
import 'package:mycomicsapp/features/search/domain/repositories/search_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SupabaseClient supabaseClient;

  SearchRepositoryImpl(this.supabaseClient);

  @override
  Future<List<Genre>> getGenres() async {
    // Giữ nguyên logic getGenres
    try {
      final response = await supabaseClient.from('Genre').select();
      return (response as List).map((item) => Genre.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải thể loại: $e');
    }
  }

  // === THAY ĐỔI LOGIC TẠI ĐÂY ===
  @override
  Future<List<Story>> searchStories(String query, FilterOptions filters) async {
    // DEBUG: Ghi lại các tham số đầu vào
    print(
      '[SearchRepository] Đang tìm kiếm với query: "$query" và genre IDs: ${filters.genreIds}',
    );

    try {
      // Sử dụng `dynamic` để có thể xâu chuỗi các loại builder khác nhau
      dynamic request;

      // Bước 1: Quyết định truy vấn dựa trên bộ lọc
      if (filters.genreIds.isNotEmpty) {
        print(
          '[SearchRepository] Đang lọc theo thể loại. Bắt đầu từ bảng Story_Genre.',
        );
        request = supabaseClient
            .from('Story_Genre')
            .select('Story!inner(*, profiles:author_id(*))')
            .inFilter('genre_id', filters.genreIds.toList());
      } else {
        print(
          '[SearchRepository] Không lọc theo thể loại. Bắt đầu từ bảng Story.',
        );
        request = supabaseClient
            .from('Story')
            .select('*, profiles:author_id(*)');
      }

      // Bước 2: Áp dụng tìm kiếm theo từ khóa nếu có
      if (query.isNotEmpty) {
        final titleColumn = filters.genreIds.isNotEmpty
            ? 'Story.title'
            : 'title';
        print(
          '[SearchRepository] Áp dụng tìm kiếm văn bản trên cột: $titleColumn',
        );
        request = request.ilike(titleColumn, '%$query%');
      }

      // Thực thi truy vấn
      print('[SearchRepository] Đang thực thi truy vấn...');
      final response = await request;
      // LOG QUAN TRỌNG: Xem Supabase trả về gì
      print('[SearchRepository] Supabase response cho truyện: $response');

      // Bước 3: Xử lý kết quả
      List<Story> stories;
      if (filters.genreIds.isNotEmpty) {
        final uniqueStories = <String, Story>{};
        for (var item in (response as List)) {
          final storyData = item['Story'];
          if (storyData != null) {
            final story = Story.fromMap(storyData);
            uniqueStories[story.storyId] = story;
          }
        }
        stories = uniqueStories.values.toList();
      } else {
        stories = (response as List)
            .map((item) => Story.fromMap(item))
            .toList();
      }

      // LOG QUAN TRỌNG: Xem chúng ta đã parse được bao nhiêu truyện
      print('[SearchRepository] Đã parse được ${stories.length} truyện.');
      return stories;
    } catch (e, st) {
      print('[SearchRepository] GẶP LỖI trong searchStories: $e'); // DEBUG
      print('[SearchRepository] Stacktrace: $st'); // DEBUG
      throw Exception('Lỗi khi tìm kiếm/lọc truyện: $e');
    }
  }
}
