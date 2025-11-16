# Running and Testing the App in Cursor

## Prerequisites

Before running the app, ensure you have:

1. **Flutter installed** and in your PATH
2. **Firebase configured** (see [Setup Guide](./setup.md))
3. **Android Studio** (for Android) or **Xcode** (for iOS/Mac)

## Quick Start

### 1. Install Dependencies

First, install all Flutter packages:

```bash
flutter pub get
```

### 2. Configure Firebase

If you haven't already, configure Firebase:

```bash
# Install FlutterFire CLI (if not already installed)
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This will:
- Generate `lib/core/config/firebase_options.dart`
- Add `google-services.json` (Android)
- Add `GoogleService-Info.plist` (iOS)

### 3. Check Available Devices

See what devices/emulators are available:

```bash
flutter devices
```

### 4. Run the App

#### Option A: Run on Connected Device/Emulator

```bash
# Run on the first available device
flutter run

# Run on a specific device (use device ID from `flutter devices`)
flutter run -d <device-id>

# Run in release mode (faster, no hot reload)
flutter run --release
```

#### Option B: Run on Android Emulator

1. Start Android Studio
2. Open AVD Manager (Tools > Device Manager)
3. Start an emulator
4. Run: `flutter run`

#### Option C: Run on iOS Simulator (Mac only)

1. Open Xcode
2. Start a simulator (Xcode > Open Developer Tool > Simulator)
3. Run: `flutter run`

#### Option D: Run on Web

```bash
flutter run -d chrome
```

## Using Cursor's Terminal

### Opening Terminal in Cursor

1. Press `` Ctrl+` `` (backtick) or go to **Terminal > New Terminal**
2. The terminal opens at the project root

### Running Commands

All Flutter commands work in Cursor's terminal:

```bash
# Check Flutter setup
flutter doctor

# Get dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Build for release
flutter build apk --release  # Android
flutter build ios --release   # iOS
```

## Hot Reload and Hot Restart

While the app is running:

- **Hot Reload**: Press `r` in the terminal (quick updates)
- **Hot Restart**: Press `R` in the terminal (full restart)
- **Quit**: Press `q` in the terminal

## Debugging

### Using Flutter DevTools

1. Run the app: `flutter run`
2. In the terminal, you'll see a DevTools URL
3. Open it in your browser for:
   - Widget inspector
   - Performance profiling
   - Network monitoring
   - Memory analysis

### Using Cursor's Debugger

1. Set breakpoints in your code (click left of line numbers)
2. Press `F5` or go to **Run > Start Debugging**
3. Select "Flutter" as the debugger
4. The app will launch in debug mode

### Viewing Logs

Logs appear in the terminal where you ran `flutter run`. You can also:

```bash
# View logs for a specific device
flutter logs

# Filter logs
flutter logs | grep "error"
```

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/widget_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

## Common Issues and Solutions

### Issue: "No devices found"

**Solution:**
- For Android: Start an emulator in Android Studio
- For iOS: Start a simulator in Xcode
- For physical device: Enable USB debugging and connect via USB

### Issue: "Firebase not initialized"

**Solution:**
```bash
# Make sure Firebase is configured
flutterfire configure

# Verify firebase_options.dart exists
ls lib/core/config/firebase_options.dart
```

### Issue: "Build failed"

**Solution:**
```bash
# Clean build
flutter clean

# Get dependencies again
flutter pub get

# For Android, rebuild
cd android && ./gradlew clean && cd ..

# For iOS, reinstall pods
cd ios && pod install && cd ..
```

### Issue: "Package not found"

**Solution:**
```bash
# Clear pub cache
flutter pub cache repair

# Get dependencies again
flutter pub get
```

## Recommended Workflow

1. **Start Development:**
   ```bash
   flutter pub get
   flutter run
   ```

2. **Make Changes:**
   - Edit code in Cursor
   - Save file (auto hot reload)
   - Or press `r` in terminal for manual reload

3. **Test Changes:**
   - Use hot reload for quick iterations
   - Use hot restart (`R`) for state resets
   - Check terminal for errors

4. **Before Committing:**
   ```bash
   flutter analyze
   flutter test
   ```

## Platform-Specific Notes

### Android

- Minimum SDK: 21 (configured in `android/app/build.gradle`)
- Requires `google-services.json` in `android/app/`
- Test on API 21+ emulator or device

### iOS

- Minimum iOS: 12.0 (configured in `ios/Podfile`)
- Requires `GoogleService-Info.plist` in `ios/Runner/`
- Requires Mac and Xcode for building

### Web

- Run: `flutter run -d chrome`
- May need to enable web support: `flutter config --enable-web`

## Tips for Cursor

1. **Use Multiple Terminals:**
   - One for `flutter run`
   - One for other commands (git, etc.)

2. **Watch Mode:**
   - Use `flutter run` (not `--release`) for hot reload
   - Keep terminal visible to see errors

3. **Quick Commands:**
   - `Ctrl+C` to stop the app
   - `r` for hot reload
   - `R` for hot restart
   - `q` to quit

4. **Code Completion:**
   - Cursor provides IntelliSense for Flutter/Dart
   - Use `Ctrl+Space` for autocomplete

5. **Error Detection:**
   - Cursor shows errors inline
   - Check Problems panel (`Ctrl+Shift+M`)

## Next Steps

After running the app:

1. Test authentication (sign up, login, logout)
2. Verify Firebase connection
3. Test navigation between screens
4. Check role-based UI (if you have admin/agent accounts)

For more details, see [Setup Guide](./setup.md).

