# graphify_update.ps1
# Runs AST-only graphify index rebuild for code relationships tracking.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($scriptDir)) { $scriptDir = "." }
$projectRoot = Resolve-Path (Join-Path $scriptDir "..")

# Set working directory to project root
Push-Location $projectRoot

Write-Host "--- Graphify Update Utility ---" -ForegroundColor Cyan

# Trigger graphify update CLI
graphify update .

Write-Host "Code graph index rebuilt successfully." -ForegroundColor Green

Pop-Location
