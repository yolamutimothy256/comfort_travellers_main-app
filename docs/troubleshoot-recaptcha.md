# Troubleshooting reCAPTCHA Error After Adding SHA Fingerprints

If you've added SHA fingerprints to Firebase but still get the error, try these steps:

## Step 1: Verify Fingerprints Were Added Correctly

1. Go to Firebase Console → Project Settings → Your Apps
2. Click on your Android app
3. Verify you see **both** SHA-1 and SHA-256 listed under "SHA certificate fingerprints"
4. Make sure there are no extra spaces or characters

## Step 2: Verify google-services.json Location

The file must be at:
```
android/app/google-services.json
```

NOT at:
- `android/app/src/google-services.json` ❌
- `android/google-services.json` ❌

## Step 3: Clean and Rebuild

```powershell
flutter clean
flutter pub get
flutter run
```

## Step 4: Wait for Firebase Propagation

Firebase changes can take 5-10 minutes to propagate. If you just added the fingerprints:
1. Wait 5-10 minutes
2. Try again

## Step 5: Verify Package Name Matches

Check that your package name in `android/app/build.gradle` matches Firebase:
- Should be: `com.comfortbusses.comfort_busses_ticketing`
- Check in: `android/app/build.gradle` → `namespace` or `applicationId`

## Step 6: Check Firebase Authentication Settings

1. Go to Firebase Console → Authentication → Settings
2. Under "Authorized domains", make sure your domain is listed
3. For Android, this is usually automatic, but verify

## Step 7: Try Uninstalling and Reinstalling

Sometimes the app caches the old configuration:
```powershell
flutter clean
# Uninstall the app from your device/emulator
flutter run
```

## Step 8: Check Firebase Console for Errors

1. Go to Firebase Console → Authentication → Users
2. Check if there are any error messages
3. Look at Firebase Console → Project Settings → General for any warnings

## Step 9: Verify SHA Fingerprints Match

Run the script again to verify your SHA fingerprints haven't changed:
```powershell
.\get-sha-with-android-studio-java.ps1
```

Make sure the SHA-1 and SHA-256 match what you added to Firebase.

## Step 10: Check for Multiple Firebase Projects

Make sure you're using the correct Firebase project:
- Check `lib/core/config/firebase_options.dart` for the project ID
- Should match: `comfort-ticketing-app`
- Verify in Firebase Console you're in the right project

## Still Not Working?

If none of these work, try:
1. Create a new Android app in Firebase with a different package name (for testing)
2. Or contact Firebase support with your project ID and the error message





