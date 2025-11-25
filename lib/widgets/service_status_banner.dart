import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_provider.dart';
import '../core/services/platform_services.dart';
import '../widgets/neumorphic/neu_card.dart';

/// Banner that shows if accessibility service is enabled
class ServiceStatusBanner extends ConsumerWidget {
  final bool isServiceEnabled;

  const ServiceStatusBanner({
    Key? key,
    required this.isServiceEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    if (isServiceEnabled) {
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
                          color: theme.mainText.withOpacity(0.87),
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
