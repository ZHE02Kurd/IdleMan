# Assets Setup Guide

## Required Assets

### 1. Fonts (assets/fonts/)

Download **Nunito** font family from Google Fonts:
https://fonts.google.com/specimen/Nunito

Required files:
- `Nunito-Regular.ttf`
- `Nunito-SemiBold.ttf` (weight 600)
- `Nunito-Bold.ttf` (weight 700)

Place these files in `assets/fonts/` directory.

### 2. App Icons (android/app/src/main/res/)

Create app icons for different densities using the IdleMan logo:

**Launcher Icons** (ic_launcher.png):
- `mipmap-mdpi/` - 48x48px
- `mipmap-hdpi/` - 72x72px
- `mipmap-xhdpi/` - 96x96px
- `mipmap-xxhdpi/` - 144x144px
- `mipmap-xxxhdpi/` - 192x192px

**Design Specifications**:
- Circular shape with neumorphic effect
- "IM" text in center (IdleMan initials)
- Use accent color (#6C63FF) for text
- Soft shadows for depth
- Background should match app theme

**Tools for Icon Generation**:
- Android Studio Asset Studio
- Online tools: https://icon.kitchen/
- Manual design in Figma/Photoshop

### 3. Splash Screen (Optional)

For Android 12+, create adaptive splash screen:
- `drawable/ic_launcher_foreground.xml`
- Configure in `res/values/styles.xml`

### 4. Images (assets/images/)

Currently no images required. This directory is reserved for future graphics:
- Onboarding illustrations
- Tutorial graphics
- Empty state illustrations

## Installation Steps

1. Create directory structure:
```bash
mkdir -p assets/fonts
mkdir -p assets/images
mkdir -p assets/icons
```

2. Download Nunito fonts and place in `assets/fonts/`

3. Generate app icons and place in appropriate `mipmap-*` directories

4. Run Flutter:
```bash
flutter pub get
flutter run
```

## Verification

Check that assets are properly configured:
```bash
flutter analyze
```

The app should compile and run even without custom fonts (it will fall back to system fonts), but the visual experience will be degraded.

## Note on Logo Design

The splash screen currently shows a simple "IM" text as a placeholder. For production:

1. Design a proper logo with:
   - Neumorphic circular background
   - "IM" or "IdleMan" branding
   - Consistent with app's design language
   
2. Export at 2x, 3x resolutions

3. Place in `assets/images/` and update splash screen code
