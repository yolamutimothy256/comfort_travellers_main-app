# Firebase reCAPTCHA Setup Guide

## Problem
Getting `CONFIGURATION_NOT_FOUND` error when trying to sign in with Firebase Authentication.

## Solution: Add SHA-1 and SHA-256 Fingerprints to Firebase

### Step 1: Get Your SHA-1 Fingerprint

**Option A: Using keytool (if Java is installed)**
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Option B: Using Android Studio**
1. Open Android Studio
2. Go to **Gradle** (right side panel)
3. Navigate to: `android` > `Tasks` > `android` > `signingReport`
4. Double-click `signingReport`
5. Look for `SHA1:` and `SHA256:` in the output

**Option C: Using Flutter (if debug keystore exists)**
```bash
cd android
.\gradlew signingReport
```
Look for the SHA-1 and SHA-256 values in the output.

### Step 2: Add Fingerprints to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **comfort-ticketing-app**
3. Click the **⚙️ Settings** icon (gear icon) next to "Project Overview"
4. Select **Project settings**
5. Scroll down to **Your apps** section
6. Find your Android app (`com.comfortbusses.comfort_busses_ticketing`)
7. Click **Add fingerprint**
8. Paste your **SHA-1** fingerprint
9. Click **Add fingerprint** again
10. Paste your **SHA-256** fingerprint
11. Click **Save**

### Step 3: Download Updated google-services.json

After adding the fingerprints:
1. In Firebase Console, click **Download google-services.json**
2. Replace the existing file at `android/app/google-services.json` with the new one
3. Rebuild your app: `flutter clean && flutter run`

### Step 4: Verify reCAPTCHA is Enabled

1. In Firebase Console, go to **Authentication** > **Settings**
2. Scroll to **Authorized domains**
3. Make sure your domain is listed (for local testing, `localhost` should be there)
4. Go to **Sign-in method** tab
5. Ensure **Email/Password** is enabled

## Alternative: Use reCAPTCHA Enterprise (Recommended for Production)

If you continue having issues, consider enabling reCAPTCHA Enterprise:
1. In Firebase Console, go to **Authentication** > **Settings** > **reCAPTCHA Enterprise**
2. Enable reCAPTCHA Enterprise
3. This provides better security and reliability

## Notes

- The SHA-1/SHA-256 fingerprints are required for Firebase Authentication to work on Android
- You need separate fingerprints for debug and release builds
- After adding fingerprints, it may take a few minutes for changes to propagate

