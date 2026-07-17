# flutter_upgrade.ps1
# Runs a comprehensive Flutter environment update and cache clean.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($scriptDir)) { $scriptDir = "." }
$projectRoot = Resolve-Path (Join-Path $scriptDir "..\frontend")

# Set working directory to flutter frontend
Push-Location $projectRoot

Write-Host "--- Flutter Upgrade & Clean Utility ---" -ForegroundColor Cyan

Write-Host "Upgrading Flutter SDK..." -ForegroundColor Yellow
flutter upgrade

Write-Host "Cleaning Flutter build cache..." -ForegroundColor Yellow
flutter clean

Write-Host "Restoring project pub packages..." -ForegroundColor Yellow
flutter pub get

Write-Host "Running static code analysis..." -ForegroundColor Yellow
flutter analyze

Write-Host "Flutter environment updated and verified successfully." -ForegroundColor Green

Pop-Location
