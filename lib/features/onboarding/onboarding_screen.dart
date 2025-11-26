import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
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
    @override
    void initState() {
      super.initState();
      _initHive();
    }

    Future<void> _initHive() async {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    }
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
      // Mark onboarding complete
      final prefs = await Hive.openBox('settings');
      await prefs.put('onboarding_complete', true);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    }
  }

  void _skip() {
    Hive.openBox('settings').then((prefs) {
      prefs.put('onboarding_complete', true);
      Navigator.of(context).pushReplacementNamed('/dashboard');
    });
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
                        color: theme.mainText.withOpacity(0.87),
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
                        }
                        // Dramatic zoom-out and fade effect
                        double scale = (1 - (value.abs() * 0.5)).clamp(0.6, 1.0);
                        double opacity = (1 - (value.abs() * 0.7)).clamp(0.3, 1.0);
                        double perspective = 0.002;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, perspective)
                            ..scale(scale, scale)
                            ..rotateY(value * 0.25),
                          child: Opacity(
                            opacity: opacity,
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
