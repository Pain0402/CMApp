// lib/features/search/presentation/widgets/filter_bottom_sheet.dart
import 'package:mycomicsapp/features/search/presentation/providers/search_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe provider lấy thể loại
    final genresAsync = ref.watch(allGenresProvider);
    // Lắng nghe các filter đã chọn
    final selectedFilters = ref.watch(filterOptionsProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Thể loại', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),

          // Xử lý cả 3 trạng thái của FutureProvider
          genresAsync.when(
            data: (genres) {
              if (genres.isEmpty) {
                return const Center(
                  child: Text('Không tìm thấy thể loại nào.'),
                );
              }
              // Hiển thị Wrap các FilterChip
              return Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: genres.map((genre) {
                  final isSelected = selectedFilters.genreIds.contains(
                    genre.id,
                  );
                  return FilterChip(
                    label: Text(genre.name),
                    selected: isSelected,
                    onSelected: (_) => ref
                        .read(filterOptionsProvider.notifier)
                        .toggleGenre(genre.id),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
              // Make sure this error part exists
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error loading genres:\n$e',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: const Text('Áp dụng'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
