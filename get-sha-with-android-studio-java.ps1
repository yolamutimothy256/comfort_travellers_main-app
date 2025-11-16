# Script to get SHA fingerprints using Android Studio's Java

Write-Host "Finding Android Studio Java..." -ForegroundColor Green

# Common Android Studio Java locations
$possibleJavaPaths = @(
    "$env:LOCALAPPDATA\Android\AndroidStudio\jbr\bin\java.exe",
    "$env:PROGRAMFILES\Android\Android Studio\jbr\bin\java.exe",
    "$env:PROGRAMFILES(X86)\Android\Android Studio\jbr\bin\java.exe",
    "$env:USERPROFILE\AppData\Local\Android\AndroidStudio\jbr\bin\java.exe"
)

$javaPath = $null
foreach ($path in $possibleJavaPaths) {
    if (Test-Path $path) {
        $javaPath = $path
        Write-Host "Found Java at: $javaPath" -ForegroundColor Green
        break
    }
}

if (-not $javaPath) {
    Write-Host "Could not find Android Studio Java automatically." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please find it manually:" -ForegroundColor Cyan
    Write-Host "1. Open Android Studio" -ForegroundColor White
    Write-Host "2. Go to: File → Settings → Build, Execution, Deployment → Build Tools → Gradle" -ForegroundColor White
    Write-Host "3. Check the 'Gradle JDK' path" -ForegroundColor White
    Write-Host "4. It's usually in: Android Studio installation folder\jbr\bin\java.exe" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run:" -ForegroundColor Cyan
    Write-Host '  $env:JAVA_HOME = "C:\path\to\android\studio\jbr"' -ForegroundColor White
    Write-Host '  cd android' -ForegroundColor White
    Write-Host '  .\gradlew signingReport' -ForegroundColor White
    exit
}

# Get the jbr directory (parent of bin)
$jbrDir = Split-Path (Split-Path $javaPath)
$keytoolPath = Join-Path (Split-Path $javaPath) "keytool.exe"

Write-Host ""
Write-Host "Setting JAVA_HOME to: $jbrDir" -ForegroundColor Cyan
$env:JAVA_HOME = $jbrDir
$env:PATH = "$(Split-Path $javaPath);$env:PATH"

Write-Host ""
Write-Host "Getting SHA fingerprints..." -ForegroundColor Green
Write-Host ""

$debugKeystore = "$env:USERPROFILE\.android\debug.keystore"

if (Test-Path $debugKeystore) {
    Write-Host "Using debug keystore: $debugKeystore" -ForegroundColor Cyan
    Write-Host ""
    & $keytoolPath -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android
} else {
    Write-Host "Debug keystore not found at: $debugKeystore" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "The keystore will be created when you build the app." -ForegroundColor Cyan
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Build/run your app once (flutter run)" -ForegroundColor White
    Write-Host "2. Then run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "OR use Android Studio's built-in terminal:" -ForegroundColor Cyan
    Write-Host "  Android Studio automatically sets JAVA_HOME" -ForegroundColor White
    Write-Host "  Just run: cd android && .\gradlew signingReport" -ForegroundColor White
}

Write-Host ""
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Look for SHA1 and SHA256 in the output above" -ForegroundColor White
Write-Host "2. Copy both fingerprints (they look like: AB:CD:EF:12:...)" -ForegroundColor White
Write-Host "3. Go to: https://console.firebase.google.com/" -ForegroundColor White
Write-Host "4. Select your project → Settings → Your Apps → Android app" -ForegroundColor White
Write-Host "5. Click 'Add fingerprint' and paste SHA-1" -ForegroundColor White
Write-Host "6. Click 'Add fingerprint' again and paste SHA-256" -ForegroundColor White
Write-Host "7. Download updated google-services.json" -ForegroundColor White
Write-Host "8. Replace android/app/google-services.json" -ForegroundColor White
Write-Host "=" * 70 -ForegroundColor Cyan


