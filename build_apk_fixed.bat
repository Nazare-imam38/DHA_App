@echo off
echo ========================================
echo DHA Marketplace APK Builder (Fixed)
echo ========================================
echo.

echo Checking Flutter installation...
flutter doctor

echo.
echo ========================================
echo Building APK...
echo ========================================

echo Building debug APK...
flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Debug APK built successfully!
    echo.
    echo Copying APK to expected location...
    mkdir -p build\app\outputs\flutter-apk
    copy android\app\build\outputs\flutter-apk\app-debug.apk build\app\outputs\flutter-apk\app-debug.apk
    
    echo.
    echo Building release APK...
    flutter build apk --release
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo Copying release APK to expected location...
        copy android\app\build\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\app-release.apk
        
        echo.
        echo ========================================
        echo APK Build Successful!
        echo ========================================
        echo Debug APK: build\app\outputs\flutter-apk\app-debug.apk
        echo Release APK: build\app\outputs\flutter-apk\app-release.apk
        echo.
        echo Alternative locations:
        echo Debug APK: android\app\build\outputs\flutter-apk\app-debug.apk
        echo Release APK: android\app\build\outputs\flutter-apk\app-release.apk
        echo.
        echo Both APKs are ready for installation!
        echo.
    ) else (
        echo.
        echo Release build failed, but debug APK is available.
        echo Debug APK location: android\app\build\outputs\flutter-apk\app-debug.apk
        echo.
    )
) else (
    echo.
    echo ========================================
    echo Build Failed!
    echo ========================================
    echo Please ensure:
    echo 1. Android SDK is installed
    echo 2. ANDROID_HOME environment variable is set
    echo 3. Flutter doctor shows no issues
    echo.
)

pause
