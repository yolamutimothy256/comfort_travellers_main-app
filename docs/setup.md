# Setup Guide

## Initial Setup

### 1. Install Flutter

If Flutter is not installed on your system:

1. Download Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract and add Flutter to your PATH
3. Verify installation:
   ```bash
   flutter doctor
   ```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

#### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it "Comfort Busses Ticketing" (or your preferred name)
4. Follow the setup wizard

#### Configure FlutterFire

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Run configuration:
   ```bash
   flutterfire configure
   ```
   
   This will:
   - Detect your Firebase project
   - Generate `lib/core/config/firebase_options.dart`
   - Configure Android and iOS apps

#### Enable Firebase Services

In Firebase Console:

1. **Authentication**
   - Go to Authentication > Sign-in method
   - Enable "Email/Password"
   - Enable "Google" (configure OAuth consent screen)

2. **Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Start in production mode (we'll add rules later)
   - Choose a location

3. **Firebase Analytics**
   - Enabled by default
   - No additional configuration needed

### 4. Android Configuration

#### Update `android/app/build.gradle`

Ensure minimum SDK version:
```gradle
minSdkVersion 21
```

#### Add Google Services

The `google-services.json` file will be added automatically by `flutterfire configure`.

### 5. iOS Configuration

#### Update `ios/Podfile`

Ensure platform version:
```ruby
platform :ios, '12.0'
```

#### Add Google Services

The `GoogleService-Info.plist` file will be added automatically by `flutterfire configure`.

### 6. Run the App

```bash
# For Android
flutter run

# For iOS (Mac only)
flutter run -d ios

# For Web
flutter run -d chrome
```

## Development Workflow

### Running Tests

```bash
flutter test
```

### Code Generation

For Riverpod code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
```

## Troubleshooting

### Firebase Not Initialized

- Ensure `firebase_options.dart` exists and is properly configured
- Verify Firebase project is active
- Check that `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) exists

### Build Errors

- Run `flutter clean`
- Delete `pubspec.lock` and run `flutter pub get`
- For iOS: `cd ios && pod install && cd ..`

### Authentication Issues

- Verify Firebase Authentication is enabled in console
- Check that sign-in methods are properly configured
- Ensure SHA-1 fingerprint is added for Android (for Google Sign-In)

## Next Steps

After setup is complete, proceed with:
1. Implementing authentication flows
2. Building ticket management features
3. Integrating QR code functionality
4. Setting up email notifications

