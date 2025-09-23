@echo off
echo Starting DHA Marketplace Mobile App...
echo.

echo Checking Flutter installation...
flutter doctor

echo.
echo Installing dependencies...
flutter pub get

echo.
echo Starting the app on Windows...
flutter run -d windows

pause
