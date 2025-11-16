# PowerShell script to get SHA fingerprints
# This script will help you get SHA-1 and SHA-256 fingerprints for Firebase

Write-Host "Getting SHA fingerprints for Firebase..." -ForegroundColor Green
Write-Host ""

# Check if Java is available
$javaPath = Get-Command java -ErrorAction SilentlyContinue
if (-not $javaPath) {
    Write-Host "Java not found in PATH. Trying alternative methods..." -ForegroundColor Yellow
    Write-Host ""
    
    # Try to find Java in common locations
    $possibleJavaPaths = @(
        "$env:JAVA_HOME\bin\keytool.exe",
        "C:\Program Files\Java\*\bin\keytool.exe",
        "C:\Program Files (x86)\Java\*\bin\keytool.exe"
    )
    
    $keytoolPath = $null
    foreach ($path in $possibleJavaPaths) {
        $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $keytoolPath = $found.FullName
            break
        }
    }
    
    if ($keytoolPath) {
        Write-Host "Found keytool at: $keytoolPath" -ForegroundColor Green
        Write-Host ""
        $debugKeystore = "$env:USERPROFILE\.android\debug.keystore"
        if (Test-Path $debugKeystore) {
            Write-Host "Getting fingerprints from debug keystore..." -ForegroundColor Cyan
            & $keytoolPath -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android
        } else {
            Write-Host "Debug keystore not found at: $debugKeystore" -ForegroundColor Red
            Write-Host "The keystore will be created automatically when you build the app." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Could not find Java/keytool. Please use one of these methods:" -ForegroundColor Red
        Write-Host ""
        Write-Host "Method 1: Enable Gradle panel in Android Studio" -ForegroundColor Cyan
        Write-Host "  1. View → Tool Windows → Gradle" -ForegroundColor White
        Write-Host "  2. Navigate to: android → Tasks → android → signingReport" -ForegroundColor White
        Write-Host "  3. Double-click signingReport" -ForegroundColor White
        Write-Host ""
        Write-Host "Method 2: Use Android Studio Terminal" -ForegroundColor Cyan
        Write-Host "  1. Open Terminal in Android Studio (View → Tool Windows → Terminal)" -ForegroundColor White
        Write-Host "  2. Run: cd android && .\gradlew signingReport" -ForegroundColor White
        Write-Host ""
        Write-Host "Method 3: Install Java JDK" -ForegroundColor Cyan
        Write-Host "  Download from: https://adoptium.net/" -ForegroundColor White
        Write-Host "  Then run this script again" -ForegroundColor White
    }
} else {
    Write-Host "Java found! Getting fingerprints..." -ForegroundColor Green
    Write-Host ""
    $debugKeystore = "$env:USERPROFILE\.android\debug.keystore"
    if (Test-Path $debugKeystore) {
        Write-Host "Getting fingerprints from debug keystore..." -ForegroundColor Cyan
        keytool -list -v -keystore $debugKeystore -alias androiddebugkey -storepass android -keypass android
    } else {
        Write-Host "Debug keystore not found at: $debugKeystore" -ForegroundColor Yellow
        Write-Host "Building the app once will create it automatically." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "After building, run this script again to get the fingerprints." -ForegroundColor White
    }
}

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Look for SHA1 and SHA256 in the output above" -ForegroundColor White
Write-Host "2. Copy both fingerprints" -ForegroundColor White
Write-Host "3. Go to Firebase Console → Project Settings → Your Apps" -ForegroundColor White
Write-Host "4. Add both SHA-1 and SHA-256 fingerprints" -ForegroundColor White
Write-Host "5. Download updated google-services.json" -ForegroundColor White
Write-Host "=" * 60 -ForegroundColor Cyan


