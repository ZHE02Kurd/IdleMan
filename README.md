# IdleMan

An Android application that interrupts compulsive app usage by introducing tactile, "Kinetic Neumorphism" based cognitive friction tasks via system overlays.

## Features

- **Kinetic Neumorphism UI**: Soft shapes, tactile depth, ambient motion, and satisfying kinetic interactions
- **Day/Night Themes**: Dynamic theme switching with consistent neumorphic design
- **Cognitive Friction Overlays**: Two interactive tasks that create meaningful pauses
  - The Neumorphic Bureaucrat: Form-based verification
  - The Kinetic Chase: Tap-to-catch game
- **App Blocking**: Monitor and interrupt specific apps using Accessibility Service
- **Local Data Storage**: Blocklists and preferences stored with Hive

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Local Database**: Hive
- **Native Layer**: Kotlin (AccessibilityService, WindowManager)

## Setup

1. Ensure Flutter SDK is installed (3.0.0+)
2. Run `flutter pub get`
3. For Android: Open `android/` in Android Studio for native development
4. Run `flutter run` to launch on connected device

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── theme/
│   └── constants/
├── features/
│   ├── splash/
│   ├── onboarding/
│   ├── dashboard/
│   ├── settings/
│   └── overlays/
└── widgets/
    └── neumorphic/
```

## Permissions Required

- Accessibility Service (for app monitoring)
- Display over other apps (for overlays)

## License

Proprietary - All Rights Reserved
