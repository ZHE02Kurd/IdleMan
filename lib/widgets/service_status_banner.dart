import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_provider.dart';
import '../core/services/platform_services.dart';
import '../widgets/neumorphic/neu_card.dart';

/// Banner that shows if accessibility service is enabled
class ServiceStatusBanner extends ConsumerStatefulWidget {
  const ServiceStatusBanner({Key? key}) : super(key: key);

  @override
  ConsumerState<ServiceStatusBanner> createState() => _ServiceStatusBannerState();
}

class _ServiceStatusBannerState extends ConsumerState<ServiceStatusBanner> with WidgetsBindingObserver {
  bool _isServiceEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkServiceStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recheck when app comes to foreground
      _checkServiceStatus();
    }
  }

  Future<void> _checkServiceStatus() async {
    try {
      final isEnabled = await PlatformServices.checkAccessibilityPermission();
      if (mounted) {
        setState(() {
          _isServiceEnabled = isEnabled;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_isServiceEnabled) {
      // Service is enabled - show success banner
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: NeuCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Protection Active',
                        style: TextStyle(
                          color: theme.mainText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'IdleMan is monitoring your apps',
                        style: TextStyle(
                          color: theme.mainText.withOpacity(0.6),
                          fontSize: 12,
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

    // Service is NOT enabled - show warning banner with action
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () async {
          await PlatformServices.requestAccessibilityPermission();
          // Recheck after a delay
          Future.delayed(const Duration(seconds: 2), _checkServiceStatus);
        },
        child: NeuCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.1),
                  Colors.red.withOpacity(0.1),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setup Required',
                        style: TextStyle(
                          color: theme.mainText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enable IdleMan accessibility service to start blocking apps',
                        style: TextStyle(
                          color: theme.mainText.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.accent,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
