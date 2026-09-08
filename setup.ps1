$ErrorActionPreference = 'Stop'
$workspacePath = if ($env:WORKSPACE_DIRECTORY) { $env:WORKSPACE_DIRECTORY } else { 'nu-shinkan-workspace' }
$repositoryUrl = if ($env:WORKSPACE_REPOSITORY_URL) { $env:WORKSPACE_REPOSITORY_URL } else { 'https://github.com/nu-shinkan-project/workspace.git' }
$repositoryRef = if ($env:WORKSPACE_REPOSITORY_REF) { $env:WORKSPACE_REPOSITORY_REF } else { 'refs/heads/main' }
$temporaryDirectory = Join-Path ([IO.Path]::GetTempPath()) ("workspace-setup-" + [guid]::NewGuid())

try {
    New-Item -ItemType Directory -Force -Path $workspacePath | Out-Null
    $workspacePath = (Resolve-Path -LiteralPath $workspacePath).Path
    New-Item -ItemType Directory -Path $temporaryDirectory | Out-Null
    $revisionLine = (& git ls-remote $repositoryUrl $repositoryRef | Select-Object -First 1)
    if ($LASTEXITCODE -ne 0 -or -not $revisionLine) { throw "Unable to resolve workspace revision: $repositoryRef" }
    $revision = ($revisionLine -split '\s+')[0]
    $archiveUrl = if ($env:WORKSPACE_ARCHIVE_URL) { $env:WORKSPACE_ARCHIVE_URL } else { "https://github.com/nu-shinkan-project/workspace/archive/$revision.zip" }
    $archivePath = Join-Path $temporaryDirectory 'workspace.zip'
    $extractPath = Join-Path $temporaryDirectory 'extracted'
    Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath
    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractPath
    $archiveRoot = Get-ChildItem -LiteralPath $extractPath -Directory | Select-Object -First 1
    $source = Join-Path $archiveRoot.FullName 'devcontainer'
    if (-not (Test-Path -LiteralPath $source -PathType Container)) { throw 'Downloaded bundle is missing devcontainer/.' }
    $destination = Join-Path $workspacePath '.devcontainer'
    if (-not (Test-Path -LiteralPath $destination)) {
        Copy-Item -LiteralPath $source -Destination $destination -Recurse
        Set-Content -LiteralPath (Join-Path $destination '.workspace-revision') -Value $revision -Encoding ascii
    } else {
        Write-Host 'Keeping existing .devcontainer directory.'
    }
    & (Join-Path $destination 'auto-clone.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'auto-clone.ps1 failed.' }
} finally {
    if (Test-Path -LiteralPath $temporaryDirectory) { Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force }
}
