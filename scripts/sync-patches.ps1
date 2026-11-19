param(
    [string]$Source = "D:\laragon\www\Game\DragonNest\patch",
    [string]$Target = (Join-Path $PSScriptRoot "..\www\Game\DragonNest\patch")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Source)) {
    throw "Source patch directory not found: $Source"
}

New-Item -ItemType Directory -Force -Path $Target | Out-Null

# Sync versioned patch folders and server version config without overwriting local PatchConfigList.xml
Get-ChildItem -Path $Source -Directory | ForEach-Object {
    $destDir = Join-Path $Target $_.Name
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    Copy-Item -Path (Join-Path $_.FullName "*") -Destination $destDir -Recurse -Force
    Write-Host "Synced folder $($_.Name)"
}

$serverCfg = Join-Path $Source "PatchInfoServer.cfg"
if (Test-Path $serverCfg) {
    Copy-Item -Path $serverCfg -Destination (Join-Path $Target "PatchInfoServer.cfg") -Force
    Write-Host "Synced PatchInfoServer.cfg"
}

Write-Host "Patch sync complete -> $Target"
