# Script to check Visual Studio installation and run Flutter Windows app

Write-Host "🔍 Checking Visual Studio Build Tools installation..." -ForegroundColor Cyan

$maxAttempts = 60
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $attempt++
    
    # Check if Visual Studio Build Tools is installed
    $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC"
    
    if (Test-Path $vsPath) {
        Write-Host "✅ Visual Studio Build Tools found!" -ForegroundColor Green
        Write-Host "📦 Installing Windows desktop dependencies..." -ForegroundColor Yellow
        
        # Enable Windows desktop
        & C:\Users\abdellah\Desktop\flutter\bin\flutter.bat config --enable-windows-desktop
        
        Write-Host "🔨 Building Windows application..." -ForegroundColor Yellow
        Write-Host "⏳ This may take 5-10 minutes for the first build..." -ForegroundColor Gray
        
        # Run the Windows app
        & C:\Users\abdellah\Desktop\flutter\bin\flutter.bat run -d windows
        
        exit 0
    }
    
    Write-Host "⏳ Waiting for Visual Studio installation... (Attempt $attempt/$maxAttempts)" -ForegroundColor Gray
    Start-Sleep -Seconds 10
}

Write-Host "❌ Visual Studio Build Tools installation timeout" -ForegroundColor Red
Write-Host "Please wait for the installation to complete and run manually:" -ForegroundColor Yellow
Write-Host "  flutter run -d windows" -ForegroundColor White
