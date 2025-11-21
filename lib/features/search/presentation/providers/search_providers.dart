import 'dart:async';
import 'package:mycomicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:mycomicsapp/features/search/data/repositories/search_repository_impl.dart';
import 'package:mycomicsapp/features/search/domain/entities/filter_options.dart';
import 'package:mycomicsapp/features/search/domain/entities/genre.dart';
import 'package:mycomicsapp/features/search/domain/repositories/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SearchRepositoryImpl(supabaseClient);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider để lấy danh sách tất cả thể loại
final allGenresProvider = FutureProvider.autoDispose<List<Genre>>((ref) {
  final searchRepository = ref.watch(searchRepositoryProvider);
  return searchRepository.getGenres();
});

// StateNotifier để quản lý các tùy chọn bộ lọc
final filterOptionsProvider =
    StateNotifierProvider.autoDispose<FilterOptionsNotifier, FilterOptions>(
      (ref) => FilterOptionsNotifier(),
    );

class FilterOptionsNotifier extends StateNotifier<FilterOptions> {
  FilterOptionsNotifier() : super(const FilterOptions());

  void toggleGenre(int genreId) {
    final newGenres = Set<int>.from(state.genreIds);
    if (newGenres.contains(genreId)) {
      newGenres.remove(genreId);
    } else {
      newGenres.add(genreId);
    }
    state = state.copyWith(genreIds: newGenres);
  }
}

final searchResultsProvider =
    AsyncNotifierProvider.autoDispose<SearchResultsNotifier, List<Story>>(
      SearchResultsNotifier.new,
    );

class SearchResultsNotifier extends AutoDisposeAsyncNotifier<List<Story>> {
  Timer? _debounceTimer;

  @override
  Future<List<Story>> build() async {
    final query = ref.watch(searchQueryProvider);
    final filters = ref.watch(filterOptionsProvider);

    if (query.isEmpty && filters.genreIds.isEmpty) {
      return [];
    }

    state = const AsyncValue.loading();
    _debounceTimer?.cancel();

    final completer = Completer<List<Story>>();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final searchRepository = ref.read(searchRepositoryProvider);
        // Truyền cả query và filters vào repository
        final results = await searchRepository.searchStories(query, filters);
        if (!completer.isCompleted) completer.complete(results);
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      }
    });

    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    return completer.future;
  }
}
