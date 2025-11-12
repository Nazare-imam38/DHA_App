# DHA Marketplace APK Build Guide

## Prerequisites

To build an APK for your DHA Marketplace app, you need to install the Android SDK. Here are the steps:

### 1. Install Android Studio
1. Download Android Studio from: https://developer.android.com/studio
2. Install Android Studio with default settings
3. Open Android Studio and follow the setup wizard
4. Install the Android SDK through the SDK Manager

### 2. Set Environment Variables
Add these environment variables to your system:

```
ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
```

Add to PATH:
```
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\tools
%JAVA_HOME%\bin
```

### 3. Verify Installation
Run this command to check if everything is set up correctly:
```bash
flutter doctor
```

All items should show green checkmarks.

## Building APK

### Quick Build (Debug)
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

### Build with Specific Target
```bash
flutter build apk --target-platform android-arm64
```

## APK Output Locations

- **Debug APK**: `build\app\outputs\flutter-apk\app-debug.apk`
- **Release APK**: `build\app\outputs\flutter-apk\app-release.apk`

## App Configuration

The app is configured with:
- **Package Name**: com.dha.marketplace
- **App Name**: DHA Marketplace
- **Version**: 1.0.0
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)

## Permissions Included

- Location access (fine and coarse)
- Internet access
- Network state access

## Installation

1. Enable "Unknown Sources" on your Android device
2. Transfer the APK file to your device
3. Open the APK file to install

## Troubleshooting

### Common Issues:

1. **Android SDK not found**
   - Install Android Studio
   - Set ANDROID_HOME environment variable

2. **Java version conflicts**
   - Use Java 17 or compatible version
   - Set JAVA_HOME environment variable

3. **Build fails**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Try building again

4. **Permission denied**
   - Check if device allows installation from unknown sources
   - Ensure APK is not corrupted

## Release Signing (Optional)

For production releases, you should sign your APK with a proper keystore:

1. Generate keystore:
```bash
keytool -genkey -v -keystore dha-marketplace-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dha-marketplace
```

2. Configure signing in `android/app/build.gradle.kts`:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = "dha-marketplace"
        keyPassword = "your-key-password"
        storeFile = file("../dha-marketplace-key.jks")
        storePassword = "your-store-password"
    }
}
```

## Support

If you encounter issues:
1. Check Flutter doctor output
2. Verify Android SDK installation
3. Ensure all environment variables are set
4. Try building a simple Flutter app first
