import 'package:mycomicsapp/features/home/presentation/widgets/story_card.dart';
import 'package:mycomicsapp/features/search/presentation/providers/search_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycomicsapp/features/search/presentation/widgets/filter_bottom_sheet.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for comics...',
            border: InputBorder.none,
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () =>
                        ref.read(searchQueryProvider.notifier).state = '',
                  )
                : null,
          ),
          onChanged: (query) {
            ref.read(searchQueryProvider.notifier).state = query;
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: searchResults.when(
        data: (stories) {
          // Cập nhật thông báo
          if (searchQuery.isEmpty &&
              ref.watch(filterOptionsProvider).genreIds.isEmpty) {
            return const Center(
              child: Text('Start searching for your favorite comics.'),
            );
          }
          if (stories.isEmpty) {
            return const Center(child: Text('No results found.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return StoryCard(story: story);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('An error occurred: $error')),
      ),
    );
  }
}
