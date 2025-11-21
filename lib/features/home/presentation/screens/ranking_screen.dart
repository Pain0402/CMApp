import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final tabs = ['Top Weekly', 'Top Monthly', 'Trending', 'Newcomers'];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((tabName) {
            return _buildRankingList(context, tabName);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRankingList(BuildContext context, String tabName) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final rank = index + 1;
        Color rankColor;
        if (rank == 1) rankColor = const Color(0xFFFFD700); 
        else if (rank == 2) rankColor = const Color(0xFFC0C0C0); 
        else if (rank == 3) rankColor = const Color(0xFFCD7F32); 
        else rankColor = Colors.grey.withOpacity(0.5);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          color: Theme.of(context).cardColor.withOpacity(0.8),
          child: ListTile(
            leading: SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                  ),
                ),
              ),
            ),
            title: Text(
              'Top Story $rank ($tabName)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Action, Adventure • 1.2M views'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ),
        );
      },
    );
  }
}