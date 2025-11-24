import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_input.dart';
import '../../widgets/neumorphic/neu_button.dart';

/// Typing Challenge Overlay - User must type out a long passage
class TypingOverlay extends ConsumerStatefulWidget {
  const TypingOverlay({super.key});

  @override
  ConsumerState<TypingOverlay> createState() => _TypingOverlayState();
}

class _TypingOverlayState extends ConsumerState<TypingOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _typingController = TextEditingController();
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  // The passage user must type (randomly selected)
  String targetText = '';
  
  // Passages that take 3-5 minutes to type
  final List<String> passages = [
    "I acknowledge that I am choosing to use this application despite knowing it may not be beneficial to my current goals and wellbeing. I understand that excessive use of digital applications can lead to decreased productivity, reduced focus, and may interfere with more meaningful activities. By typing this message, I am making a conscious decision to proceed with full awareness of these potential consequences. I commit to using this time intentionally and will set appropriate boundaries for myself.",
    
    "This is my deliberate choice to access this application at this moment. I recognize that my time and attention are valuable resources that should be allocated thoughtfully. I am aware that this usage may compete with other priorities in my life, including work, relationships, personal growth, and physical wellbeing. I accept responsibility for this decision and understand that I am choosing this activity over alternatives that might be more aligned with my long-term objectives and values.",
    
    "I am consciously deciding to use this application with full awareness of the implications. I understand that my digital habits shape my daily life and overall productivity. I acknowledge that while this application may provide temporary satisfaction or entertainment, it could detract from more substantial and fulfilling activities. I am making this choice with intention, and I commit to being mindful of the time I spend here and ensuring it aligns with my broader goals and priorities.",
  ];

  @override
  void initState() {
    super.initState();
    
    // Select random passage
    targetText = (passages..shuffle()).first;
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _typingController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final typed = _typingController.text;
    
    // Check if text matches exactly
    if (typed == targetText) {
      // Success!
      HapticFeedback.heavyImpact();
      _completeChallenge();
    } else {
      // Not a match
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0.0);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Text doesn\'t match. ${typed.length}/${targetText.length} characters'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _completeChallenge() {
    const MethodChannel('com.idleman/overlay').invokeMethod('close', {
      'success': true,
      'durationMinutes': AppConstants.defaultBypassDuration
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final size = MediaQuery.of(context).size;
    final typedLength = _typingController.text.length;
    final progress = typedLength / targetText.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppConstants.overlayBlurAmount,
              sigmaY: AppConstants.overlayBlurAmount,
            ),
            child: Container(
              color: theme.isDark
                  ? Colors.black.withOpacity(AppConstants.overlayBackgroundOpacity)
                  : Colors.white.withOpacity(AppConstants.overlayBackgroundOpacity),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: NeuCard(
                  child: SizedBox(
                    width: size.width * 0.9,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Row(
                              children: [
                                Icon(
                                  Icons.keyboard,
                                  color: theme.accent,
                                  size: 32,
                                ),
                                const SizedBox(width: AppConstants.paddingMedium),
                                Expanded(
                                  child: Text(
                                    'Type to Continue',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.mainText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: theme.shadowDark.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(theme.accent),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            
                            // Progress text
                            Text(
                              '${typedLength} / ${targetText.length} characters',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.mainText.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),
                            
                            // Target text to type
                            Text(
                              'Type this text exactly:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.mainText.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            
                            Container(
                              padding: const EdgeInsets.all(AppConstants.paddingMedium),
                              decoration: BoxDecoration(
                                color: theme.shadowDark.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                              ),
                              child: Text(
                                targetText,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: theme.mainText.withOpacity(0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),
                            
                            // Input field
                            Text(
                              'Your typing:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.mainText.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            
                            NeuInput(
                              controller: _typingController,
                              hintText: 'Start typing...',
                              maxLines: 8,
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            
                            // Hint
                            Text(
                              'Type exactly as shown, including punctuation.',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: theme.mainText.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),
                            
                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              child: NeuButton(
                                onTap: _handleSubmit,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppConstants.paddingMedium,
                                  ),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.mainText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
