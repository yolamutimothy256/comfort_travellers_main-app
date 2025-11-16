# Fix Firebase reCAPTCHA Configuration Error

## Error Message
```
E/RecaptchaCallWrapper: Initial task failed for action RecaptchaAction(action=signInWithPassword)with exception - An internal error has occurred. [ CONFIGURATION_NOT_FOUND ]
```

## Problem
Firebase requires SHA-1 and SHA-256 fingerprints to be registered in your Firebase project for Android apps. This is required for reCAPTCHA verification during authentication.

## Solution

### Step 1: Get Your App's SHA Fingerprints

You have two options:

#### Option A: Using Gradle (Recommended)
```powershell
cd android
.\gradlew signingReport
```

Look for output like:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

#### Option B: Using keytool (If Gradle doesn't work)
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Look for:
- **SHA1:** under "Certificate fingerprints"
- **SHA256:** under "Certificate fingerprints"

### Step 2: Add Fingerprints to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **comfort-ticketing-app**
3. Click the **gear icon** ⚙️ next to "Project Overview"
4. Select **Project settings**
5. Scroll down to **Your apps** section
6. Find your Android app (package: `com.comfortbusses.comfort_busses_ticketing`)
7. Click **Add fingerprint**
8. Add both SHA-1 and SHA-256 fingerprints:
   - Paste SHA-1 fingerprint → Click **Save**
   - Click **Add fingerprint** again
   - Paste SHA-256 fingerprint → Click **Save**

### Step 3: Download Updated google-services.json

1. In the same Firebase Console page (Project settings)
2. Under **Your apps**, find your Android app
3. Click **Download google-services.json**
4. Replace the existing file at:
   ```
   android/app/google-services.json
   ```

### Step 4: Rebuild and Test

```powershell
flutter clean
flutter pub get
flutter run
```

## Alternative: Quick Fix (For Development Only)

If you just need to test quickly, you can temporarily disable reCAPTCHA in Firebase Console:

1. Go to Firebase Console → Authentication → Settings
2. Under **Authorized domains**, make sure your domain is listed
3. However, **this is not recommended** for production

## For Production Builds

When building for production, you'll need to:
1. Get SHA fingerprints from your **release keystore** (not debug keystore)
2. Add those fingerprints to Firebase
3. Use the same `google-services.json` file

## Troubleshooting

### If Gradle command doesn't work:
- Make sure Java is installed and in PATH
- Or use Android Studio: **Build → Generate Signed Bundle/APK → Android App Bundle → Create new →** (it will show fingerprints)

### If keytool command doesn't work:
- Make sure Java JDK is installed
- The debug keystore is usually at: `C:\Users\YourName\.android\debug.keystore`

### Still having issues?
- Make sure you're using the correct Firebase project
- Verify the package name matches: `com.comfortbusses.comfort_busses_ticketing`
- Check that `google-services.json` is in the correct location: `android/app/google-services.json`


