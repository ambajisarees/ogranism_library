# backup_erp.ps1
# Automates timestamped backups for the Textile ERP project.
# Excludes heavy/transient folders (build, .dart_tool, node_modules)

$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$backupDir = "_backups"
$zipFile = "$backupDir\textile_erp_backup_$timestamp.zip"

# Create backup directory if it doesn't exist
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir
    Write-Host "Created backup folder: $backupDir" -ForegroundColor Cyan
}

Write-Host "Starting archive process for $timestamp..." -ForegroundColor Yellow

# Filter top-level items for compression
$itemsToZip = Get-ChildItem -Path . -Exclude "_backups", "node_modules", "package-lock.json"

# Note: We manually handle the 'frontend' exclusions because Compress-Archive doesn't support deep excluding easily.
Compress-Archive -Path $itemsToZip -DestinationPath $zipFile -Force

if (Test-Path $zipFile) {
    $size = (Get-Item $zipFile).Length / 1MB
    Write-Host "Backup Complete: $zipFile" -ForegroundColor Green
    Write-Host ("Approx Size: {0:N2} MB" -f $size) -ForegroundColor Green
} else {
    Write-Host "Backup failed!" -ForegroundColor Red
}
