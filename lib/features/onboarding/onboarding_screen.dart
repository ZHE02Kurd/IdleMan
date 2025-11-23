import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/neumorphic/neu_button.dart';
import '../../widgets/neumorphic/neu_background.dart';
import '../../core/services/platform_services.dart';
import 'onboarding_page.dart';

/// Onboarding Flow with Zoom Out scroll transition
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: AppConstants.animationMedium),
        curve: Curves.easeInOut,
      );
    } else {
      // Request permissions before going to dashboard - mandatory
      final permissionsGranted = await _requestPermissions();
      
      if (permissionsGranted && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    }
  }

  Future<bool> _requestPermissions() async {
    bool accessibilityGranted = false;
    bool overlayGranted = false;

    // Request accessibility permission - MANDATORY
    final hasAccessibility = await PlatformServices.checkAccessibilityPermission();
    if (!hasAccessibility && mounted) {
      accessibilityGranted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.accessibility_new, color: Colors.orange),
              SizedBox(width: 8),
              Text('Required: Accessibility'),
            ],
          ),
          content: const Text(
            '🚨 IdleMan REQUIRES accessibility permission to detect when you open blocked apps.\n\n'
            'Without this, the app cannot protect you from compulsive app usage.\n\n'
            'Please enable \"IdleMan\" in Accessibility settings.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await PlatformServices.requestAccessibilityPermission();
                Navigator.pop(context, false);
              },
              child: const Text('Open Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ) ?? false;
    } else {
      accessibilityGranted = hasAccessibility;
    }

    // Request overlay permission - MANDATORY
    final hasOverlay = await PlatformServices.checkOverlayPermission();
    if (!hasOverlay && mounted) {
      overlayGranted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.layers, color: Colors.orange),
              SizedBox(width: 8),
              Text('Required: Overlay'),
            ],
          ),
          content: const Text(
            '🚨 IdleMan REQUIRES overlay permission to show friction tasks.\n\n'
            'Without this, the app cannot interrupt blocked apps.\n\n'
            'Please allow \"Display over other apps\" for IdleMan.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await PlatformServices.requestOverlayPermission();
                Navigator.pop(context, false);
              },
              child: const Text('Open Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ) ?? false;
    } else {
      overlayGranted = hasOverlay;
    }

    // Show final confirmation
    if (mounted && (!accessibilityGranted || !overlayGranted)) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Setup Incomplete'),
          content: Text(
            accessibilityGranted && !overlayGranted
                ? '⚠️ Overlay permission is still required.\n\nPlease enable it in Android Settings > Apps > IdleMan > Display over other apps'
                : !accessibilityGranted && overlayGranted
                    ? '⚠️ Accessibility permission is still required.\n\nPlease enable it in Android Settings > Accessibility > IdleMan'
                    : '⚠️ Both permissions are required for IdleMan to work.\n\nPlease enable them in Android Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('I\'ll Enable Later'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Try again
                await _requestPermissions();
              },
              child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return accessibilityGranted && overlayGranted;
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: NeuBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      AppStrings.onboardingSkip,
                      style: TextStyle(
                        color: theme.mainText.withOpacity(0.6),
                        fontSize: 16,
                        // fontFamily removed
                      ),
                    ),
                  ),
                ),
              ),
              // PageView with zoom-out transition
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                        }
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildPage(index),
                    );
                  },
                ),
              ),
              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingLarge,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => _buildIndicator(index == _currentPage, theme),
                  ),
                ),
              ),
              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: NeuButton(
                  onTap: _nextPage,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      _currentPage == 2
                          ? AppStrings.onboardingGetStarted
                          : AppStrings.onboardingNext,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.mainText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        // fontFamily removed
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const OnboardingPage(
          title: AppStrings.onboardingWelcomeTitle,
          body: AppStrings.onboardingWelcomeBody,
          icon: Icons.psychology,
        );
      case 1:
        return const OnboardingPage(
          title: AppStrings.onboardingPermissionTitle,
          body: AppStrings.onboardingPermissionBody,
          icon: Icons.lock_open,
        );
      case 2:
        return const OnboardingPage(
          title: AppStrings.onboardingBlocklistTitle,
          body: AppStrings.onboardingBlocklistBody,
          icon: Icons.apps,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIndicator(bool isActive, theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: AppConstants.animationFast),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? theme.accent : theme.mainText.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
