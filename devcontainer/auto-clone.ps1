$ErrorActionPreference = 'Stop'
$workspaceDirectory = Split-Path -Parent $PSScriptRoot
$organization = if ($env:WORKSPACE_REPOSITORY_ORG) { $env:WORKSPACE_REPOSITORY_ORG } else { 'nu-shinkan-project' }

foreach ($rawEntry in Get-Content -LiteralPath (Join-Path $PSScriptRoot 'repos')) {
    $entry = $rawEntry.Trim()
    if (-not $entry -or $entry.StartsWith('#')) { continue }
    if ($entry -match '^(https?://|git@|ssh://)') {
        $url = $entry
        $name = [IO.Path]::GetFileName($entry) -replace '\.git$', ''
    } else {
        $name = $entry -replace '\.git$', ''
        $url = "https://github.com/$organization/$name.git"
    }
    $target = Join-Path $workspaceDirectory $name
    if (Test-Path -LiteralPath $target) {
        Write-Host "Skipping existing path: $target"
        continue
    }
    & git clone -- $url $target
    if ($LASTEXITCODE -ne 0) { throw "git clone failed for $url" }
}
