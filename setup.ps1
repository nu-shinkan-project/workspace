$ErrorActionPreference = 'Stop'

$workspaceDirectory = if ($env:WORKSPACE_DIRECTORY) { $env:WORKSPACE_DIRECTORY } else { 'nu-shinkan-workspace' }
$repositoryUrl = if ($env:WORKSPACE_REPOSITORY_URL) { $env:WORKSPACE_REPOSITORY_URL } else { 'https://github.com/nu-shinkan-project/workspace.git' }
$repositoryRef = if ($env:WORKSPACE_REPOSITORY_REF) { $env:WORKSPACE_REPOSITORY_REF } else { 'refs/heads/development-environment' }

# -----------------------
# Create workspace
# -----------------------

New-Item -ItemType Directory -Force -Path $workspaceDirectory | Out-Null
$workspaceDirectory = (Resolve-Path -LiteralPath $workspaceDirectory).Path

# -----------------------
# Resolve latest revision
# -----------------------

$revisionLine = & git ls-remote $repositoryUrl $repositoryRef | Select-Object -First 1

if ($LASTEXITCODE -ne 0 -or -not $revisionLine) {
    throw 'Unable to resolve workspace revision.'
}

$revision = ($revisionLine -split '\s+')[0]

# -----------------------
# Download workspace archive
# -----------------------

$temporaryDirectory = Join-Path ([IO.Path]::GetTempPath()) ("workspace-setup-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $temporaryDirectory | Out-Null

try {
    $archiveUrl = "https://github.com/nu-shinkan-project/workspace/archive/$revision.zip"
    $archivePath = Join-Path $temporaryDirectory 'workspace.zip'
    $extractDirectory = Join-Path $temporaryDirectory 'extracted'

    Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath
    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractDirectory

    # -----------------------
    # Install devcontainer
    # -----------------------

    $archiveRoot = Get-ChildItem -LiteralPath $extractDirectory -Directory | Select-Object -First 1
    $devcontainerSource = Join-Path $archiveRoot.FullName 'devcontainer'
    $devcontainerTarget = Join-Path $workspaceDirectory '.devcontainer'

    if (-not (Test-Path -LiteralPath $devcontainerSource -PathType Container)) {
        throw 'Downloaded bundle is missing devcontainer/.'
    }

    if (Test-Path -LiteralPath $devcontainerTarget) {
        Write-Host 'Keeping existing .devcontainer directory.'
    } else {
        Copy-Item -LiteralPath $devcontainerSource -Destination $devcontainerTarget -Recurse
        Set-Content -LiteralPath (Join-Path $devcontainerTarget '.workspace-revision') -Value $revision -Encoding ascii
    }

    # -----------------------
    # Clone repositories
    # -----------------------

    & (Join-Path $devcontainerTarget 'auto-clone.ps1')

    if ($LASTEXITCODE -ne 0) {
        throw 'auto-clone.ps1 failed.'
    }
} finally {
    if (Test-Path -LiteralPath $temporaryDirectory) {
        Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
    }
}
