# Install my OpenCode config into ~/.config/opencode (Windows PowerShell).
# Linux/macOS/WSL/Git Bash users: use setup.sh instead.
#
# Examples:
#   .\setup.ps1                        # multiplier variant (default)
#   .\setup.ps1 -Variant dollars       # USD prices variant
[CmdletBinding()]
param(
  [ValidateSet("multiplier", "dollars")]
  [string]$Variant = "multiplier"
)

$ErrorActionPreference = "Stop"

$RepoDir = $PSScriptRoot
$ConfigRoot = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME ".config" }
$ConfigDir = Join-Path $ConfigRoot "opencode"

$RepoMultiplier = Join-Path $RepoDir "opencode\opencode.json"
$RepoDollars    = Join-Path $RepoDir "opencode\opencode-dollars.json"

if ($Variant -eq "dollars") {
  $Active  = $RepoDollars
  $Aux     = $RepoMultiplier
  $AuxName = "opencode-multiplier.json"
} else {
  $Active  = $RepoMultiplier
  $Aux     = $RepoDollars
  $AuxName = "opencode-dollars.json"
}

foreach ($f in @($Active, $Aux)) {
  if (-not (Test-Path $f)) { throw "Missing $f - run this script from the repo root" }
}

if (-not (Test-Path $ConfigDir)) {
  New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
}

$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Install-File {
  param([string]$Src, [string]$Target)
  if (Test-Path $Target) {
    $srcHash  = (Get-FileHash $Src -Algorithm SHA256).Hash
    $tgtHash  = (Get-FileHash $Target -Algorithm SHA256).Hash
    if ($srcHash -eq $tgtHash) {
      Write-Host "unchanged: $Target"
      return
    }
    Copy-Item $Target "$Target.bak.$Stamp"
    Write-Host "backed up: $(Split-Path -Leaf $Target) -> $(Split-Path -Leaf $Target).bak.$Stamp"
  }
  Copy-Item $Src $Target
  Write-Host "installed: $Target"
}

Install-File $Active (Join-Path $ConfigDir "opencode.json")
Install-File $Aux    (Join-Path $ConfigDir $AuxName)

Write-Host ""
Write-Host "Done. Active variant: $Variant"
Write-Host "If OpenCode is already running, restart its service to pick up the config:"
Write-Host "  opencode service restart"
