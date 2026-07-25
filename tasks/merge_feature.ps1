# tasks/merge_feature.ps1
# Feature branch verification and merge tool for Windows PowerShell.

param(
    [string]$Branch
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($scriptDir)) { $scriptDir = "." }
$projectRoot = Resolve-Path (Join-Path $scriptDir "..")

Push-Location $projectRoot

if ([string]::IsNullOrEmpty($Branch)) {
    $Branch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
    if ($Branch -eq "master") {
        Write-Host "Error: Please specify the feature branch to merge (e.g. .\tasks\merge_feature.ps1 -Branch feature/02-print-recipes)" -ForegroundColor Red
        Pop-Location
        exit 1
    }
}

Write-Host "--- Feature Merge Verification Utility (Windows) ---" -ForegroundColor Cyan
Write-Host "Target Feature Branch: $Branch" -ForegroundColor Yellow

Write-Host "1. Running Flutter Static Analysis..." -ForegroundColor Yellow
Push-Location "$projectRoot\frontend"
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "Static analysis failed! Please fix warnings/errors before merging." -ForegroundColor Red
    Pop-Location
    Pop-Location
    exit 1
}
Pop-Location

Write-Host "2. Updating Graphify Knowledge Graph..." -ForegroundColor Yellow
if (Get-Command graphify -ErrorAction SilentlyContinue) {
    graphify update .
} else {
    Write-Host "Graphify CLI not found in PATH; skipping graph update." -ForegroundColor Gray
}

Write-Host "3. Merging into master..." -ForegroundColor Yellow
git checkout master
git pull origin master
git merge --no-ff $Branch -m "Merge branch '$Branch' into master"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully merged $Branch into master cleanly!" -ForegroundColor Green
} else {
    Write-Host "Merge conflict encountered! Please resolve conflicts manually." -ForegroundColor Red
}

Pop-Location
