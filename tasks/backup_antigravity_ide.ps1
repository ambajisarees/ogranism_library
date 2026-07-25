# backup_antigravity_ide.ps1
# Creates a timestamped zip snapshot of the Antigravity brain/chat-history data
# (~/.gemini/antigravity-ide) so it can be cleanly reverted to an older state
# independent of git history/LFS/sync surgery.
# Excludes .git internals (already backed up on GitHub) and the same
# heavy/unrelated folders that are excluded from the git sync itself
# (browser_recordings, html_artifacts, playground, scratch, bin, mcp, plugins,
# prompting). Includes mcp_config.json / installation_id since those aren't
# recoverable from GitHub — this zip stays local-only (see .gitignore).

$sourceRoot = Join-Path $env:USERPROFILE ".gemini\antigravity-ide"
$backupDir = Join-Path $sourceRoot "_backups"

$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$zipFile = Join-Path $backupDir "antigravity_ide_backup_$timestamp.zip"

if (!(Test-Path $sourceRoot)) {
    Write-Host "Source folder not found: $sourceRoot" -ForegroundColor Red
    exit 1
}

# Create backup directory if it doesn't exist
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Write-Host "Created backup folder: $backupDir" -ForegroundColor Cyan
}

Write-Host "Gathering files for backup in $sourceRoot..." -ForegroundColor Yellow

# Get all source files, excluding git internals, unrelated heavy folders, and prior backups
$files = Get-ChildItem -Path $sourceRoot -Recurse -File | Where-Object {
    $relPath = $_.FullName.Replace($sourceRoot, "")
    $relPath -notmatch '^\\_backups' -and
    $relPath -notmatch '\\\.git\\' -and
    $relPath -notmatch '\\browser_recordings\\' -and
    $relPath -notmatch '\\html_artifacts\\' -and
    $relPath -notmatch '\\playground\\' -and
    $relPath -notmatch '\\scratch\\' -and
    $relPath -notmatch '\\bin\\' -and
    $relPath -notmatch '\\mcp\\' -and
    $relPath -notmatch '\\plugins\\' -and
    $relPath -notmatch '\\prompting\\' -and
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
        $relativePath = $file.FullName.Replace($sourceRoot + "\", "").Replace("\", "/")
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
