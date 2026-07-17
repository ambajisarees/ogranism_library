# git_commit.ps1
# Prompts for commit parameters and commits repository changes cleanly.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($scriptDir)) { $scriptDir = "." }
$projectRoot = Resolve-Path (Join-Path $scriptDir "..")

# Set working directory to project root
Push-Location $projectRoot

Write-Host "--- Git Commit Utility ---" -ForegroundColor Cyan

# Stage all files
git add -A
Write-Host "Staged all changes." -ForegroundColor Yellow

# Show staged changes summary
Write-Host "Staged files summary:" -ForegroundColor Gray
git status --short

# Ask for commit message
$msg = Read-Host "Enter commit message"
if ([string]::IsNullOrEmpty($msg)) {
    Write-Host "Commit message cannot be empty! Aborting." -ForegroundColor Red
} else {
    git commit -m $msg
    Write-Host "Commit completed successfully." -ForegroundColor Green
}

Pop-Location
