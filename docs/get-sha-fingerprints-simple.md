# How to Get SHA Fingerprints for Firebase

## Easiest Method: Android Studio Terminal

1. **Open Terminal in Android Studio:**
   - Click **View** → **Tool Windows** → **Terminal**
   - OR press `Alt + F12`
   - OR click the **Terminal** tab at the bottom of Android Studio

2. **In the terminal, run:**
   ```powershell
   cd android
   .\gradlew signingReport
   ```

3. **Wait for it to complete** (may take 1-2 minutes the first time)

4. **Look for output like this:**
   ```
   Variant: debug
   Config: debug
   Store: C:\Users\YourName\.android\debug.keystore
   Alias: AndroidDebugKey
   SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
   SHA256: 12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF
   ```

5. **Copy both SHA1 and SHA256 values**

## Alternative: If Terminal Doesn't Work

### Option 1: Use Build Output
1. Build your app: **Build** → **Make Project** (or press `Ctrl + F9`)
2. Check the **Build** output tab at the bottom
3. Look for signing information

### Option 2: Check if Keystore Exists First
The debug keystore might not exist yet. Build the app once:
1. Run `flutter run` from command line
2. Or click **Run** in Android Studio
3. This creates the debug keystore
4. Then try the terminal method again

### Option 3: Manual Keystore Location
The debug keystore is usually at:
```
C:\Users\YourName\.android\debug.keystore
```

If it exists, you can use keytool (if Java is installed):
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

## What to Do After Getting Fingerprints

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **comfort-ticketing-app**
3. Click **⚙️ Settings** → **Project settings**
4. Scroll to **Your apps** section
5. Find your Android app
6. Click **Add fingerprint**
7. Paste SHA-1 → Click **Save**
8. Click **Add fingerprint** again
9. Paste SHA-256 → Click **Save**
10. Click **Download google-services.json**
11. Replace `android/app/google-services.json` with the new file
12. Run `flutter clean && flutter run`


