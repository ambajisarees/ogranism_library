# backup_erp.ps1
# Automates timestamped backups for the Textile ERP project.
# Excludes heavy/transient folders (build, .dart_tool, node_modules, .git) and active lockfiles.

# Determine script directories
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($scriptDir)) { $scriptDir = "." }
$projectRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path

$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$backupDir = Join-Path $projectRoot "_backups"
$zipFile = Join-Path $backupDir "textile_erp_backup_$timestamp.zip"

# Create backup directory if it doesn't exist
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Write-Host "Created backup folder: $backupDir" -ForegroundColor Cyan
}

Write-Host "Gathering files for backup in $projectRoot..." -ForegroundColor Yellow

# Get all source files, excluding the unwanted folders
$files = Get-ChildItem -Path $projectRoot -Recurse -File | Where-Object {
    $relPath = $_.FullName.Replace($projectRoot, "")
    $relPath -notmatch '^\\_backups' -and
    $relPath -notmatch '\\node_modules\\' -and
    $relPath -notmatch '\\\.git\\' -and
    $relPath -notmatch '\\\.dart_tool\\' -and
    $relPath -notmatch '\\build\\' -and
    $relPath -notmatch '\\ephemeral\\' -and
    $relPath -notmatch '\.zip$'
}

Write-Host ("Found {0} files to archive. Compressing..." -f $files.Count) -ForegroundColor Yellow

# Use .NET System.IO.Compression.ZipFile to create the archive cleanly and support relative paths
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

try {
    $zipArchive = [System.IO.Compression.ZipFile]::Open($zipFile, [System.IO.Compression.ZipArchiveMode]::Create)
    foreach ($file in $files) {
        # Calculate relative path inside the zip
        $relativePath = $file.FullName.Replace($projectRoot + "\", "").Replace("\", "/")
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $file.FullName, $relativePath) | Out-Null
    }
    $zipArchive.Dispose()
    
    if (Test-Path $zipFile) {
        $size = (Get-Item $zipFile).Length / 1MB
        Write-Host "Backup Complete: $zipFile" -ForegroundColor Green
        Write-Host ("Approx Size: {0:N2} MB" -f $size) -ForegroundColor Green
    } else {
        Write-Host "Backup failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "Error during backup: $_" -ForegroundColor Red
    if ($zipArchive) { $zipArchive.Dispose() }
}
