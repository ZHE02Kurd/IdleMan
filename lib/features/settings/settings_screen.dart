import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/blocklist_provider.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_toggle.dart';
import '../../widgets/service_status_banner.dart';
import '../../widgets/neumorphic/neu_background.dart';
import '../../widgets/neumorphic/neu_toggle.dart';
import '../../widgets/neumorphic/neu_button.dart';
import 'blocked_apps_screen.dart';

/// Settings Screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final blocklist = ref.watch(blocklistProvider);
    final blocklistNotifier = ref.read(blocklistProvider.notifier);

    return Scaffold(
      backgroundColor: theme.background,
      body: NeuBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.mainText,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(
                      AppStrings.settingsTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.mainText,
                        // fontFamily removed
                      ),
                    ),
                  ],
                ),
              ),
              // Settings list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  children: [
                    // Service status banner
                    const ServiceStatusBanner(),
                    // Theme toggle
                    NeuCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                theme.isDark
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: theme.accent,
                                size: 28,
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.settingsThemeToggle,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: theme.mainText,
                                      // fontFamily removed
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    theme.isDark
                                        ? AppStrings.settingsThemeNight
                                        : AppStrings.settingsThemeDay,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.mainText.withOpacity(0.6),
                                      // fontFamily removed
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          NeuToggle(
                            value: theme.isDark,
                            onChanged: (_) => themeNotifier.toggleTheme(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    // Blocked apps section
                    NeuCard(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
                        leading: Icon(
                          Icons.block,
                          color: theme.accent,
                          size: 28,
                        ),
                        title: Text(
                          'Manage Blocked Apps',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.mainText,
                          ),
                        ),
                        subtitle: Text(
                          '${blocklist.where((app) => app.isBlocked).length} apps blocked',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.mainText.withOpacity(0.6),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: theme.accent,
                          size: 20,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BlockedAppsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Access Duration setting
                    NeuCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: theme.accent,
                                  size: 28,
                                ),
                                const SizedBox(width: AppConstants.paddingMedium),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Access Duration',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: theme.mainText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'How long apps stay unlocked',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.mainText.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            Text(
                              '${AppConstants.defaultBypassDuration} minutes',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.accent,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Text(
                              'After completing a challenge, you\'ll have ${AppConstants.defaultBypassDuration} minutes of access.',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.mainText.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Permissions section
                    Text(
                      AppStrings.settingsPermissions,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.mainText.withOpacity(0.7),
                        // fontFamily removed
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    NeuCard(
                      child: Row(
                        children: [
                          Icon(
                            Icons.accessibility,
                            color: theme.accent,
                            size: 28,
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Accessibility Service',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.mainText,
                                    // fontFamily removed
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Required for app monitoring',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.mainText.withOpacity(0.6),
                                    // fontFamily removed
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
