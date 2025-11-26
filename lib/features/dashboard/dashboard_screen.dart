import 'package:flutter/foundation.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/blocklist_provider.dart';
import '../../core/services/platform_services.dart';
import '../../widgets/neumorphic/neu_background.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_button.dart';
import '../../widgets/service_status_banner.dart';

/// Main Dashboard (Home Screen)
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isServiceEnabled = false;
  List<AppInfo> _installedApps = [];
  Set<String> _selectedPackages = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _loadInstalledApps();
    _loadBlocklist();
  }

  Future<void> _loadBlocklist() async {
    final blocklist = ref.read(blocklistProvider);
    setState(() {
      _selectedPackages = blocklist.map((app) => app.packageName).toSet();
    });
  }

  Future<void> _checkServiceStatus() async {
    final isEnabled = await PlatformServices.checkAccessibilityPermission();
    if (mounted) {
      setState(() {
        _isServiceEnabled = isEnabled;
      });
    }
  }

  Future<void> _loadInstalledApps() async {
    setState(() => _isLoading = true);
    try {
      final apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true,
      );
      final launchableApps = apps
          .where((app) =>
              app.packageName != 'com.google.android.inputmethod.latin' &&
              app.packageName != 'com.android.providers.downloads.ui' &&
              app.packageName != 'com.android.providers.media' &&
              app.packageName != 'com.android.providers.downloads' &&
              app.packageName != 'com.android.providers.contacts')
          .toList();
      if (mounted) {
        setState(() {
          _installedApps = launchableApps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading apps: $e')),
        );
      }
    }
  }

  String _getAppCategory(AppInfo app) {
    return 'Other';
  }

  Map<String, List<AppInfo>> get _categorizedApps {
    final Map<String, List<AppInfo>> categories = {};
    for (final app in _installedApps) {
      final category = _getAppCategory(app);
      categories.putIfAbsent(category, () => []);
      categories[category]!.add(app);
    }
    return categories;
  }

  List<AppInfo> get _filteredApps {
    List<AppInfo> apps = _installedApps;
    if (_selectedCategory != null) {
      apps = apps
          .where((app) => _getAppCategory(app) == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      apps = apps.where((app) {
        final appName = app.name.toLowerCase();
        final packageName = app.packageName.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return appName.contains(query) || packageName.contains(query);
      }).toList();
    }
    return apps;
  }

  Future<void> _onAppSelected(AppInfo app) async {
    final hasPermission = await PlatformServices.checkAccessibilityPermission();
    if (!hasPermission) {
      await _showPermissionDialog();
      return;
    }

    final isSelected = _selectedPackages.contains(app.packageName);
    setState(() {
      if (isSelected) {
        _selectedPackages.remove(app.packageName);
      } else {
        _selectedPackages.add(app.packageName);
      }
    });

    await PlatformServices.updateBlockedApps(_selectedPackages.toList());
  }

  Future<void> _showPermissionDialog() async {
    final theme = ref.read(themeProvider);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.background,
        title: Text(
          'Permission Required',
          style: TextStyle(color: theme.mainText, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'To block apps, IdleMan needs the Accessibility Service to be enabled. Please enable it in your device settings.',
          style: TextStyle(color: theme.mainText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: theme.accent)),
          ),
          ElevatedButton(
            onPressed: () async {
              await PlatformServices.requestAccessibilityPermission();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: NeuBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with settings button
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.mainText,
                      ),
                    ),
                    NeuIconButton(
                      icon: Icons.settings,
                      onTap: () async {
                        await Navigator.of(context).pushNamed('/settings');
                        _loadInstalledApps();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              // ...existing code... (ServiceStatusBanner removed)
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: NeuCard(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      hintStyle:
                          TextStyle(color: theme.mainText.withOpacity(0.87)),
                      prefixIcon: Icon(Icons.search,
                          color: theme.mainText.withOpacity(0.87)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(color: theme.mainText),
                  ),
                ),
              ),
              // App grid
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: theme.accent,
                        ),
                      )
                    : _filteredApps.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'No apps found'
                                  : 'No apps match "$_searchQuery"',
                              style: TextStyle(
                                color: theme.mainText.withOpacity(0.87),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _filteredApps.length,
                            itemBuilder: (context, index) {
                              final app = _filteredApps[index];
                              final isSelected =
                                  _selectedPackages.contains(app.packageName);

                              return GestureDetector(
                                onTap: () => _onAppSelected(app),
                                child: Container(
                                  child: Stack(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.memory(
                                            app.icon!,
                                            width: 56,
                                            height: 56,
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: Text(
                                              app.name,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? theme.accent
                                                : theme.background
                                                    .withOpacity(0.5),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? theme.accent
                                                  : theme.mainText
                                                      .withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
