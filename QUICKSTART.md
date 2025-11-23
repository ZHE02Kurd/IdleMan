# IdleMan - Setup & Quick Start Guide

## Prerequisites

### Required Software
1. **Flutter SDK** (3.0.0 or higher)
   - Download: https://flutter.dev/docs/get-started/install
   - Add Flutter to PATH

2. **Android Studio** (for Android development)
   - Download: https://developer.android.com/studio
   - Install Android SDK (API level 24+)
   - Install Android SDK Command-line Tools

3. **VS Code** (recommended) or Android Studio
   - VS Code Extensions:
     - Flutter
     - Dart
     - Flutter Riverpod Snippets (optional)

4. **Git**
   - For version control

### Verify Installation
```powershell
flutter doctor
```

Ensure all checks pass for:
- ✓ Flutter SDK
- ✓ Android toolchain
- ✓ VS Code or Android Studio

## Project Setup

### 1. Clone Repository
```powershell
cd C:\Users\zheda\Documents\GitHub
git clone <repository-url> IdleMan
cd IdleMan
```

### 2. Install Dependencies
```powershell
flutter pub get
```

This will download all required packages:
- flutter_riverpod (state management)
- hive & hive_flutter (local database)
- flutter_animate (animations)
- vibration (haptic feedback)
- permission_handler (runtime permissions)
- And more...

### 3. Setup Fonts (Required)

Download **Nunito** font from Google Fonts:
1. Visit: https://fonts.google.com/specimen/Nunito
2. Download font family
3. Extract these files to `assets/fonts/`:
   - `Nunito-Regular.ttf`
   - `Nunito-SemiBold.ttf`
   - `Nunito-Bold.ttf`

### 4. Create App Icons (Optional for development)

For now, the app will use default Flutter icon. To create custom icons:

**Option A - Using Android Studio**:
1. Open `android/` folder in Android Studio
2. Right-click `res` folder → New → Image Asset
3. Create launcher icon with "IM" logo design

**Option B - Using Online Tool**:
1. Visit: https://icon.kitchen/
2. Upload logo design
3. Generate and download icon pack
4. Replace icons in `android/app/src/main/res/mipmap-*/`

### 5. Setup Android Configuration

The Android configuration is already set up in the repository:
- ✓ AndroidManifest.xml with permissions
- ✓ Accessibility service configuration
- ✓ Kotlin source files
- ✓ Build scripts

No additional configuration needed!

## Running the App

### Development Mode

**Connect Android Device** (recommended) or **Start Emulator**:

```powershell
# Check connected devices
flutter devices

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with hot reload enabled (default)
flutter run
```

**Expected behavior**:
1. App launches with splash screen
2. Logo appears at top-right (20% cut-off)
3. After 3 seconds, navigates to onboarding
4. Complete onboarding flow
5. Arrives at dashboard

### Debug Mode Features
- Hot reload: Press `r` in terminal
- Hot restart: Press `R` in terminal
- Toggle performance overlay: Press `P`
- Quit: Press `q`

## Granting Permissions

### During First Run

The app requires two critical permissions

**1. Accessibility Permission**
- Requested during onboarding
- Opens system settings
- Navigate to: Settings → Accessibility → IdleMan
- Toggle ON

**2. Display Over Other Apps**
- Requested during onboarding
- Opens system settings
- Navigate to: Settings → Apps → Special access → Display over other apps → IdleMan
- Toggle ALLOW

### Manual Permission Grant

If skipped during onboarding:
1. Open Settings screen in app
2. Tap on Permissions section
3. Grant required permissions

## Testing the App

### Test Workflow

1. **Theme Toggle**
   - Go to Settings
   - Toggle theme switch
   - Verify smooth transition between Day/Night modes

2. **Block an App**
   - Go to Settings → Blocked Apps
   - Toggle an app ON (e.g., Chrome, YouTube)
   - Wait for sync

3. **Test Overlay**
   - Exit IdleMan (press home button)
   - Launch the blocked app
   - Overlay should appear immediately
   - Complete friction task to proceed

4. **Verify Stats**
   - Return to Dashboard
   - Check "Interruptions Today" counter incremented

### Testing Specific Overlays

To test overlays directly without blocking apps:

**Bureaucrat Overlay**:
```dart
Navigator.of(context).pushNamed('/overlay/bureaucrat');
```

**Chase Overlay**:
```dart
Navigator.of(context).pushNamed('/overlay/chase');
```

Add a debug button in dashboard during development.

## Building for Release

### Create Release APK

```powershell
flutter build apk --release
```

Output location: `build\app\outputs\flutter-apk\app-release.apk`

### Install on Device

```powershell
flutter install --release
```

Or manually:
```powershell
adb install build\app\outputs\flutter-apk\app-release.apk
```

### App Bundle (for Play Store)

```powershell
flutter build appbundle --release
```

Output: `build\app\outputs\bundle\release\app-release.aab`

## Troubleshooting

### Issue: "Flutter command not found"
**Solution**: Add Flutter to system PATH
```powershell
$env:Path += ";C:\path\to\flutter\bin"
```

### Issue: "Android licenses not accepted"
**Solution**:
```powershell
flutter doctor --android-licenses
```
Accept all licenses.

### Issue: "Gradle build failed"
**Solution**:
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "Accessibility service not working"
**Solution**:
1. Verify service enabled in Settings
2. Restart device
3. Check logcat: `adb logcat | Select-String "IdleMan"`

### Issue: "Fonts not loading"
**Solution**:
1. Verify fonts exist in `assets/fonts/`
2. Check `pubspec.yaml` fonts section
3. Run: `flutter clean && flutter pub get`

### Issue: "Hot reload not working"
**Solution**:
1. Try hot restart (`R`)
2. Stop and restart app
3. Check for compilation errors

## Development Tips

### VS Code Shortcuts
- `Ctrl+Shift+P`: Command palette
- `F5`: Start debugging
- `Ctrl+F5`: Run without debugging
- `Shift+F5`: Stop debugging

### Flutter DevTools
```powershell
flutter pub global activate devtools
flutter pub global run devtools
```

Access at: http://localhost:9100

### Logging
```dart
import 'dart:developer' as developer;
developer.log('Message', name: 'IdleMan');
```

View logs:
```powershell
flutter logs
```

### Code Generation (if needed later)
```powershell
flutter pub run build_runner build
```

## Project Structure Reference

```
IdleMan/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/
│   │   ├── theme/                # Theme system
│   │   ├── constants/            # App constants
│   │   ├── services/             # Native communication
│   │   └── providers/            # State management
│   ├── features/
│   │   ├── splash/               # Splash screen
│   │   ├── onboarding/           # Onboarding flow
│   │   ├── dashboard/            # Home screen
│   │   ├── settings/             # Settings screen
│   │   └── overlays/             # Friction tasks
│   └── widgets/
│       └── neumorphic/           # Reusable widgets
├── android/                      # Native Android code
├── assets/                       # Fonts, images, icons
├── pubspec.yaml                  # Dependencies
└── README.md                     # Project overview
```

## Next Steps

1. ✓ Setup complete
2. ✓ App running
3. → Add custom fonts (see ASSETS_SETUP.md)
4. → Test with real apps
5. → Customize blocked apps list
6. → Monitor stats
7. → Build release version
8. → Deploy to device

## Support & Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Riverpod Docs**: https://riverpod.dev/
- **Hive Docs**: https://docs.hivedb.dev/
- **Developer Guide**: See `DEVELOPER_GUIDE.md`
- **Assets Setup**: See `ASSETS_SETUP.md`

---

**Happy Coding! 🚀**

Break the idle habit, one tactile interaction at a time.
