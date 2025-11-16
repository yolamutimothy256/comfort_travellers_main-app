# Troubleshooting Guide

## Common Build Errors

### Gradle/Java Version Incompatibility

**Error:**
```
Unsupported class file major version 65
Gradle version is incompatible with the Java version
```

**Solution:**
1. Update Gradle version in `android/gradle/wrapper/gradle-wrapper.properties`:
   ```properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-all.zip
   ```

2. Update Android Gradle Plugin in `android/build.gradle`:
   ```gradle
   classpath 'com.android.tools.build:gradle:8.1.4'
   ```

3. Clean and rebuild:
   ```bash
   flutter clean
   cd android
   ./gradlew clean
   cd ..
   flutter pub get
   flutter run
   ```

**Java/Gradle Compatibility:**
- Java 17 → Gradle 8.3+
- Java 21 → Gradle 8.5+
- Check compatibility: https://docs.gradle.org/current/userguide/compatibility.html#java

### Firebase Not Configured

**Error:**
```
DefaultFirebaseOptions have not been configured
```

**Solution:**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### Package Not Found

**Error:**
```
Package not found: <package-name>
```

**Solution:**
```bash
# Clear pub cache
flutter pub cache repair

# Get dependencies
flutter pub get

# If still failing, check pubspec.yaml for correct package names
```

### Android Build Failed

**Error:**
```
BUILD FAILED
```

**Solution:**
```bash
# Clean build
flutter clean

# Clean Android build
cd android
./gradlew clean
cd ..

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

### iOS Build Failed

**Error:**
```
CocoaPods not installed or out of date
```

**Solution:**
```bash
# Install/update CocoaPods
sudo gem install cocoapods

# Install pods
cd ios
pod install
pod update
cd ..

# Clean and rebuild
flutter clean
flutter run
```

### No Devices Found

**Error:**
```
No devices found
```

**Solution:**

**For Android:**
1. Start Android Studio
2. Open AVD Manager (Tools > Device Manager)
3. Create/Start an emulator
4. Or connect a physical device with USB debugging enabled

**For iOS (Mac only):**
1. Open Xcode
2. Xcode > Open Developer Tool > Simulator
3. Start a simulator

**For Web:**
```bash
flutter run -d chrome
```

### Hot Reload Not Working

**Solution:**
- Press `R` (capital R) for hot restart instead of `r`
- Or stop the app (`q`) and restart with `flutter run`
- Check for syntax errors that prevent hot reload

### Permission Denied Errors

**Error:**
```
Permission denied: gradlew
```

**Solution (Linux/Mac):**
```bash
chmod +x android/gradlew
chmod +x ios/Podfile
```

### Out of Memory

**Error:**
```
OutOfMemoryError: Java heap space
```

**Solution:**
Update `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096M -XX:MaxMetaspaceSize=512m
```

## Getting Help

1. Check Flutter doctor:
   ```bash
   flutter doctor -v
   ```

2. Check logs:
   ```bash
   flutter logs
   ```

3. Run with verbose output:
   ```bash
   flutter run -v
   ```

4. Check Flutter issues: https://github.com/flutter/flutter/issues

