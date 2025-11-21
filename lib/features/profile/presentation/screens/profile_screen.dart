import 'package:mycomicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:mycomicsapp/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycomicsapp/core/utils/toast_utils.dart';
import 'package:mycomicsapp/core/config/theme/app_theme.dart'; 



class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _showLogoutConfirmationDialog(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Sign Out',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to log out of your account?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: Text(
                'Signout',
                style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); 
                ref.read(justLoggedOutProvider.notifier).state = true;
                await ref.read(profileRepositoryProvider).signOut();
                ref.read(justLoggedOutProvider.notifier).state = true;
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentThemeMode = ref.watch(themeModeProvider);
    final isDarkMode = currentThemeMode == ThemeMode.dark || 
        (currentThemeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('User information not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.surfaceVariant,
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.displayName ?? 'No Name',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ref
                              .read(supabaseClientProvider)
                              .auth
                              .currentUser
                              ?.email ??
                          '',

                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildStatsSection(context, profile: profile),
              const SizedBox(height: 16),
              const Divider(),
              SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode, 
                  color: theme.colorScheme.primary
                ),
                value: isDarkMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).toggleTheme(value);
                },
                activeColor: theme.colorScheme.primary,
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                hoverColor: theme.colorScheme.primary.withAlpha(26), 
                splashColor: theme.colorScheme.primary.withAlpha(51), 
                onTap: () {
                  // TODO: Navigate to settings screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'), 
                hoverColor: theme.colorScheme.primary.withAlpha(26), 
                splashColor: theme.colorScheme.primary.withAlpha(51), 
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigating to notification settings...')), 
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded),
                title: const Text('Help Center'), 
                hoverColor: theme.colorScheme.primary.withAlpha(26), 
                splashColor: theme.colorScheme.primary.withAlpha(51), 
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening help center...')), 
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: colorScheme.error),
                hoverColor: theme.colorScheme.primary.withAlpha(26), 
                splashColor: theme.colorScheme.primary.withAlpha(51), 
                title: Text(
                  'Sign Out',
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () => _showLogoutConfirmationDialog(context, ref),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading profile: $err')),
      ),
    );
  }

  /// Builds the user statistics section (Bookmarks, Comments, Reviews).
  Widget _buildStatsSection(BuildContext context, {required dynamic profile}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          count: profile.bookmarkedStoriesCount,
          label: 'Following',
        ),
        _buildStatItem(
          context,
          count: profile.commentsCount,
          label: 'Comments',
        ),
        _buildStatItem(context, count: profile.reviewsCount, label: 'Reviews'),
      ],
    );
  }

  /// Builds a single item for the statistics section.
  Widget _buildStatItem(
    BuildContext context, {
    required int count,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
