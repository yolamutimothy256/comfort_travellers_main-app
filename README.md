# Comfort Busses Ticketing App

A smart ticketing application for Comfort Busses, transitioning from paper-based to digital ticketing.

## Features

- 🔐 **Authentication**: Email/password and Google Sign-In
- 🎫 **Ticket Management**: Issue, track, and filter tickets by date
- 📊 **Analytics**: Revenue tracking and analytics dashboard (web admin)
- 📧 **Email Integration**: Send tickets to customers via email
- 📱 **QR Codes**: Generate and scan QR codes for ticket validation
- 🎨 **Modern UI**: Clean, intuitive interface with orange (#d51f19) branding

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Firebase account and project
- Android Studio / Xcode (for mobile development)

## Setup Instructions

### 1. Install Flutter

If Flutter is not installed, follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install).

### 2. Get Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```
   This will generate the `firebase_options.dart` file automatically.

### 4. Enable Firebase Services

In Firebase Console, enable:
- **Authentication**: Email/Password and Google Sign-In
- **Firestore Database**: Create database in production mode (we'll add security rules later)
- **Firebase Analytics**: Enabled by default

### 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── core/                 # Core functionality
│   ├── config/          # Configuration files
│   ├── routing/         # App routing
│   └── theme/           # App theming
├── features/            # Feature modules
│   ├── auth/           # Authentication
│   ├── tickets/        # Ticket management
│   └── home/           # Home screen
└── main.dart           # App entry point
```

## Development

### Running Tests

```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Next Steps

- [ ] Implement authentication flows
- [ ] Build ticket issuance and management
- [ ] Integrate QR code generation and scanning
- [ ] Set up email sending via Cloud Functions
- [ ] Create web admin dashboard for analytics

## License

Proprietary - Comfort Busses

